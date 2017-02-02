using PyCall
using PyPlot
include("MyFunc.jl")
unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport MCMClass as Mcm

Mcm.main()
