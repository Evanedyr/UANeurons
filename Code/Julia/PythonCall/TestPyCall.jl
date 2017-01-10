using PyCall
using PyPlot
include("MyFunc.jl")
unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport MCMClass as Mcm

soma, axon = Mcm.create_sec("soma", "axon")
Mcm.define_geometry(soma, 30, 20, 5)
Mcm.define_geometry(axon, 50, 1, 11)
Mcm.build_topology_axso(axon, soma, 0)
Mcm.define_biophysics(2, soma, 800, 320, 1/30000, 0.75, 150, -70, 60, -80)
Mcm.define_biophysics(2, axon, 8000, 1600, 1/30000, 0.75*0.75, 150, -70, 60, -80)
curr = 0.025:0.00005:0.035
stand = 0:0.01:0
dt = 0.005
tau = 10
mu = 0
for j in stand
    counter = 0
    totalcount = []
    stepi = []
    for i in curr
				soma, axon = Mcm.create_sec("soma", "axon")
				Mcm.define_geometry(soma, 30, 20, 5)
				Mcm.define_geometry(axon, 50, 1, 11)
				Mcm.build_topology_axso(axon, soma, 0)
				Mcm.define_biophysics(2, soma, 800, 320, 1/30000, 0.75, 150, -70, 60, -80)
				Mcm.define_biophysics(2, axon, 8000, 1600, 1/30000, 0.75*0.75, 150, -70, 60, -80)
        delay = 0
        dur = 100000
        stim = Mcm.attach_noise_clamp(soma, delay, dur, j, mu, tau, i, dt, 0.5)
        soma_vec, axon_vec, i_inj_vec, i_cap_vec, t_vec = Mcm.special_run(stim, soma, axon, dur, dt, -70, 37)
				peaktime = FindMax(soma_vec, t_vec, 0.)

        if length(peaktime) > 1
					push!(totalcount, (length(peaktime)/(peaktime[end]-peaktime[1])) * 1000)
        else
          push!(totalcount, 0)
				end
        push!(stepi, i)
        print("$(length(peaktime)), $(counter), $(i), $(t_vec[end])")
        counter += 1
		end
    filename = "FIVal$(j).txt"
		writedlm("test.txt", [totalcount stepi])
end
