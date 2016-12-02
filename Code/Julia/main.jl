addprocs(10)  # Number of processes

@everywhere include("MyFunc.jl")
# @everywhere using LsqFit
# @everywhere using PyPlot




const Δt = 0.005;      # integration time step [ms]

# evolve_model Variables ------------------------------------
T  = 500_000.;                  # Simulation lifetime [ms]
N  = Int64(floor(T/Δt));          # Corresponding number of steps
noise = 1                         # If there is noise in the input current, 0 for DC current, 1 for noisy DC current, 2 for noise sine
timema = []
allcurr = []
Ipeak = 1000.;                     # Amplitude of the external injected (somatic) current [pA]
amp = Ipeak * 0.1                  # Amplitude of the sine term in the extrenal injected (somatic) current [pA]
freq = .101                         # Frequency of sine term in the external injected (somatic) current [kHz]
# noisevar = Noisevar(0., Δt, 0., Ipeak/3, 10.)
# freq = 1.001
tstim = 0.;
tstim_dur = 1_000_000.;
tstimcon = 0.
tstimcon_dur = 100.


timesim = (1:N)*Δt;      # This array of variables contains the "current time" [ms]
# freq1 = 0.001:0.001:0.101
# freq2 = 0.111:0.01:1.001
# freq = [freq1; freq2]

const Ra = 0.0045;      # In GOhm
const ps= Ps(60., -90., -80., 1./Ra, 250., 800., 2200., 12., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.);  # One variable of type "Ps" is created and initialised
const pa= Pa(60., -90., -80., 1./Ra,   5.,1200.,  800.,  0., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.);  # One variable of type "Pa" is created and initialised

std = 0.:100.:1000.
curr = -200.:1.:200.
# Initializing vector to keep fitted values in ----------------------------

# freqvec = []
# alloffset = []
# allamp = []
# allphase = []
# allval = SharedArray(Float64, (length(curr), 2))
# For loop over different input frequencies -----------------------------------
@sync @parallel for j=1:length(std)
	jj = std[j]
	noisevar = zeros(Float64, N)
	noisevar = simulate_ou!(noisevar, N, 0., Δt, 0., jj, 2.)   # Starting value, time step, Steady-state mean, Steady-state standard deviation, relaxation time
	allval = zeros(Float64, (length(curr),2))
	for i=1:length(curr)
	  ii = curr[i]
	  allval[i, 1] = ii
	  W  = zeros(N,3);                  # This is a "vector" to "record" state variables as the time goes by.

	  xs = Xs(ps.Eleak, 0., 1., 0.);  # Let's declare a var of type "Xs" and initialise it
	  xa = Xa(pa.Eleak, 0., 1., 0.);  # Let's declare a var of type "Xa" and initialise it

	  t  = 0.;              # actual running time [ms]
	  (t, xs, xa) = evolve_model!(W, ps, pa, xs, xa, ii, N, Δt, t, tstim, tstim_dur, tstimcon, tstimcon_dur, noise, noisevar, amp, freq, false, "test.txt");

	  peaktime = FindMax(W[:, 1], timesim[:], -20.)
	  # peakmodtime = mod(peaktime, 2.*1./ii)
	  # peakmodtime = mod(peaktime, 1./freq)
	  # writedlm("testje.txt", peakmodtime)

	  # figure(87)
	  # (nsom, bins, patches)=plt[:hist](peakmodtime, 33)
	  # @time (nsom, bins) = GetThatHistBoy(peakmodtime)
	  # print(length(nsom))
	  # splice!(bins, 1)
	  # print(length(bins))
	  # model(xval, par) = par[1] + par[2] * sin((i .* 2 .* π .* xval) + par[3])
	  # fit = curve_fit(model, bins, nsom, [mean(nsom), (maximum(nsom)-minimum(nsom))/2., 0])

	  allval[i, 2] = (1000.*length(peaktime))/T


	  # push!(alloffset, fit.param[1])
	  # push!(allamp, abs(fit.param[2]/Ipeak))
	  # push!(allphase, fit.param[3])
	  # writedlm("./histstau10/histval$(freq).txt", [bins nsom])


	  # print(freq)
	end
	writedlm("FIStd$(jj).txt", allval)
end

rmprocs(workers(), waitfor = 10)
print(workers())
