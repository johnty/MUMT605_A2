t = 1:44100;
N = 512;
window_type = 0;
window_size = 512, 
hop_size = round(N/4.1);
time_str = 1.0;
Fs = 44100;
bin_w = Fs/N;

switch window_type
    case 0
        wind = hamming(window_size);
        H_val = N/4;
    case 1
        wind = hanning(window_size);
        H_val = N/4;
    case 2
        wind = kaiser(window_size);
        H_val = N/6;
    otherwise
        wind = hanning(N);
        H_val = N/4;
end

input_wave = sin(2*pi*4.1*bin_w*t/Fs);

num_stfts = ceil(length(input_wave)/hop_size)

% pad the end of the input wave with zeros, so we don't
% have overflow (and still get a complete FFT frame at the end...
% if we pad by N we definite have enough...
input_wave = [input_wave zeros(1, N)]; 

%create empty array to hold STFTS
X = zeros(N, num_stfts);

%now we go through and fill it with windowed, FFT'ed values
for k=1:num_stfts
    frame_begin = 1 + (k-1) * hop_size;
    frame_end = frame_begin + N-1;
    x = input_wave(frame_begin:frame_end);
    x_w = x.*wind';
    X_w = fft(x_w);
    X(:,k) = X_w'; %place the transpose into the k_th column
end
subplot(3,1,1)
plot(wind);

%we now have all the "analysis frames" needed in the array X.
% now we need to get Y, which is the same array but with corrected
% phase values for each channel given the time stretch factor
% which places each consecutive frame at a new location (so that when
% we resynthesize with a different hop size, the phase coherence is
% maintained...

Y = zeros(size(X)); % Y is same size as X;
Y = X;

%the new hop size is given by:
hop_size_synth = round(hop_size * time_str);

% since we have to round the hop size to an integer, 
% the actual time stretch is in fact:
actual_stretch = hop_size_synth/hop_size

%the length of output is dependent on new hop size
new_len = (num_stfts-1)*hop_size_synth + N
output_wave = zeros(1, new_len);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trying to use the method of calculating each phase value:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hop_size
hop_size_synth

for k=1:num_stfts
    y = ifft(X(:,k))';
    %the new time locations
    frame_begin = 1 + (k-1)*hop_size;
    frame_end = frame_begin + N -1;
    output_wave(frame_begin:frame_end) = output_wave(frame_begin:frame_end)+y;
    
end;


% normalize: (I may have ommitted a step somewhere, causing
% the amplitudes to be larger than 1.0 with overlap/add...)
% or is this expected behaviour?
output_wave = output_wave./max(abs(output_wave));
length(output_wave)
subplot(3,1,3);
plot(output_wave);

player = audioplayer(input_wave, Fs);
player.playblocking();

player = audioplayer(output_wave, Fs);
player.playblocking();

