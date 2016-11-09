function FindMax(vec, time, thres::Float64)
  timemax = []
  valmax = maximum(vec)
  f(x) = x > thres
  varranges = find(f, vec)
  tempvec = vec[varranges]
  tempvectime = time[varranges]
  startrange = 1
  for iter in eachindex(varranges)
      if iter == length(varranges)
        temprange= tempvec[startrange:iter]
        temprangetime = tempvectime[startrange:iter]
        spacemax = findmax(temprange)
        push!(timemax, temprangetime[spacemax[2]])
        startrange = iter+1
        temprange = []
        temprangetime = []
        break
      elseif varranges[iter] + 1 != varranges[iter+1]
        temprange= tempvec[startrange:iter]
        temprangetime = tempvectime[startrange:iter]
        spacemax = findmax(temprange)
        push!(timemax, temprangetime[spacemax[2]])
        startrange = iter+1
        temprange = []
        temprangetime = []
      end
  end
  return timemax
end
