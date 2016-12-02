addprocs(10)  # Number of processes
@everywhere include("MyFunc.jl")

####################### TIMING VARIABLES ###############################
const Δt = 0.005;      # integration time step [ms]
T  = 500_000.;                  # Simulation lifetime [ms]
N  = Int64(floor(T/Δt));	# Corresponding number of steps		
timema = []
tstim = 0.;
tstim_dur = 1_000_000.;
tstimcon = 0.
tstimcon_dur = 100.
timesim = (1:N)*Δt;      # This array of variables contains the "current time" [ms]
t  = 0.;

####################### INPUT VARIABLES ###############################
noise = 1# 0 = only DC, 1 = noisy DC, 2 = noisy sin
allcurr = []
Ipeak = 1000.;			# Amplitude of the external injected (somatic) current [pA]
amp = Ipeak * 0.1		# Amplitude of the sine term in the extrenal injected (somatic) current [pA]
freq = .101			# Frequency of sine term in the external injected (somatic) current [kHz]

####################### MODEL VARIABLES ###############################
const Ra = 0.0045;      # In GOhm
const ps= Ps(60., -90., -80., 1./Ra, 250., 800., 2200., 12., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.);  # One variable of type "Ps" is created and initialised
const pa= Pa(60., -90., -80., 1./Ra,   5.,1200.,  800.,  0., -25., -35., -15., 6., 6., 4., 0.1, 0.5, 2.);  # One variable of type "Pa" is created and initialised
xs = Xs(ps.Eleak, 0., 1., 0.);  # Let's declare a var of type "Xs" and initialise it
xa = Xa(pa.Eleak, 0., 1., 0.);  # Let's declare a var of type "Xa" and initialise it

####################### LOOP VARIABLES ###############################
std = 0.:100.:1000.
curr = -200.:1.:200.

####################### CODE ###############################
@sync @parallel for j=1:length(std)
  jj = std[j]
  noisevar = zeros(Float64, N)
# Starting value, time step, Steady-state mean, Steady-state standard deviation, relaxation time
  noisevar = simulate_ou!(noisevar, N, 0., Δt, 0., jj, 2.)   
  allval = zeros(Float64, (length(curr),2))
  for i=1:length(curr)
    ii = curr[i]
    allval[i, 1] = ii
    W  = zeros(N,3);                # This is a "vector" to "record" state variables as the time goes by.
    evolve_model!(W, ps, pa, xs, xa, ii, N, Δt, t, tstim, tstim_dur, tstimcon, tstimcon_dur, noise, noisevar, amp, freq);
    peaktime = FindMax(W[:, 1], timesim[:], -20.)
    allval[i, 2] = (1000.*length(peaktime))/T
  end
  writedlm("FIStd$(jj).txt", allval)
end

rmprocs(workers(), waitfor = 10)
print(workers())
