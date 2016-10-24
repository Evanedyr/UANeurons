# This is from Bertrand's optimization
# Spike between 150 and 170 ms

from brian2 import *
import time


voltage_clamp = False # if False then current clamp

defaultclock.dt=0.01*ms


duration = 300*ms
input_current = .3*namp
# specify neuron
# Na channels

Ina_s_g = 800*nS
Ina_s_Vi_act = -25*mV
Ina_s_Vi_inact = -35*mV
Ina_k_act = 6*mV
Ina_s_k_inact = 6*mV
Ina_s_tau_cst_act = 100*us
Ina_s_tau_cst_inact = .5*ms

Ina_a_g = 1200*nS
Ina_a_Vi_act = -25*mV
Ina_a_Vi_inact = -35*mV
Ina_a_k_inact = 6*mV
Ina_a_tau_cst_act = 100*us
Ina_a_tau_cst_inact = .5*ms

# K channels
Ik_s_g = 2200*nS
Ik_a_g = 1200*nS
Ik_Vi_act = -15*mV
Ik_tau_cst_act = 2*ms
Ik_k_act = 4*mV


Ra = 4.5*Mohm
Ileak_Vr = -80*mV

# Somatic compartment
Cs = 250*pF
Ca=5*pF
Ileak_g = 12*nS



eqs ="""
dva/dt = (-Ina_a -Ik_a - Ia) /Ca : volt
Ia = (va-vs)/Ra : amp
"""

eqs +="""  
Ina_s=Ina_s_g*(vs-60*mV)*m_Ina_s*h_Ina_s:amp
dm_Ina_s/dt=(m_Ina_sinf - m_Ina_s)/m_Ina_stau:1
m_Ina_sinf=(1./ (1+exp(-(vs-Ina_s_Vi_act)/Ina_k_act))):1
m_Ina_stau= Ina_s_tau_cst_act:second
dh_Ina_s/dt=(h_Ina_sinf - h_Ina_s)/h_Ina_stau:1
h_Ina_sinf=(1./ (1+exp((vs-Ina_s_Vi_inact)/Ina_s_k_inact))):1
h_Ina_stau= Ina_s_tau_cst_inact:second
"""

eqs +=""" 
Ina_a=Ina_a_g*(va-60*mV)*m_Ina_a*h_Ina_a:amp
dm_Ina_a/dt=(m_Ina_ainf - m_Ina_a)/m_Ina_atau:1
m_Ina_ainf=(1./ (1+exp(-(va-Ina_a_Vi_act)/Ina_k_act))):1
m_Ina_atau= Ina_a_tau_cst_act:second
dh_Ina_a/dt=(h_Ina_ainf - h_Ina_a)/h_Ina_atau:1
h_Ina_ainf=(1./ (1+exp((va-Ina_a_Vi_inact)/Ina_a_k_inact))):1
h_Ina_atau= Ina_a_tau_cst_inact:second  
"""

eqs +=""" 
Ik_s=Ik_s_g*(vs+90*mV)*m_Ik_s:amp
dm_Ik_s/dt=(m_Ik_sinf - m_Ik_s)/m_Ik_tau:1
m_Ik_sinf=(1./ (1+exp(-(vs-Ik_Vi_act)/Ik_k_act))):1
m_Ik_tau= Ik_tau_cst_act:second   
"""

eqs +=""" 
Ik_a=Ik_a_g*(va+90*mV)*m_Ik_a:amp
dm_Ik_a/dt=(m_Ik_ainf - m_Ik_a)/m_Ik_tau:1
m_Ik_ainf=(1./ (1+exp(-(va-Ik_Vi_act)/Ik_k_act))):1
"""



if voltage_clamp:
    # voltage clamp
    eqs+='''
    Ileak=Ileak_g*(vs-Ileak_Vr):amp
    Iclamp =(Ileak+Ik_s+Ina_s-Ia):amp
    vs=vc: volt
    vc :volt  # 
    '''
else:
    # current clamp
    eqs+="""
    Ileak=Ileak_g*(vs-Ileak_Vr):amp
    dvs/dt = (-Ileak -Ina_s -Ik_s+ Ia + I) /Cs : volt
    I : amp # external stimulation
    """

if voltage_clamp:     
    nvolts = 1000
    neuron = NeuronGroup(nvolts,eqs,method='exponential_euler')
else:
    neuron = NeuronGroup(1,eqs,method='exponential_euler')
    
    

neuron.h_Ina_s=1
neuron.h_Ina_a=1

if voltage_clamp:

    volts = np.linspace(-80,20,nvolts) # voltage rangespace
    currents = []

    M=StateMonitor(neuron,('Iclamp','vc','vs'),record=True)
#     neuron.gclamp = Ileak_g*500
    
    t1= time.time()
    neuron.vc = -80*mV
    run(10*ms)
    neuron.vc = -70*mV
    run(10*ms)
    neuron.vc = -80*mV
    run(10*ms)
    p_value10 = M.Iclamp.T[-10*np.round(1000/(neuron.dt/usecond)):,0]
    neuron.vc = volts * mV
    run(10*ms)
    print('elapsed time',time.time()-t1)
    
    fraction = (-80-volts)/10
    Itmp = M.Iclamp.T[-10*np.round(1000/(neuron.dt/usecond)):,:]
    p_value10 = tile(p_value10,(nvolts,1)).T
    fraction = tile(fraction,(Itmp.shape[0],1))
    corrected_current = (Itmp-p_value10*fraction)/namp
    current_in = corrected_current
    currents = (corrected_current[20:150,:]).min(axis=0)
    

else:
    neuron.vs = Ileak_Vr
    neuron.va = Ileak_Vr
#     neuron.I=5*mV*gL
    M=StateMonitor(neuron,('vs','va', 'Ina_a','Ik_a', 'Ina_s','Ik_s','Ileak','m_Ina_s','m_Ina_a','Ia'),record=True)
    #M=StateMonitor(neuron,('vs','va', 'tauhs','IK_axon','INa_axon','Ia','Il'),record=True)
    run(duration/2,report='text')
    neuron.I = input_current 
    run(duration/2,report='text')

# plots
if voltage_clamp:
    # IV curve
    # calculate where the discontinuity begins
    dif_curr = diff(currents)
    thres = volts[np.where(abs(dif_curr) > 10)[0][0]]

    figure()
    plot(volts, currents, 'k.')
    plot(volts, currents)
    xlabel('voltage (mV)')
    ylabel('current (pA)')
    vlines(thres, min(currents), max(currents), color = '0.7', linestyles = 'dotted')
    text(thres+0.25,0, str(round(thres,2))+'mV')


    figure()
    plt.plot(np.array(current_in))
    xlabel('time (ms)')
    ylabel('current (pA)')


else:

    # voltage over time and phaseplot
    figure()
    subplot(121)
    vs,va=M[0].vs,M[0].va
    plot(M.t/ms,M[0].vs/mV,'k')
    plot(M.t/ms,M[0].va/mV,'r')
    xlabel('t (ms)')
    ylabel('Vm (mV)')
    legend(['vs','va'],0)
#     xlim([50,58])
    subplot(122)
    dvs=diff(vs)/defaultclock.dt
    dva=diff(va)/defaultclock.dt
    plot(0.5*(vs[:-1]+vs[1:])/mV,dvs,'k')
    plot(0.5*(va[:-1]+va[1:])/mV,dva,'r')
    xlabel('Vm (mV)')
    ylabel('dV/dt (mV/ms)')

    figure()
    # Na influx ratio
    ind = (M.t>150*ms) & (M.t<170*ms)
    print(sum(M[0].Ina_a[ind])/sum(M[0].Ina_s[ind]))
    plot(M.t/ms,M[0].Ina_s,'k')
    plot(M.t/ms,M[0].Ina_a,'r')

show()
