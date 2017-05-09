using PyCall


include("MyFunc.jl")
unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport MCMClass_c as Mcm2

initValues = readdlm("./Intersectionsonesom0.003.jl")
# stdRange = initValues[:, 3]
# stdRange2 = 0.01:0.09:0.1
mode = 1
nbins = 30
fRange1 = 10.^(linspace(-3, -2, 10))
fRange2 = 10.^(linspace(-2, -1, 20))
fRange3 = 10.^(linspace(-1, 0, 10))
shift!(fRange2)
shift!(fRange3)
fRange = [fRange1; fRange2; fRange3]
Mcm2.realmain(20, initValues, fRange, mode)
# A = readdlm("testFI.txt")
# allpos = []
# allpos2 = []
# for i = 1:size(A)[2]-1
# 	data = Array{Float64}(size(A)[1],2)
# 	data[:,1] = A[:,1]
# 	data[:,2] = A[:,i+1]
# 	(pos, a) = findIntersect(data, 5)
# 	(pos2, a) = findIntersect(data, 20)
# 	push!(allpos, pos)
# 	push!(allpos2, pos2)
# end
# B = Array{Float64}(3,4)
# B[:, 1] = allpos
# B[:, 2] = allpos2
# B[:, 3] = 0.03
# B[:, 4] = 0.0:0.3:0.6
# writedlm("Intersections.jl", B)
