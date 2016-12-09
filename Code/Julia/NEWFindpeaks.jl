function findpeaks(data)
  th = -20;#mean(data)+std(data)*4; #threshold as 2 times the SD
  f1(x) = x > th
  f2(x) = x < th
  if f2(data[1])
    isUnder = true;
  else
    isUnder = false;
  end
  up = [];
  down = [];
  i = 1;
  while (i!=0)
    if (isUnder)
      val = findnext(f1, data, i+1);
      if (val!=0)
        push!(up, val)
	i = val;
        isUnder = false;
      else
        break
      end
    else
      val = findnext(f2, data, i+1);
      if (val!=0)
        push!(down,val)
	i = val;
        isUnder = true;
      else
        break
      end
    end
  end
  if length(up)<length(down)
    shift!(down)
  end
  peak = [];
  if (!isempty(down) & !isempty(up))
    for i=1:minimum([length(down), length(up)])
      val= indmax(data[up[i]:down[i]]);
      push!(peak, up[i]+val-1);
    end
  end
  return peak;
end
