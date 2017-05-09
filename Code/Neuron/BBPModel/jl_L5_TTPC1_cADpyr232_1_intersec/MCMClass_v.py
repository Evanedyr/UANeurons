#!/usr/bin/env python

from neuron import h#, gui
#from matplotlib import pyplot
import numpy, time
#from math import sin, cos, pi
import run
from multiprocessing import Pool

def init_simulation():
    """Initialise simulation environment"""

    h.load_file("stdrun.hoc")
    h.load_file("import3d.hoc")

    print('Loading constants')
    h.load_file('constants.hoc')

def create_cell(add_synapses=True):
    """Create the cell model"""
    # Load morphology
    h.load_file("morphology.hoc")
    # Load biophysics
    h.load_file("biophysics.hoc")
    # Load main cell template
    h.load_file("template.hoc")

#    Instantiate the cell from the template

    print("Loading cell dNAC222_L23_SBC_cf92e1b802")
    cell = h.dNAC222_L23_SBC_cf92e1b802(1 if add_synapses else 0)
    return cell

def attach_noise_sin_clamp(cell, delay, dur, offset, amp, freq, dt, tau, sigma, mu, loc, noiseseed):
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
    stim.new_seed = noiseseed
    return stim

def special_run(stim, cell, simdur, dt, init, cel):
    soma_v_vec = h.Vector()
    t_vec = h.Vector()
    soma_v_vec.record(cell.soma[0](0.5)._ref_v)
    t_vec.record(h._ref_t)
    apc = h.APCount(cell.soma[0](0.5)) #####
    spikes = h.Vector()     ########
    apc.thresh = 0          ####
    apc.record(spikes)      ######
    h.dt = dt
    h.tstop = simdur
    h.v_init = init
    h.celsius = cel
    h.run()
    # soma_v_vec.resize(0)
    # t_vec.resize(0)
    # spikes.resize(0)
    # h.continuerun(10001.)
    return soma_v_vec; #spikes;

def alltogethernow(dist, count, delay, dur, offset, amp, freq, dt, tau, std, mu):
    cell = run.create_cell(False)
    stim = attach_noise_sin_clamp(cell, delay, dur, offset, amp, freq, dt, tau, std, mu, 0.5, count)
    # cell.axon[1].gNaTa_tbar_NaTa_t = 0.
    # cell.axon[0].gNaTa_tbar_NaTa_t = 0.
    # Ra = 3.137968*20. # default value = 3.137968
    # cell.axon[1](dist).gNaTa_tbar_NaTa_t = Ra
    spikes = special_run(stim, cell, dur, dt, -70, 34)
    filename = "OUTPUT/test.txt";
    f = open(filename, 'w');
    dataarray = spikes.to_python()
    f.writelines(["%s\n" % item  for item in dataarray])
    f.close()
    return False;

def main(offsetRange, amp, freqRange, std, dt, tau, mu, delay, dur):
    init_simulation()
    pool = Pool(processes=1)
    count = 0
    freq = freqRange[1]
    dist = 0.0
    # for dist in [.1,.5,.9]:
    # for offset in offsetRange:
    offset = 1.
    proc = pool.apply_async(alltogethernow, (dist,count,delay, dur, offset, amp, freq, dt, tau, std, mu))
    count = count+1;
    pool.close()
    pool.join()
    return 0;
