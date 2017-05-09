#!/usr/bin/env python

import MCMClass as Mcm
from neuron import h, gui
import numpy
from math import sin, cos, pi

soma, axon = Mcm.create_sec('soma', 'axon')
Mcm.define_geometry(soma, 30, 20, 5)
Mcm.define_geometry(axon, 50, 1, 11)
Mcm.build_topology_axso(axon, soma, 0)
# Mcm.define_biophysics(2, soma, 800, 320, 1/30000, 0.75, 150, -70, 60, -80)
# Mcm.define_biophysics(2, axon, 8000, 1600, 1/30000, 0.75*0.75, 150, -70, 60, -80)
# Mcm.define_biophysics(2, soma, 250, 400, 1/30000, 0.75, 150, -70, 60, -80)
# Mcm.define_biophysics(2, axon, 8000, 1600, 1/30000, 0.75*0.75, 150, -70, 60, -80)

T = 10000.
step = 0.002
startcur = -.05
num_steps = 100
counter = 0
test = h.Vector()

delay = 0
dur = T
amp = 0
freq = 0
dt = 0.005
tau = 10
mu = 0
loc = 0.5
seed = 1
distRange = numpy.arange(0, 0.9, 0.3)
con = 1
stdcounts = numpy.zeros(shape=(num_steps, len(distRange)+1))
for distSAIS in distRange:
    std = 0.03
    Mcm.define_biophysics(2, soma, 800, 320, 1 / 30000, 0.75, 150, -70, 60, -80)
    Mcm.define_biophysics(2, axon, 0, 1600, 1 / 30000, 0.75 * 0.75, 150, -70, 60, -80)
    axon(distSAIS).gbar_na = 8000 * 15
    totalcount = []
    stepi = []
    counter = 0
    for i in range(0, num_steps):
        counts = h.Vector()
        apc = h.APCount(soma(0.5))
        apc.thresh = 0
        apc.record(counts)
        offset = startcur + (step * i)
        # stim = Mcm.attach_current_clamp(soma, 1, 1000, startcur + (step * i), 0.5)
        stim = Mcm.attach_noise_sin_clamp(soma, delay, dur, offset, amp, freq, dt, tau, std, mu, loc, seed)
        soma_vec, axon_vec, i_inj_vec, i_cap_vec, t_vec = Mcm.set_recording_vectors(stim, soma, axon)
        icap = h.Vector()
        icap.record(soma(.5)._ref_i_cap)
        Mcm.simulate(T, 0.005, -70, 37)
        # dvdt_vec = Mcm.calc_dvdt(soma_vec, t_vec)
        # fig = pyplot.figure()
        # ax1 = fig.add_subplot(2, 1, 1)
        # ax2 = fig.add_subplot(2, 1, 2)
        # ax1.plot(t_vec, soma_vec)
        # ax2.plot(t_vec, i_inj_vec)
        # pyplot.show()
        # for x in range(1, len(counts)):
        #     test.append(counts[x]-counts[x-1])
        if len(counts) > 1:
            deltat = counts[-1]-counts[0]
            totalcount.append(((len(counts)) / deltat) * 1000)
        else:
            totalcount.append(0)
        stepi.append(startcur + (step * i))
        print(len(counts), counter, startcur + (step * i))
        counter += 1
        # if counter == num_steps:
        #     fig = pyplot.figure()
        #     pyplot.plot(t_vec, soma_vec, color='orange')
        #     pyplot.plot(t_vec, axon_vec, color='blue')
        #     fig2 = pyplot.figure()
        #     pyplot.plot(t_vec, i_inj_vec, color='purple')
        #     pyplot.show()
    stdcounts[:, con] = totalcount
    con += 1
stdcounts[:, 0] = stepi
# for i in range(0, len(test)):
#     print(test[i])
newcoun = 1
pyplot.figure(1)
for l in distRange:
    pyplot.plot(stdcounts[:, 0], stdcounts[:, newcoun])
    newcoun += 1
pyplot.xlabel('Input current (in nA)')
pyplot.ylabel('Frequency (in Hz)')
pyplot.show()
numpy.savetxt('testFI.txt', stdcounts)
