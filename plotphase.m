t=1:44100;
x = sin(2*pi*440*t/44100);
a = x(1:512);
b = x(513:513+512);
A = fft(a); B = fft(b);
subplot(2,1,1)
plot(a)
subplot(2,1,2)
plot(b)
figure
subplot(2,1,1)
plot(A)
plot(real(A))
subplot(2,1,2)
plot(real(B))
figure
subplot(2,1,1)
plot(angle(A))
subplot(2,1,2)
plot(angle(B))