init_time = time();

using PyCall
unshift!(PyVector(pyimport("sys")["path"]), "")
PyCall.@pyimport MCMClass_v as Mcm
include("MyFunc.jl")

pyfun = Mcm.main
function wrap_pyfun(Ipeak, amp, fRange, stdRange, dt, tau, mu, delay, dur)
    return pyfun(Ipeak, amp, fRange, stdRange, dt, tau, mu, delay, dur)
end

#wrap_pyfun(0., 0., 0., .0, 0.005, 0., 0., 0, 10)
#nbins = 50.
#fRange1 = 0.001:(.01-.001)/nbins:0.009
#fRange2 = 0.01:(.1-.01)/nbins:0.09
#fRange3 = 0.1:(1.-.1)/nbins:1.
#fRange = [fRange1; fRange2; fRange3];
fRange = [0.00; 0.00]
#initValues = readdlm("/home/stefano/Workspace/jl_NrnL5_NBC_cNAC187_1/Intersections.jl")
amp = 0.#.35*5.0;
dt = 0.005;
tau = 10.; #22.5 # [ms] # 10.
mu = 0.;
delay = 0;
dur = 500.;
std = 0.0#[initValues[3,3]; initValues[3,3]];
Ipeak = -2.:0.5:5.0#[initValues[3,1]; initValues[3,1]];
wrap_pyfun(Ipeak, amp, fRange, std, dt, tau, mu, delay, dur)
print(time() - init_time)
# writedlm("OUTPUT/parameters.jl", "Ra=default")
