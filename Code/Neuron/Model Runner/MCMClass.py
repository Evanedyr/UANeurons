#!/usr/bin/env python

from neuron import h, gui
from matplotlib import pyplot
import numpy
from math import sin, cos, pi


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
    stim = h.IClampNoiseSin(cell(loc))
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
    h_vec = h.Vector()
    i_inj_vec = h.Vector()
    n_vec = h.Vector()
    t_vec = h.Vector()
    soma_v_vec.record(cell.soma(0.5)._ref_v)
    h_vec.record(cell.soma(0.5).na._ref_h)
    i_inj_vec.record(stim._ref_i)
    n_vec.record(cell.soma(0.5).kv._ref_n)
    t_vec.record(h._ref_t)
    h.dt = dt
    h.tstop = simdur
    h.v_init = init
    h.celsius = cel
    h.run()
    return soma_v_vec, h_vec, i_inj_vec, n_vec, t_vec
