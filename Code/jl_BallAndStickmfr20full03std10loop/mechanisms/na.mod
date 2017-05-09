COMMENT
na.mod

Sodium channel, Hodgkin-Huxley style kinetics.  

Kinetics were fit to data from Huguenard et al. (1988) and Hamill et
al. (1991)

qi is not well constrained by the data, since there are no points
between -80 and -55.  So this was fixed at 5 while the thi1,thi2,Rg,Rd
were optimized using a simplex least square proc

voltage dependencies are shifted approximately from the best
fit to give higher threshold

Author: Zach Mainen, Salk Institute, 1994, zach@salk.edu

26 Ago 2002 Modification of original channel to allow 
variable time step and to correct an initialization error.
Done by Michael Hines(michael.hines@yale.e) and 
Ruggero Scorcioni(rscorcio@gmu.edu) at EU Advance Course 
in Computational Neuroscience. Obidos, Portugal

11 Jan 2007 Fixed glitch in trap where (v/th) was where (v-th)/q is. 
(thanks Ronald van Elburg!)

20110202 made threadsafe by Ted Carnevale
20120514 replaced vtrap0 with efun, which is a better approximation
         in the vicinity of a singularity

Special comment:

This mechanism was designed to be run at a single operating 
temperature--37 deg C--which can be specified by the hoc 
assignment statement
celsius = 37
This mechanism is not intended to be used at other temperatures, 
or to investigate the effects of temperature changes.

Zach Mainen created this particular model by adapting conductances 
from lower temperature to run at higher temperature, and found it 
necessary to reduce the temperature sensitivity of spike amplitude 
and time course.  He accomplished this by increasing the net ionic 
conductance through the heuristic of changing the standard HH 
formula
  g = gbar*product_of_gating_variables
to
  g = tadj*gbar*product_of_gating_variables
where
  tadj = q10^((celsius - temp)/10)
  temp is the "reference temperature" (at which the gating variable
    time constants were originally determined)
  celsius is the "operating temperature"

Users should note that this is equivalent to changing the channel 
density from gbar at the "reference temperature" temp (the 
temperature at which the at which the gating variable time 
constants were originally determined) to tadj*gbar at the 
"operating temperature" celsius.
ENDCOMMENT

NEURON {
    THREADSAFE
	SUFFIX na
	USEION na READ ena WRITE ina
	RANGE m, h, gna, gbar, ina, tha, qa, qinf, thinf
	RANGE minf, hinf, mtau, htau
	GLOBAL Ra, Rb, Rd, Rg
	GLOBAL q10, temp, tadj, vmin, vmax, vshift
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(pS) = (picosiemens)
	(um) = (micron)
} 

PARAMETER {
	gbar = 1000   	(pS/um2)	: 0.12 mho/cm2
	vshift = 0	(mV)		: voltage shift (affects all)
								
	tha  = -35	(mV)		: v 1/2 for act		(-42)
	qa   = 9	(mV)		: act slope
	Ra   = 0.182	(/ms)		: open (v)
	Rb   = 0.124	(/ms)		: close (v)

	thi1  = -50	(mV)		: v 1/2 for inact
	thi2  = -75	(mV)		: v 1/2 for inact
	qi   = 5	(mV)	        : inact tau slope
	thinf  = -65	(mV)		: inact inf slope	
	qinf  = 6.2	(mV)		: inact inf slope
	Rg   = 0.0091	(/ms)		: inact (v)
	Rd   = 0.024	(/ms)		: inact recov (v)

	temp = 23	(degC)		: original temp
	q10  = 2.3			: temperature sensitivity

:	dt		(ms)
	vmin = -120	(mV)
	vmax = 100	(mV)
}

ASSIGNED {
	v 		(mV)
	celsius		(degC)
	ina 		(mA/cm2)
	gna		(pS/um2)
	ena		(mV)
	minf 		hinf
	mtau (ms)	htau (ms)
	tadj
}
 
STATE { m h }

INITIAL {
    tadj = 1 : make all threads calculate tadj at initialization

	trates(v+vshift)
	m = minf
	h = hinf
}

BREAKPOINT {
        SOLVE states METHOD cnexp
        gna = gbar*m*m*m*h
	ina = (1e-4) * gna * (v - ena)
} 

: LOCAL mexp, hexp

DERIVATIVE states {   :Computes state variables m, h, and n
        trates(v+vshift)      :             at the current v and dt.
        m' =  (minf-m)/mtau
        h' =  (hinf-h)/htau
}

PROCEDURE trates(v (mV)) {
    TABLE minf, hinf, mtau, htau
    DEPEND celsius, temp, Ra, Rb, Rd, Rg, tha, thi1, thi2, qa, qi, qinf
    FROM vmin TO vmax WITH 199

	rates(v): not consistently executed from here if usetable == 1
}




UNITSOFF
PROCEDURE rates(vm (mV)) {  
    LOCAL  a, b
	a = (0.182*(vm+35))/(1-exp(-(vm+35)/9))
	b = (-0.124*(vm+35))/(1-exp((vm+35)/9))
	mtau = 0.1
	minf = a/(a+b)

    :"h" inactivation
	a = 0.25*exp(-(vm+70)/12)
	b = (0.25*exp((vm+42)/6))/exp((vm+70)/12)
    htau = 0.5
    hinf = a/(a+b)
}
UNITSON

FUNCTION efun(z) {
	if (fabs(z) < 1e-6) {
		efun = 1 - z/2
	}else{
		efun = z/(exp(z) - 1)
	}
}