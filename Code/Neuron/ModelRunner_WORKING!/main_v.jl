addprocs(1)

using PyCall
using PyPlot
unshift!(PyVector(pyimport("sys")["path"]), "")
PyCall.@pyimport MCMClass_v as Mcm

@everywhere using PyCall
@everywhere using PyPlot
@everywhere include("/home/stefano/GIT_UANeurons/UANeurons/Code/Julia/CrunchCode/MyFunc.jl")
@everywhere unshift!(PyVector(pyimport("sys")["path"]), "")
@everywhere PyCall.@pyimport MCMClass_v as Mcm
# Additional test entries
@everywhere pyfun = Mcm.main
@everywhere function wrap_pyfun(curr, std, dt, tau, mu, delay, dur)
    return pyfun(curr, std, dt, tau, mu, delay, dur)
end

std = 0.;
currRange = 0.035:0.0025:0.06;  #looks like it may be in [mA] instead of [nA]
dt = 0.005
tau = 10. #22.5 # [ms] # 10.
mu = 0.
delay = 0
dur = 100
MFR = SharedArray(Float64, length(currRange), 3)
@sync @parallel for i=1:length(currRange)
  curr = currRange[i];   # [ms]
  soma_vec, i_inj_vec, t_vec = wrap_pyfun(curr, std, dt, tau, mu, delay, dur)
  peaktime = FindMax(soma_vec, t_vec, 0.)
  mfr = (length(peaktime)/(dur))*1000;
  MFR[i,1] = mfr;
  MFR[i,2] = curr;
  MFR[i,3] = std;
  # figure(i)
  # plot(t_vec, soma_vec)
end
writedlm("MFRPlot$(std)std.txt", MFR)
figure(100)
plot(MFR[:,2], MFR[:,1]);
rmprocs(workers(), waitfor = 10)
print(workers())
