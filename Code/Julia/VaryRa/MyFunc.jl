# Let's first predefine a couple of 'structs' (called **composite types** in Julia)
type Ps                    # structure containing the numerical parameters of the somatic compartment
    ENa::Float64           # Reversal potential of sodium current(s), in mV
    EK::Float64            # Reversal potential of potassium current(s), in mV
    Eleak::Float64         # Reversal potential of leak current(s), in mV
    Gax::Float64           # Total axial conductance, in mS
    C::Float64             # Total membrane capacitance, in pF
    gNa::Float64           # Maximal conductance of sodium current, in nS
    gK::Float64            # Maximal conductance of potassium current, in nS
    gleak::Float64         # Maximal conductance of leak current, in nS
    V1Na::Float64          # Activation voltage of sodium current, in mV
    V2Na::Float64          # Inactivation voltage of sodium current, in mV
    V1K::Float64           # Activation voltage of potassium current, in mV
    KactNa::Float64        # Activation voltage slope of sodium current, in mV
    KinactNa::Float64      # Inactivation voltage slope of sodium current, in mV
    KactK::Float64         # Activation voltage slope of potassium current, in mV
    tm::Float64            # Activation time constant of sodium current, in ms
    th::Float64            # Inactivation time constant of sodium current, in ms
    tn::Float64            # Activation time constant of potassium current, in ms
end

type Pa                    # structure containing the numerical parameters of the axonal compartment
    ENa::Float64           # Reversal potential of sodium current(s), in mV
    EK::Float64            # Reversal potential of potassium current(s), in mV
    Eleak::Float64         # Reversal potential of leak current(s), in mV
    Gax::Float64           # Total axial conductance, in mS
    C::Float64             # Total membrane capacitance, in pF
    gNa::Float64           # Maximal conductance of sodium current, in nS
    gK::Float64            # Maximal conductance of potassium current, in nS
    gleak::Float64         # Maximal conductance of leak current, in nS
    V1Na::Float64          # Activation voltage of sodium current, in mV
    V2Na::Float64          # Inactivation voltage of sodium current, in mV
    V1K::Float64           # Activation voltage of potassium current, in mV
    KactNa::Float64        # Activation voltage slope of sodium current, in mV
    KinactNa::Float64      # Inactivation voltage slope of sodium current, in mV
    KactK::Float64         # Activation voltage slope of potassium current, in mV
    tm::Float64            # Activation time constant of sodium current, in ms
    th::Float64            # Inactivation time constant of sodium current, in ms
    tn::Float64            # Activation time constant of potassium current, in ms
end

type Xs                    # Structure containing the state variables of the somatic compartment
    V::Float64             # Membrane potential
    m::Float64             # Fraction of sodium channels in the open state
    h::Float64             # Fraction of sodium channels in the inactive state
    n::Float64             # Fraction of potassium channels in the open state
end

type Xa                    # Structure containing the state variables of the axonal compartment
    V::Float64             # Membrane potential
    m::Float64             # Fraction of sodium channels in the open state
    h::Float64             # Fraction of sodium channels in the inactive state
    n::Float64             # Fraction of potassium channels in the open state
end


function sigmoid(tmp)
    #tmp = (V - Vo)/k;
    f = 1./(1. + exp(-tmp));
end

function simulate_ou!(x, N::Int, x0::Float64, Δt::Float64, μ::Float64, σ::Float64, τ::Float64)
    tmp1 = exp(-Δt/τ);                # Useful to slighlty reduce the n. of operations
    tmp2 = σ * sqrt(1-exp(-2*Δt/τ));  # Useful to slighlty reduce the n. of operations
    tmp3 = μ * (1 - exp(-Δt/τ));      # Useful to slighlty reduce the n. of operations

    x[1] = x0;                        # We take care of the initial condition
    for i=2:N,
        x[i] = x[i-1] * tmp1 + tmp3 + tmp2 * randn();
    end
    # x = x * tmp1 + tmp3 + tmp2 * randn()
    return x
end

function evolve_model!(out, ps::Ps, pa::Pa, xs::Xs, xa::Xa, Ipeak::Float64, N, Δt::Float64, t::Float64, tstim::Float64, tstim_dur::Float64, tstimcon::Float64, tstimcon_dur::Float64, Noise::Int, nv, Amp::Float64, Freq::Float64)
    # Noise is 0 for DC current, 1 for DC current with noise, 2 for DC + noise + sine
    # Useful temporary variables are defined and initialised below
    Δms = 0.;    Δhs = 0.;    Δns = 0.;
    Δma = 0.;    Δha = 0.;    Δna = 0.;
    ΔVs = 0.;    ΔVa = 0.;
    Ina = 0.;    Ik = 0.;     Ileak = 0.;
    Iax = 0.;    counter = 1;

    @inbounds for k in 1:N

        # External current pulse ------------------------------------------------------------------
        if Noise == 0
          if (tstim   <= (k*Δt) < (tstim + tstim_dur))
              Iext = Ipeak;
          else
              Iext = 0.;
          end
        elseif Noise == 1
          if (tstim   <= (k*Δt) < (tstim + tstim_dur))
              Iext = Ipeak + nv[counter];
              counter += 1
          else
              Iext = 0.;
          end
        elseif Noise == 2
          if (tstim   <= (k*Δt) < (tstim + tstim_dur))
              # nv.x = simulate_ou!(nv.x, nv.Δt, nv.μ, nv.σ, nv.τ)
              Iext = Ipeak + nv[counter] + Amp * sin(2 * π * Freq * k * Δt);
              counter += 1
          elseif (tstimcon <= (k * Δt) < (tstimcon + tstimcon_dur))
              Iext = Ipeak
          else
              Iext = 0.;
          end
        end
        # Soma ------------------------------------------------------------------------------------
        Δms = Δt/ps.tm * (sigmoid((xs.V - ps.V1Na)  / ps.KactNa)   - xs.m);
        Δhs = Δt/ps.th * (sigmoid(-(xs.V - ps.V2Na) / ps.KinactNa) - xs.h);   # Note the minus sign
        Δns = Δt/ps.tn * (sigmoid((xs.V - ps.V1K)   / ps.KactK)    - xs.n);

        Ina = ps.gNa   * xs.m * xs.h * (xs.V - ps.ENa)
        Ik  = ps.gK    * xs.n *        (xs.V - ps.EK)
        Il  = ps.gleak *               (xs.V - ps.Eleak)
        Iax = ps.Gax      *            (xs.V - xa.V)

        ΔVs = Δt/ps.C * (-Ina -Ik -Il -Iax + Iext);      # Note the sign for Iax

        # Axon ------------------------------------------------------------------------------------
        Δma = Δt/pa.tm * (sigmoid((xa.V - pa.V1Na)  / pa.KactNa)   - xa.m);
        Δha = Δt/pa.th * (sigmoid(-(xa.V - pa.V2Na) / pa.KinactNa) - xa.h);   # Note the minus sign
        Δna = Δt/pa.tn * (sigmoid((xa.V - pa.V1K)   / pa.KactK)    - xa.n);

        Ina = pa.gNa   * xa.m * xa.h * (xa.V - pa.ENa)
        Ik  = pa.gK    * xa.n *        (xa.V - pa.EK)
        Il  = pa.gleak *               (xa.V - pa.Eleak)
        #Iax = pa.Gax      *               (xs.V - xa.V)

        ΔVa = Δt/pa.C * (-Ina -Ik + Iax);      # Note the (different) sign for Iax and neither Iext nor Ileak

        # The (forward) Euler method is applied --------------------------------------------------
        xs.m += Δms;        xs.h += Δhs;        xs.n += Δns;        xs.V += ΔVs;
        xa.m += Δma;        xa.h += Δha;        xa.n += Δna;        xa.V += ΔVa;

        # Output ---------------------------------------------------------------------------------
        out[k,1] = xs.V;
        out[k,2] = Iext;
        out[k,3] = t;
        t += Δt;
 end # for
end


function FindMax(vec, time, thres::Float64)
  timemax = []
  valmax = maximum(vec)		# Find max from somatic Voltage
  f(x) = x > thres		# Set threshold function with given fixed value
  varranges = find(f, vec)	# varranges is array of indexes that satisfy condition
  tempvec = vec[varranges]
  tempvectime = time[varranges]
  startrange = 1
  for iter in eachindex(varranges)
      if iter == length(varranges)
        temprange= tempvec[startrange:iter]
        temprangetime = tempvectime[startrange:iter]
        spacemax = findmax(temprange)
        push!(timemax, temprangetime[spacemax[2]])
        break
      elseif varranges[iter] + 1 != varranges[iter+1]	# If true, we finished the points of the previous spike
        temprange= tempvec[startrange:iter]
        temprangetime = tempvectime[startrange:iter]
        spacemax = findmax(temprange)
        push!(timemax, temprangetime[spacemax[2]])
        startrange = iter+1				# Set new startrange for next spike
        temprange = []
        temprangetime = []
      end
  end
  return timemax		# vector of peak occurrence timings
end


function GetThatHistBoy(vec)
  (nsom, bins, patches)=plt[:hist](vec, 33)
  return nsom, bins
end

function findIntersect(data, th, init)
  fOver5(x) = x > th;
  a = findnext(fOver5, data[:,2], 2);
  b = a-1;
  pos = data[b,1] - ((data[b,2]-th)/(data[b,2]-data[a,2]))*(data[b,1]-data[a,1]);
  return (pos, a);
end
