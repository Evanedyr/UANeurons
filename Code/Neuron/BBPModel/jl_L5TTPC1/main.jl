using PyCall
include("MyFunc.jl")
unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport MCMClass_c as Mcm2

initValues = readdlm("./Intersections.jl")
mode = 1
fRange1 = 10.^(linspace(-3, -2, 10))
fRange2 = 10.^(linspace(-2, -1, 20))
fRange3 = 10.^(linspace(-1, 0, 10))
shift!(fRange2)
shift!(fRange3)
fRange = [fRange1; fRange2; fRange3]
std = 1.
Mcm2.realmain(20, initValues, fRange, mode, std)
