print("starting....")

addprocs(1)  # Number of processes
@everywhere include("MyFunc.jl")
@everywhere using StatsBase
@everywhere using LsqFit

####################### TIMING VARIABLES ###############################
const Δt = 0.005;      # integration time step [ms]
T  = 1000.;                  # Simulation lifetime [ms]
N  = Int64(floor(T/Δt));	# Corresponding number of steps
timema = []
tstim = 0.;
tstim_dur = 1_000_000.;
tstimcon = 0.
tstimcon_dur = 100.
timesim = (1:N)*Δt;      # This array of variables contains the "current time" [ms]
t  = 0.;

####################### INPUT VARIABLES ###############################
noise = 2# 0 = only DC, 1 = noisy DC, 2 = noisy sin
allcurr = []
#Ipeak = 1000.;			# Amplitude of the external injected (somatic) current [pA]
#amp = Ipeak * 0.1		# Amplitude of the sine term in the extrenal injected (somatic) current [pA]
#freq = .101			# Frequency of sine term in the external injected (somatic) current [kHz]

####################### MODEL VARIABLES ###############################
const Ra = 0.0045;      # In GOhm
const ps= Ps(60., -90., -80., 1./Ra, 250., 800., 2200., 12., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.);  # One variable of type "Ps" is created and initialised
const pa= Pa(60., -90., -80., 1./Ra,   5.,1200.,  800.,  0., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.);  # One variable of type "Pa" is created and initialised
xs = Xs(ps.Eleak, 0., 1., 0.);  # Let's declare a var of type "Xs" and initialise it
xa = Xa(pa.Eleak, 0., 1., 0.);  # Let's declare a var of type "Xa" and initialise it

####################### LOOP VARIABLES ###############################

mode = 1;     # choose between low MFR(1) and high MFR(2) regime
initValues = readdlm("Intersections.txt");
std = initValues[1,3];
Ipeak = initValues[1,mode];
amp = Ipeak * .1;
fRange1 = .001:.01:0.101	# Range of frequencies to be computed over
fRange2 = 0.111:.1: 1.001
fRange = [fRange1; fRange2];
pos_vect = SharedArray(Float64, (length(std),3))

####################### CODE ###############################

magnitudeArray = SharedArray(Float64, length(fRange), 2);

@sync @parallel for j=1:length(fRange)
  print("im here at round $(j)");
  noisevar = zeros(Float64, N);
  simulate_ou!(noisevar, N, 0., Δt, 0., std, 2.)
  W = zeros(N+Int64(tstim/Δt),2);
  freq = fRange[j];
  W, xs, xa, t = evolve_model!(W, ps, pa, xs, xa, Ipeak, N+Int64(tstim/Δt), Δt, t, tstim, tstim_dur, tstimcon, tstimcon_dur, noise, noisevar, amp, fRange[j])
  #rng = 1:length(fRange)
  xvalues = zeros(33,1);
  yvalues = zeros(33,1);
  W  = zeros(N,2);
  while maximum(yvalues)<100
    simulate_ou!(noisevar, N, noisevar[end], Δt, 0., std, 2.)
    W, xs, xa, t = evolve_model!(W, ps, pa, xs, xa, Ipeak, N, Δt, t, 0., tstim_dur, tstimcon, tstimcon_dur, noise, noisevar, amp, freq)
    data = W[:,1];
    time = W[:,2]-3000.;
    #peaks = FindMax(W[:, 1], timesim[:], -20.)
    peaks = findpeaks(data);#.*Δt;
    xvalues, yvalues = DefinitelyNotAnHist(length(data), peaks, xvalues, yvalues)
    print(yvalues)
  end
  magnitudeArray[j, 1] = fit_hist(xvalues, yvalues, freq);
  magnitudeArray[j, 2] = freq;
end
writedlm("MagArray.txt", magnitudeArray);
rmprocs(workers(), waitfor = 10)
print(workers())
