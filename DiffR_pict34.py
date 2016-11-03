import neuron
from neuron import h, gui
import numpy
from math import sin, pi
import YuSimpleModel
import MyMethods
from matplotlib import pyplot

dt = 0.001
h.dt = dt
tend = 15.0
h.tstop = tend
h.celsius = 37

cell = YuSimpleModel.YuSimple()
cell.soma.insert('extracellular')
R = [1, 30, 150, 250]
color = ['blue', 'cyan', 'green', 'orange']
t_vect = h.Vector()
t_vect.record(h._ref_t)
v_vect = h.Vector()
v_vect.record(cell.axon(.5)._ref_v)
im_vect = h.Vector()
im_vect.record(cell.soma(.5)._ref_i_membrane)
plots = []
area = h.area(.6)
print(area)
for i in range(4):
	i_tot = list()
	i_vect = list()
	cell.soma.Ra = R[i]
	cell.axon.Ra = R[i]
	for j in range(-70,20):
		print(j)
		stim = MyMethods.myVClamp(cell.soma(0.5), 10, 10, 10, -80, j , -80)
		h.run()
		for k in range(len(im_vect)):
			i_vect.append(im_vect[k]*(area)/100)
			i_tot.append(min(i_vect))
	#plota = MyMethods.myPlot(t_vect,ina_vect, color[0], '-')
	plota = MyMethods.myPlot(range(-70,20),i_tot, color[1], '-')
	#plot = MyMethods.myPlot(range(-70,20),i_tot, color[i], '-')
	#plots.append(plot)
	pyplot.show()
	print('plot added')
	del i_tot, i_vect

#pyplot.legend(plots[0]+plots[1]+plots[2]+plots[3],['1 ohm*cm', '30 ohm*cm', '150 ohm*cm', '250 ohm*cm'])
#pyplot.ylabel('nA')
#pyplot.xlabel('mV')

