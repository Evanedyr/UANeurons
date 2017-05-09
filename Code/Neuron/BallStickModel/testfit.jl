using PyPlot
A = readdlm("/home/christophe/Documents/Git/UANeurons/Data/BallAndStick/mfr5Hz0.05Amp/spiketrain5Hzmfr0.0Ra0.0288freq0.03std61seed.txt")
# figure(1)
# plot(A)
freq = 0.0298
modA = mod(A, 1/0.0298)
figure(1)
(nsom, bins, patches)=plt[:hist](modA, 33)


Rx = cos(A.*2*pi*freq)
Ry = sin(A.*2*pi*freq)
Rmeanx = mean(Rx)
Rmeany = mean(Ry)
peakN = length(A);
R = sqrt(sum(Rx)^2+sum(Ry)^2)/peakN
figure(23)
scatter(Rx,Ry)
scatter(Rmeanx, Rmeany, color="red")
scatter(0, 0, color="black")
