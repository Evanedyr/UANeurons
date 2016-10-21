using PyPlot
cm = 0.010
gnamax = 1.2
gkmax = 0.36
gl = 0.003
Vna = 50.
Vk = -77.
Vl = -54.387
dt = 0.0001
tot = 50
N = tot/dt
N = convert(Int, N)
T = (0:N-1)*dt
V = zeros(N)
m = zeros(N)
h = zeros(N)
n = zeros(N)
V[1]=-64.9964
m[1]=0.0530
h[1]=0.5960
n[1]= 0.3177
Iext = zeros(N)
alpham = zeros(N)
alphah = zeros(N)
alphan = zeros(N)
betam = zeros(N)
betah = zeros(N)
betan = zeros(N)
tbegin = 10.
tend = 40.
Curr = .5
for i = 1:N
  tempvar = T[i]
  if tempvar > tbegin && tempvar < tend
    Iext[i] = Curr
  end
end

for k=2:N
  V[k]=V[k-1]+(dt/cm)*(gnamax*m[k-1]^3* h[k-1]*(Vna-V[k-1])+gkmax*n[k-1]^4*(Vk-V[k-1])+gl*(Vl-V[k-1])+Iext[k])
  alpham[k-1]=0.1*(V[k-1]+40)/(1.-exp(-(V[k-1]+40)/10))
  betam[k-1]=4*exp(-0.0556*(V[k-1]+65))
  alphan[k-1]=0.01*(V[k-1]+55)/(1-exp(-(V[k-1]+55)/10))
  betan[k-1]=0.125*exp(-(V[k-1]+65)/80)
  alphah[k-1]=0.07*exp(-0.05*(V[k-1]+65))
  betah[k-1]=1/(1+exp(-0.1*(V[k-1]+35)))
  m[k]=m[k-1]+(alpham[k-1]*(1-m[k-1])-betam[k-1]*m[k-1])*dt
  h[k]=h[k-1]+(alphah[k-1]*(1-h[k-1])-betah[k-1]*h[k-1])*dt
  n[k]=n[k-1]+(alphan[k-1]*(1-n[k-1])-betan[k-1]*n[k-1])*dt
end


plot(T, V)
