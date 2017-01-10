COMMENT
  This .mod file introduces a pointprocess for current clamp made with sinusoidal noisy signal.
  To use, on linux, you have to locate it in the same folder as the .py file you are running, and run nrnivmodl before
  running the actual script. Doing this will create a x86_64 folder with inside all the compiled (in c) files needed
  by Neuron to use this point process.
  To use it in the .py fill, you call it as any other point process:
    stim = h.IClampNoise(soma(.5))
  and later you can edit all the PARAMETER fields
ENDCOMMENT

NEURON {
  POINT_PROCESS IClampNoise
  RANGE i,delay,dur,std,offset,mu,tau,dt
  ELECTRODE_CURRENT i
}

UNITS {
  (nA) = (nanoamp)
}

PARAMETER {
  delay=50    (ms)
  dur=200   (ms)
  std=0.2   (nA)
  offset=0.05	(nA)
  mu = 0  (nA)
  tau = 10  (ms)
  dt = 0.0001  (ms)
}

ASSIGNED {
  ival (nA)
  i (nA)
  noise (nA)
  ou (nA)
  lastou (nA)
  on (1)
}

INITIAL {
  i = 0
  on = 0
  lastou = 0
  net_send(delay, 1)
}

PROCEDURE seed(x) {
  set_seed(x)
}

BEFORE BREAKPOINT {
  if  (on) {
    noise = normrand(0,std*1(/nA))*1(nA)
    ou = lastou*exp(-dt/tau)+mu*(1-exp(-dt/tau))+std*sqrt(1-exp(-2*dt/tau))*noise
    ival = offset+ou
    lastou = ou
  } else {
    ival = 0
  }
}

BREAKPOINT {
  i = ival
}

NET_RECEIVE (w) {
  if (flag == 1) {
    if (on == 0) {
      : turn it on
      on = 1
      : prepare to turn it off
      net_send(dur, 1)
    } else {
      : turn it off
      on = 0
    }
  }
}
