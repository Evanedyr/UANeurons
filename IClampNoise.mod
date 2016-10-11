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
  RANGE i,delay,dur,f0,f1,r,torn,std,bias
  ELECTRODE_CURRENT i
}

UNITS {
  (nA) = (nanoamp)
}

PARAMETER {
  delay=50    (ms)
  dur=200   (ms)
  torn=500  (ms)
  std=0.2   (nA)
  f0=0.2    (nA)
  f1=0.8    (nA)
  r =60
  bias = 0 (nA)
}

ASSIGNED {
  ival (nA)
  i (nA)
  amp (nA)
  noise (nA)
  on (1)
}

INITIAL {
  i = 0
  on = 0
  net_send(delay, 1)
}

PROCEDURE seed(x) {
  set_seed(x)
}

BEFORE BREAKPOINT {
  if  (on) {
    noise = normrand(0,std*1(/nA))*1(nA)
    amp = f0 + 0.5*(f1-f0)*(tanh((t-torn)/(r/3)/(1(ms))-3)+1)
    ival = amp + noise + bias
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
