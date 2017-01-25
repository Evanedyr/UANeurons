function ColorPicker(XthColor::Int64)
####### Give this function an Integer number between 1-13 and get the specified color or give zero for a random color. If the specified number is higher than 11 it will be modded to be between 1 and 13. #######
col = [255 30 30; 88 24 69; 38 183 216; 132 20 164; 255 210 58; 255 147 0; 245 15 230; 16 0 160; 89 88 102; 20 127 42; 0 246 170; 0 0 0; 114 70 4]
col /= 255

if XthColor == 0
	pickColor = rand(1:size(col)[1])
else
	pickColor = mod(XthColor-1, size(col)[1]) + 1
end
return col[pickColor,:]

end
