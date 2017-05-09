#!/usr/bin/env python

from neuron import h, gui
from matplotlib import pyplot
import numpy
from math import sin, cos, pi


def create_sec(*arg):
    """Create the sections of the cell."""
    temp=[]
    for i in range(0, len(arg)):
        temp.append(h.Section(name=arg[i]))
    return [test for test in temp]


def build_topology_axso(axon, soma, loc):
    """Connect the sections of the cell to build a tree."""
    axon.connect(soma(loc))


def define_geometry(cell, l, diam, seg):
    """Set the 3D geometry of the cell.
    :param cell: The cell you want to set the parameters on
    :param l: The length of the cell
    :param diam: The diameter of the cell
    :param seg: The amount of segments in the cell"""
    cell.L = l
    cell.diam = diam
    cell.nseg = seg


def show_cell_geometry():
    """Shows the 3D cell morphology"""
    h.define_shape()
    shape_window = h.PlotShape()
    shape_window.exec_menu('Show Diam')


def define_biophysics(*arg):
    """Defines the biophysics of the cell, if the first argument is 1 an hh model, if 2 an adapted version of HH
     in accordance with Yu et all will be applied with following parameters:
    2st argument: cell
    3rd argument: Sodium conductance            (in S/cm^2)
    4th argument: Potassium conductance         (in S/cm^2)
    5th argument: Leak conductance              (in S/cm^2)
    6th argument: Membrane Capacitance          (in uF/cm^2)
    7th argument: Axial resistance              (in Ohm*cm)
    8th argument: Reversal potential leak       (in mV)
    9th argument: Reversal potential Sodium     (in mV)
    10th argument: Reversal potential Potassium (in mV)"""
    if arg[0] == 1:
        arg[1].insert('hh')
        arg[1].gnabar_hh = arg[2]
        arg[1].gkbar_hh = arg[3]
        arg[1].gl_hh = arg[4]
        arg[1].cm = arg[5]
        arg[1].Ra = arg[6]
        arg[1].el_hh = arg[7]
        arg[1].ena = arg[8]
        arg[1].ek = arg[9]
    if arg[0 == 2]:
        arg[1].insert('pas')
        arg[1].insert('na')
        arg[1].insert('kv')
        arg[1].gbar_na = arg[2]
        arg[1].gbar_kv = arg[3]
        arg[1].g_pas = arg[4]
        arg[1].cm = arg[5]
        arg[1].Ra = arg[6]
        arg[1].e_pas = arg[7]
        arg[1].ena = arg[8]
        arg[1].ek = arg[9]
    h.psection(sec=arg[1])


def set_recording_vectors(stim, soma, axon):
    """Creates the recording vectors in following order: soma, axon, injected current, t
    :param stim: The stimulated input to calculate the injected current
    :param soma: The soma that needs to be recorded
    :param axon: The axon that needs to be recorded"""
    soma_v_vec = h.Vector()
    axon_v_vec = h.Vector()
    i_inj_vec = h.Vector()
    i_cap_vec = h.Vector()
    t_vec = h.Vector()
    soma_v_vec.record(soma(0.5)._ref_v)
    axon_v_vec.record(axon(0.5)._ref_v)
    i_inj_vec.record(stim._ref_i)
    i_cap_vec.record(soma(0.5)._ref_i_cap)
    t_vec.record(h._ref_t)
    return soma_v_vec, axon_v_vec, i_inj_vec, i_cap_vec, t_vec


def attach_current_clamp(cell, delay, dur, amp, loc):
    """Attach a current Clamp to a cell.

    :param cell: Cell object to attach the current clamp.
    :param delay: Onset of the injected current.
    :param dur: Duration of the stimulus.
    :param amp: Magnitude of the current.
    :param loc: Location on the dendrite where the stimulus is placed.
    """
    stim = h.IClamp(cell(loc))
    stim.delay = delay
    stim.dur = dur
    stim.amp = amp
    return stim


def attach_rampcurrent_clamp(cell, delay, dur, stinc, endinc, loc):
    """Attach a ramp current Clamp to a cell.

    :param cell: Cell object to attach the current clamp.
    :param delay: Onset of the injected current.
    :param dur: Duration of the stimulus.
    :param stinc: Start of the incline.
    :param endinc: End of the incline.
    :param loc: Location on the dendrite where the stimulus is placed.
    """
    stim = h.IClampRamp(cell(loc))
    stim.delay = delay
    stim.dur = dur
    stim.startincline = stinc
    stim.endincline = endinc
    return stim


def attach_voltage_clamp(cell, dur1, dur2, dur3, amp1, amp2, amp3, loc):
    stim = h.VClamp(cell(loc))
    stim.dur[0] = dur1
    stim.dur[1] = dur2
    stim.dur[2] = dur3
    stim.amp[0] = amp1
    stim.amp[1] = amp2
    stim.amp[2] = amp3
    return stim


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


def calc_dvdt(soma_vec, t_vec):
    """Calculate dV/dt"""
    dvdt = numpy.concatenate((numpy.array([0]), numpy.diff(soma_vec) / numpy.diff(t_vec)))
    return dvdt


def plot(somavec, somavec0, axonvec, dvdtvec, dvdtvec0, tvec, range1, range2, comprange=False):
    """Plotting the results"""
    fig = pyplot.figure()
    ax1 = fig.add_subplot(2, 1, 1)
    ax2 = fig.add_subplot(2, 1, 2)
    soma_plot = ax1.plot(tvec, somavec, color='orange')
    soma0_plot = ax1.plot(tvec, somavec0, color='orange', linestyle=':')
    axon_plot = ax1.plot(tvec, axonvec, color='blue')
    dvdt_plot = ax2.plot(somavec, dvdtvec, color='red')
    dvdt0_plot = ax2.plot(somavec0, dvdtvec0, color='blue', linestyle=':')
    ax1.set_xlabel('time (ms)')
    ax1.set_ylabel('mV')
    ax2.set_ylabel('dV/dt (mV/ms)')
    ax2.set_xlabel('mV')
    ax1.legend(soma_plot + soma0_plot + axon_plot, ['soma ($g_{Na}$ = 0.8)', 'soma ($g{_Na}$ = 0)', 'axon'])
    ax2.legend(dvdt_plot + dvdt0_plot, ['$g_{Na}$ = 0.8', '$g_{Na}$ = 0'], loc=2)
    if comprange:
        ax1.axis([range1, range2, -90, 70])
    pyplot.show()


def plot2(somavec, axonvec, dvdtvec, tvec, range1, range2, comprange=False):
    """Plotting the results"""
    fig = pyplot.figure()
    ax1 = fig.add_subplot(2, 1, 1)
    ax2 = fig.add_subplot(2, 1, 2)
    soma_plot = ax1.plot(tvec, somavec, color='orange')
    axon_plot = ax1.plot(tvec, axonvec, color='blue')
    dvdt_plot = ax2.plot(somavec, dvdtvec, color='red')
    ax1.set_xlabel('time (ms)')
    ax1.set_ylabel('mV')
    ax2.set_ylabel('dV/dt (mV/ms)')
    ax2.set_xlabel('mV')
    ax1.legend(soma_plot + axon_plot, ['soma ($g_{Na}$ = 0.8)', 'axon'])
    ax2.legend(dvdt_plot, ['$g_{Na}$ = 0.8'], loc=2)
    if comprange:
        ax1.axis([range1, range2, -90, 70])
    pyplot.show()


def plotcurrent(i, t):
    pyplot.figure()
    pyplot.plot(t, i)
    pyplot.xlabel('Time (in ms)')
    pyplot.ylabel('Injected current (in nA)')
    pyplot.show()


def writetofile(*arg):
    filename = arg[0]
    temparray = numpy.zeros((len(arg[1]), len(arg)-1))
    maxlength = len(arg)-1
    for i in range(maxlength):
        temp = numpy.array(arg[i + 1])
        temparray[:, i] = temp
    numpy.savetxt(filename, temparray)


def attach_noise_sin_clamp(som, delay, dur, offset, amp, freq, dt, tau, sigma, mu, loc, seed):
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
    stim = h.IClampNoiseSin(som(loc))
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
