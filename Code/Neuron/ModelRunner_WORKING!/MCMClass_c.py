#!/usr/bin/env python

from neuron import h, gui
from matplotlib import pyplot
import numpy
from math import sin, cos, pi

def init_simulation():
    """Initialise simulation environment"""

    h.load_file("stdrun.hoc")
    h.load_file("import3d.hoc")

    print("Loading constants")
    h.load_file('constants.hoc')


def create_cell(add_synapses=True):
    """Create the cell model"""
    # Load morphology
    h.load_file("morphology.hoc")
    # Load biophysics
    h.load_file("biophysics.hoc")
    # Load main cell template
    h.load_file("template.hoc")

    # Instantiate the cell from the template

    print("Loading cell dNAC222_L23_SBC_cf92e1b802")
    cell = h.dNAC222_L23_SBC_cf92e1b802(1 if add_synapses else 0)
	# print(type(cell))
    return cell

def attach_noise_sin_clamp(cell, delay, dur, offset, amp, freq, dt, tau, sigma, mu, loc):
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
    stim = h.IClampNoiseSin(cell.soma[0](loc))
    stim.delay = delay
    stim.dur = dur
    stim.std = sigma
    stim.offset = offset
    stim.amp = amp
    stim.freq = freq
    stim.dt = dt
    stim.tau = tau
    stim.mu = mu
    return stim

def special_run(stim, cell, simdur, dt, init, cel):
    soma_v_vec = h.Vector()
    i_inj_vec = h.Vector()
    t_vec = h.Vector()
    soma_v_vec.record(cell.soma(0.5)._ref_v)
    i_inj_vec.record(stim._ref_i)
    t_vec.record(h._ref_t)
    h.dt = dt
    h.tstop = simdur
    h.v_init = init
    h.celsius = cel
    h.run()
    return soma_v_vec, i_inj_vec, t_vec

def simulate(simdur, dt, init, cel):
    """Start the simulation
    :param simdur: The simulation duration
    :param dt: The time step
    :param init: The initiation voltage
    :param cel: The temperature of the simulationn."""
    h.dt = dt
    h.tstop = simdur
    h.v_init = init
    h.celsius = cel
    h.run()


def set_recording_vectors(stim, cell):
    """Creates the recording vectors in following order: soma, axon, injected current, t
    :param stim: The stimulated input to calculate the injected current
    :param soma: The soma that needs to be recorded
    :param axon: The axon that needs to be recorded"""
    soma_v_vec = h.Vector()
    axon_v_vec = h.Vector()
    i_inj_vec = h.Vector()
    t_vec = h.Vector()
    soma_v_vec.record(cell.soma[0](0.5)._ref_v)
    axon_v_vec.record(cell.axon[0](0.5)._ref_v)
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


def main():
    init_simulation()
    cell = create_cell(False)
    std = 0.;
    currRange = numpy.arange(0.038,.04,0.001);  #looks like it may be in [mA] instead of [nA]
    dt = 0.005
    tau = 10. #22.5 # [ms] # 10.
    mu = 0.
    totalcount = []
    stepi = []
    for i in currRange:
        curr = i
        counts = h.Vector()
        apc = h.APCount(cell.soma[0](0.5))
        apc.thresh = 10
        apc.record(counts)
        delay = 0
        dur = 100
        stim = attach_noise_sin_clamp(cell, delay, dur, curr, 0., 0., dt, tau, std, mu, 0.5)
        soma_vec, axon_vec, i_inj_vec, t_vec = set_recording_vectors(stim, cell)
        simulate(dur, dt, -70, 37)
        if len(counts) > 1:
            deltat = counts[-1]-counts[0]
            totalcount.append(((len(counts)) / deltat) * 1000)
            stepi.append(curr)
        else:
            totalcount.append(0)
            stepi.append(curr)
        pyplot.figure()
        pyplot.plot(t_vec, soma_vec)
    filename = 'FIVal' + str(0) + 'bis.txt'
    writetofile(filename, stepi, totalcount)
    pyplot.figure()
    pyplot.plot(stepi, totalcount)
