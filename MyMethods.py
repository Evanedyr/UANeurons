import neuron
from neuron import h
from matplotlib import pyplot

def myVClamp(loc, d0, d1, d2, a0, a1, a2):
	stim = h.VClamp(loc)
	stim.dur[0]=d0
	stim.dur[1]=d1
	stim.dur[2]=d2
	stim.amp[0]=a0
	stim.amp[1]=a1
	stim.amp[2]=a2
	return stim
	
def mySinClamp(loc, amp, freq, delay, dur):
	stim = h.SinClamp(loc)
	stim.pkamp = amp
	stim.freq = freq
	stim.delay = delay
	stim.dur = dur
	return stim
	
def myNoiseClamp(loc, amp0, amp1, freq, delay, dur):
	stim = h.IClampNoise(loc)
	stim.f0 = amp0
	stim.f1 = amp1
	stim.f = freq
	stim.delay = delay
	stim.dur = dur
	return stim

def myIClamp(loc, delay, d, a):
	stim = h.IClamp(loc)
	stim.delay = delay
	stim.dur = d
	stim.amp = a
	return stim
	
def myRampClamp(loc, delay, dur, iamp, famp):
	stim = h.RampClamp(loc)
	stim.delay = delay
	stim.dur = dur
	stim.iamp = iamp
	stim.famp = famp
	return stim

def myVector(loc, pos, dim):
	vect=h.Vector()
	if dim=='v':
		vect.record(loc(pos)._ref_v)
	elif dim=='c':
		vect.record(loc(pos).pas._ref_i)
	return vect

def myPlot(vx,vy, Color='black', style='_'):
	plot=pyplot.plot(vx, vy, color=Color, linestyle=style)
	return plot
