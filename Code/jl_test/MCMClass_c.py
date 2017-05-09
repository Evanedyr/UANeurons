#!/usr/bin/env python

from neuron import h, gui
import numpy
from math import sin, cos, pi
import multiprocessing
import itertools as it
import time
import MCMClass as Mcm


def attach_noise_sin_clamp(soma, delay, dur, offset, amp, freq, dt, tau, sigma, mu, loc, seed):
    """Attach a sinusoidal current Clamp to a cell.

    :param cell: Cell object to attach the current clamp.
    :param delay: Onset of the injected current.
    :param dur: Duration of the stimulus.
    :param offset: Offset of the sine.
    :param amp: The amplitude of the sine.
    :param freq: The frequency of the sine.
    :param sigma: The standard deviation of the normrand.
    :param loc: Location on the dendrite where the stimulus is placed.
    """
    stim = h.IClampNoiseSin(soma(loc))
    stim.delay = delay
    stim.dur = dur
    stim.std = sigma
    stim.offset = offset
    stim.amp = amp
    stim.freq = freq
    stim.dt = dt
    stim.tau = tau
    stim.mu = mu
    stim.new_seed = seed
    return stim


def set_recording_vectors(stim, soma, axon):
    """Creates the recording vectors in following order: soma, axon, injected current, t
    :param stim: The stimulated input to calculate the injected current
    :param soma: The soma that needs to be recorded
    :param axon: The axon that needs to be recorded"""
    soma_v_vec = h.Vector()
    axon_v_vec = h.Vector()
    i_inj_vec = h.Vector()
    t_vec = h.Vector()
    soma_v_vec.record(soma(0.5)._ref_v)
    axon_v_vec.record(axon(0.5)._ref_v)
    i_inj_vec.record(stim._ref_i)
    t_vec.record(h._ref_t)
    return soma_v_vec, axon_v_vec, i_inj_vec, t_vec


def writetofile(*arg):
    filename = arg[0]
    temparray = numpy.zeros((len(arg[1]), len(arg)-1))
    maxlength = len(arg)-1
    for i in range(maxlength):
        temp = numpy.array(arg[i + 1])
        temparray[:, i] = temp
    numpy.savetxt(filename, temparray)


def simulatepar(delay, dur, Ra, std, offset, amp, freq, dt, tau, mu, loc, simdur, init, cel, seed, loop):
    soma, axon = Mcm.create_sec('soma', 'axon')
    Mcm.define_geometry(soma, 30, 20, 5)
    Mcm.define_geometry(axon, 50, 1, 11)
    Mcm.build_topology_axso(axon, soma, 0)
    Mcm.define_biophysics(2, soma, 250, 400, 0.3e-3, .75, 150, -65, 55, -70, -25., 6., -35., 6., -15., 4.)
    Mcm.define_biophysics(2, axon, 250, 500, 0.3e-3, .75*0.75, 150, -65, 55, -70, -25., 6., -35., 6., -15., 4.)

    axon(Ra).gbar_na = 1000*15
    counts = h.Vector()
    apc = h.APCount(soma(0.5))
    apc.thresh = -15
    apc.record(counts)
    stim = attach_noise_sin_clamp(soma, delay, dur, offset, amp, freq, dt, tau, std, mu, loc, seed)
    soma_vec, axon_vec, i_inj_vec, t_vec = set_recording_vectors(stim, soma, axon)
    h.dt = dt
    h.tstop = simdur
    h.v_init = init
    h.celsius = cel
    h.run()
    filename = './OUTPUT/spiketrain5Hzmfr' + str(Ra) + 'Ra' + str(freq) + 'freq' + str(std) + 'std' + str(seed) + 'seed' + str(loop) + 'loop.txt'
    writetofile(filename, soma_vec)
    return 0


def simulatepar_one_arg(a):
    return simulatepar(*a)


def realmain(numprocs, initval, freq, mode):
    p = multiprocessing.Pool(processes=numprocs)
    dt = 0.005
    tau = 10.
    mu = 0.
    loc = 0.5
    simdur = 50000.
    cel = 37
    init = -65
    val = 0
    distSAIS = numpy.arange(0.0, 1.0, 1.3)
    std = 0.003
    looplength = numpy.arange(1, 2, 1)
    seedstart = 0
    beginseedstart = 0
    sfr = mode-1
    for Ra in distSAIS:
        for loopi in looplength:
            beginseedstart += 1
            amp = 0.36*std
            curr = initval[val, sfr]
            delay = 0
            dur = simdur
            seedrange = numpy.arange(seedstart, beginseedstart*len(freq), 1)
            q = p.map_async(simulatepar_one_arg, zip(it.repeat(delay), it.repeat(dur), it.repeat(Ra), it.repeat(std), it.repeat(curr), it.repeat(amp), freq, it.repeat(dt), it.repeat(tau), it.repeat(mu), it.repeat(loc), it.repeat(simdur), it.repeat(init), it.repeat(cel), seedrange, it.repeat(loopi)))
            while not q.ready():
               time.sleep(1)
            seedstart += len(freq)
        val += 1
