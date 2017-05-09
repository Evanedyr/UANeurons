using PyPlot

color = ["*b", "*g", "*r", "*c", "*m"];
i = 1;
for dist in [0.0, .25, .5, .75, 1.]
  for dc in [0.0, 1.0, 5.0]
    data = readdlm("/home/stefano/Workspace/jl_L5_TTPC1_cADpyr232_1_intersec/OUTPUT/spktrain$(dc)DC$(dist)dist.txt")
    spikecnt = length(data)
    mfr = spikecnt/((data[end]-data[1])*0.005)
    plot(dc, mfr, color[i])
  end
  i += 1;
end
