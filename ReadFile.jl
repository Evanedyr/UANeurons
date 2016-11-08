
V = readdlm("/home/christophe/Documents/Git/PhD/ModelsMarie/test.txt")

print(size(V))
using PyPlot
plot(V[:,1],V[:,2])

##### Python conductancetime = numpy.array(t_vec)

# somavolt = numpy.array(soma_vec)
# filename = 'test.txt'
# numpy.savetxt(filename, numpy.transpose(numpy.vstack((time, somavolt))))
