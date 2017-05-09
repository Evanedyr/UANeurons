A = readdlm("./OUTPUT/test.txt")
timeA = (0:(length(A)-1))*0.005
figure(1)
subplot(211)
linePlot(timeA, A)
A = A[20000:end]
timeA = timeA[20000:end]
subplot(212)
linePlot(A[1:end-1], diff(A))

W = Array{Float64}(length(A), 3)
W[:, 1] = A
W[:, 3] = (1:length(A))*0.005
Ra = 0.0
timevec = timeA
timemax=[]
timemax2=[]


deri1 = diff(W[:, 1])
deri2 = diff(deri1)
deri3 = diff(deri2)
deriwtf = deri2./deri1[2:end]

#
figure(535)
plot(deri1, linestyle="--", color="r")
plot(deri2, linestyle="--", color="g")
figure(21)
plot(deri3, linestyle="--", color="k")
timemax = FindMax(deri3, timevec[4:end], 0.0015)
for l = 1:length(timemax)
  temptime = Int64(round((timemax[l]/0.005)))-20000
  if W[temptime, 1] < -40 && W[temptime, 1] > -60
    push!(timemax2,  timemax[l])
  end
end
figure(656)
subplot(211)
plot(timevec, W[:,1], label="Ra: $(Ra)")
legend(fancybox = "true", loc="best")
subplot(212)
plot(W[2:end, 1], deri1)
onvolt = [0.]
onslope = [0.]
count=1
for j in timemax2
  f(x) = x==j
  indj = find(f, timevec)
  print(indj)
  subplot(211)
  plot(j*ones(81), -60:20, linewidth=0.5, color=ColorPicker(count))
  subplot(212)
  markerPlot(W[indj, 1], deri1[indj-1], count)
  xstart = W[indj, 1]
  xv = [xstart xstart+10.]'
  # print(count)
  try
    plot(xv, deri1[indj-1].+deriwtf[indj-2].*(xv.-W[indj, 1]), color=ColorPicker(count), linewidth=0.8)
    count += 1
    append!(onvolt, W[indj, 1])
    append!(onslope, deriwtf[indj-2])
  end
end
shift!(onvolt)
shift!(onslope)
meanonvolt = mean(onvolt)
stdonvolt = std(onvolt)
meanonslope = mean(onslope)
stdonslope = std(onslope)
print("The average threshold to spike is (in mv): $(meanonvolt[1]), with std: $(stdonvolt[1]) \n The average slope is: $(meanonslope[1]), with std: $(stdonslope[1])")
