addprocs(20)
@everywhere using StatsBase
@everywhere using LsqFit
@everywhere using PyPlot

@everywhere include("MyFunc.jl")


const Δt = 0.005      # integration time step [ms]


# evolve_model Parameters ----------------------------------------------------------------------------------
const Ra = 0.0045      # In GOhm
const ps= Ps(60., -90., -80., 1./Ra, 250., 800., 2200., 12., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.)  # One variable of type "Ps" is created and initialised
const pa= Pa(60., -90., -80., 1./Ra,   5.,1200.,  800.,  0., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.)  # One variable of type "Pa" is created and initialised


# Input current Parameters ---------------------------------------------------------------------------------

noise = 2                         # If there is noise in the input current, 0 for DC current, 1 for noisy DC current, 2 for noise sine
τ = 10.
AmFreq = 2 			# 1 for 5 Hz, 2 for 20 Hz
stdind = 11
initValues = readdlm("Intersections.jl")
std = initValues[stdind, 3]
Ipeak = initValues[stdind, AmFreq]
amp = abs(Ipeak) * .1
# fRange1 = 0.001:0.001:0.101	# Range of frequencies to be computed over
# fRange2 = 0.111:0.1:1.001
# fRange1 = 0.001:0.01:0.101
# fRange2 = 0.111:0.1:1.001
# fRange = [fRange1; fRange2]
fRange1 = 0.001:(0.01-0.001)/50:0.010
fRange2 = 0.011:(0.100-0.011)/50:0.100
fRange3 = 0.101:(1.-0.101)/50:1.
fRange = [fRange1; fRange2; fRange3]

# Declaring some useful values -------------------------------------------------------------------------

bins = 33
MagArr = SharedArray(Float64, (length(fRange), 4))

# For loop Over The Frequencies ---------------------------------------------------------------------------

@sync @parallel for i=1:length(fRange)

	freq = fRange[i]
	print("Calculating the following frequency: ", freq, "\n")

	# Time Variables of the model ----------------------------------------------------------------------------

	Per = 1. / freq										# The Period
	T  = Per          					# Simulation lifetime [ms]
	N  = Int64(floor(T/Δt))	          # Corresponding number of steps

	t = 0.

	tstimcon = 0.
	tstimcon_dur = T
	tstim = tstimcon_dur - tstimcon
	tstim_dur = Inf


	# Initialiazing Values For The Model -------------------------------------------------------------------

	W  = zeros(N,2)                  # This is a "vector" to "record" state variables as the time goes by.
	xs = Xs(ps.Eleak, 0., 1., 0.)  # Let's declare a var of type "Xs" and initialise it
	xa = Xa(pa.Eleak, 0., 1., 0.)  # Let's declare a var of type "Xa" and initialise it


	# Creating the Noise ---------------------------------------------------------------------------------

	noisevar = zeros(Float64, N)
	noisevar = simulate_ou!(noisevar, N, 0., Δt, 0., std, τ)   # Starting value, time step, Steady-state

	# Initialize the model with a DC current ---------------------------------------------------------------

	(W, xs, xa, t) = evolve_model!(W, ps, pa, xs, xa, Ipeak, N, Δt, t, tstim, tstim_dur, tstimcon, tstimcon_dur, noise, noisevar, amp, freq)


	# Declaring some useful values -------------------------------------------------------------------------

	WCounter = 0.
	TotTime = 0.
	nSom = zeros(Float64, bins)


	# Time Variables of the model -----------------------------------------------------------------------

	T  = Per          					# Simulation lifetime [ms]
	N  = Int64(floor(T/Δt))	          # Corresponding number of steps

	tstimcon = 0.
	tstimcon_dur = 0.
	tstim = 0.
	tstim_dur = Inf


	# While loop to fill up the histogram ---------------------------------------------------------------

	while TotTime <= 10_000_000. && maximum(nSom) < 2500

		WCounter += 1.
		TotTime = WCounter * T

		#t = 0.


		# Creating the Noise ------------------------------------------------------------------------------

		NoiseEnd = noisevar[end]
		noisevar = zeros(Float64, N)
		noisevar = simulate_ou!(noisevar, N, NoiseEnd, Δt, 0., std, τ)   # Starting value, time step, Steady-state


		# Simulating the model ----------------------------------------------------------------------------

		W  = zeros(N,2)                  # This is a "vector" to "record" state variables as the time goes by.
		(W, xs, xa, t) = evolve_model!(W, ps, pa, xs, xa, Ipeak, N, Δt, t, tstim, tstim_dur, tstimcon, tstimcon_dur, noise, noisevar, amp, freq)


		# Calculating the Peaks Time Position, Modding and Binning them -------------------------------------

		TimeOfPeaks = FindMax(W[:,1], W[:,2], -20.)
		TimeOfPeaksMod = mod(TimeOfPeaks, Per)
		nSom = GetThatHistBoy(TimeOfPeaksMod, Per, nSom, bins)

	end


	# Writing the Histogram Values to a Textfile -------------------------------------------------------

	nBins = Per/bins:Per/bins:Per
	nBins -= Per/bins
	writedlm("HistVal$(freq).txt", [nBins nSom])
	(FittedMean, FittedAmp, FittedPhase) = fit_hist(nBins, nSom, freq)

	MagArr[i, 1] = freq
	MagArr[i, 2] = FittedMean
	MagArr[i, 3] = FittedAmp
	MagArr[i, 4] = FittedPhase
end



writedlm("MagArray.txt", MagArr);

rmprocs(workers(), waitfor = 10)
print(workers())
