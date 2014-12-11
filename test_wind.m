N = 512;
T = N*4
O = N/4;
t = 1:T;
wn = sin(2*pi*440*t/44100);

X = zeros(N,4);
wind = hann(N)';
for k=1:4
    frame_start = round((k-1)*O)+1;
    frame_end = frame_start+N-1;
    frame_wn = wn(frame_start:frame_end);
    frame_wnw = frame_wn.*wind;
    X_k = fft(frame_wn);
    X_kw = fft(frame_wnw);
    subplot(2,1,1);
    
    stem(abs(X_k), 'r.');
    axis([0, length(X_k)/2, 0, 1.2*max(abs(X_k))]);
    xx = abs(X_k');
    subplot(2,1,2);
    
    stem(abs(X_kw), 'b.');
    axis([0, length(X_k)/2, 0, 1.2*max(abs(X_kw))]);
end

Y = zeros(N,4);
