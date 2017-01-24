using PyCall
using PyPlot
include("/home/stefano/GIT_UANeurons/UANeurons/Code/Julia/CrunchCode/MyFunc.jl")
unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport MCMClass as Mcm

std = 0.;
currRange = 0.035:0.0025:0.06;  #looks like it may be in [mA] instead of [nA]
dt = 0.005
tau = 10. #22.5 # [ms] # 10.
mu = 0.
#MFR = SharedArray(Float64, (length(currRange), 3))
MFR = Array(Float64, length(currRange), 3)
for i=1:length(currRange)
  curr = currRange[i];
  delay = 0
  dur = 100     # [ms]
  soma_vec, i_inj_vec, t_vec = Mcm.main(curr, std, dt, tau, mu, delay, dur)
  peaktime = FindMax(soma_vec, t_vec, 0.)
  mfr = (length(peaktime)/(dur))*1000;
  MFR[i,1] = mfr;
  MFR[i,2] = curr;
  MFR[i,3] = std;
  figure(i)
  plot(t_vec, soma_vec)
end
writedlm("MFRPlot$(std)std.txt", MFR)
figure(100)
plot(MFR[:,2], MFR[:,1]);
rmprocs(workers(), waitfor = 10)
print(workers())
