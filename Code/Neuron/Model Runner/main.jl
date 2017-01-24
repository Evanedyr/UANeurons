addprocs(1)

@everywhere using PyCall
@everywhere using PyPlot
@everywhere include("/home/stefano/GIT_UANeurons/UANeurons/Code/Julia/CrunchCode/MyFunc.jl")
unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport MCMClass as Mcm


Mcm.create_cell(false)
std = 0.;
currRange = .02:.001/2.:.021;  #looks like it may be in [mA] instead of [nA]
dt = 0.005
tau = 10. #22.5 # [ms] # 10.
mu = 0.
MFR = SharedArray(Float64, (length(currRange), 3))
for i=1:length(currRange)
  curr = currRange[i];
  delay = 0
  dur = 1000     # [ms]
  stim = Mcm.attach_noise_sin_clamp(soma, delay, dur, curr, 0., 0., dt, tau, std, mu, 0.5)
  soma_vec, axon_vec, i_inj_vec, i_cap_vec, t_vec = Mcm.special_run(stim, soma, axon, dur, dt, -70, 37)
  peaktime = FindMax(soma_vec, t_vec, 0.)
  mfr = (length(peaktime)/(dur))*1000;
  MFR[i,1] = mfr;
  MFR[i,2] = curr;
  MFR[i,3] = stand;
  figure(i)
  plot(t_vec, soma_vec)
end
writedlm("MFRPlot$(stand)std.txt", MFR)
figure(100)
plot(MFR[:,2], MFR[:,1]);
rmprocs(workers(), waitfor = 10)
print(workers())
