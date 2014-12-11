function [output_wave] = A2_funcB(input_wave, N, window_type, window_size, hop_size, time_str)
% Johnty Wang - MUMT605 Assignment 2
% A2_func generates an output time stretched waveform using the phase vocoder method in Part 1 of MillerPuckette's "Phase-locked Vocoder" paper.
%  Parameters:
%  output_wave - the output time-stretched waveform
%  input_wave - the input waveform
%  N - the analysis STFT size
%  window_type - the window type, given by:
%     0 - hamming
%     1 - hanning
%     2 - kaiser
%     3 - rectangular
%  window_size - the length of window
%  hope_size - the size of hops between each analysis STFT
%  time_str - the amount of time stretch

N
window_size
hop_size = round(hop_size);

output_wave = 0;
switch window_type
    case 0
        wind = hamming(window_size);
    case 1
        wind = hanning(window_size);
    case 2
        wind = kaiser(window_size);
    case 3
        wind = ones(window_size, 1);
    otherwise
        wind = hanning(window_size);
end

num_stfts = ceil(length(input_wave)/hop_size)

old_len = length(input_wave)

output_samples = floor(old_len*time_str);

% pad the end of the input wave with zeros, so we don't
% have overflow (and still get a complete FFT frame at the end...
% if we pad by N we definite have enough... (lazy, but definitely enough!)
input_wave = [input_wave zeros(1, N)];

%create empty array to hold STFTS, and freq estimates
X = zeros(num_stfts, N);
Wk = zeros(num_stfts, N);

%now we go through and fill it with windowed, FFT'ed values
for k=1:num_stfts
    frame_begin = 1 + (k-1) * hop_size - window_size/2;
    frame_end = frame_begin + window_size - 1;
    if (frame_begin < 1)
        x = input_wave(1:frame_end); % frame_end is never < 1!
        x = padarray(x, [0, -frame_begin+1], 0 , 'pre');
    else
        x = input_wave(frame_begin:frame_end);
    end
    x = x'; % put in column;
    
    %frame_begin = 1 + (k-1) * hop_size;
    %frame_end = frame_begin + window_size - 1;
    %x = input_wave(frame_begin:frame_end); x = x';
    
    x_w = x.*wind; %apply window
    %x_w_shifted = circshift(x_w, [0, window_size/2]);

    % FFT does auto zero padding when N > length of input
    X_w = fft(x_w, N); %FFT the windowed time series
    X(k,:) = X_w; %place into kth row of Spectrum matrix
    

    subplot(2,1,1);
    plot(abs(X_w));
    axis([0, 50, 0, 200]);
    subplot(2,1,2);
    plot(angle(X_w));
    axis([0, 50, -2*pi, 2*pi]);
    

end



% we now have all the "analysis frames" needed in the array X.
% where each row is one STFT
% now we need to get Y, which is the same array but with corrected
% phase values for each channel given the time stretch factor
% which places each consecutive frame at a new location (so that when
% we resynthesize with a different hop size, the phase coherence is
% maintained...
%
% Code for implementation of Puckette's method appears below next section,
% and can be enabled by changing the "use_puckette" flag to true, which
% overwrites the "manual method" output.
%

Y = zeros(size(X)); % Y is same size as X;

% The manual way of modifying the accumulated phase
% by going through the trig/exp functions and unwrapping angles...

unwrap_helper = ((0:N-1)*2*pi*hop_size/N); %unwrap helper: an interger 
% amount of this value is the potential wrap-around amount 
% for a frequency in a particular bin.

Y_mag = zeros(size(X));
prev_ang = zeros(size(X));
Y_ang_res_accum = zeros(N,1); %variable for holding accumulated angle

for k=1:num_stfts
    Y_mag = abs(X(k,:));
    prev_ang = Y_ang_res_accum;
    if (k==1) % for the first one, we just take the input
        Y_ang_res_accum = angle(X(k,:));
    else
        Y_unwrapped = angle(X(k,:)) - prev_ang - unwrap_helper;
        Y_unwrapped = Y_unwrapped - round(Y_unwrapped/(2*pi))*2*pi;
        Y_unwrapped = (Y_unwrapped + unwrap_helper)*time_str; % here's where the 
        % phase increment is changed to correspond to time stretch
        Y_ang_res_accum = Y_ang_res_accum + Y_unwrapped;
    end
    Y_ui = Y_mag.*exp(1i*Y_ang_res_accum);
    plot(Y_mag);
    axis([0, 50, 0, 200]);
    Y(k,:) = Y_ui; %store in output spectra array
end

use_puckette = false;
skip = round(time_str); %NOTE: only accept integers!!
% method from Puckette's paper; only works for t_i-s_i = u_i - u_i-1!
if (use_puckette)
    for k=1:num_stfts-skip
        if (k==1) % initial bin: just use first frame from analysis!
            Y_ui = X(:,k);
        else
            %equation on pg 2, bottom 1st column:
            Y_ui = X(:,k+skip).*Y(:,k-1)./X(:,k)./(abs(Y(:,k-1)./X(:,k)));
        end
        Y(:,k) = Y_ui;
    end
end


% when we resynthesize, we place each inverse FFT at the stretched hop locations,
% window, overlap and add into the time series at the new (stretched) locations

%the new hop size is given by:
hop_size_synth = round(hop_size * time_str)

% since we have to round the hop size to an integer,
% the actual time stretch is in fact:
actual_stretch = hop_size_synth/hop_size

new_len = (num_stfts-1)*hop_size_synth + N

%the length of output is dependent on new hop size
output_wave = zeros(1, new_len);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trying to use the method of calculating each phase value:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%the length of output is dependent on new hop size
output_wave = zeros(1, new_len+N);

hop_size
hop_size_synth

for k=1:num_stfts
    y = real(ifft(Y(k,:)));
    subplot(2,1,1);
    plot(abs(fft(y)));
    axis([0, 50, 0, 200]);
    subplot(2,1,2);
    plot(angle(fft(y)));
    axis([0, 50, -2*pi, 2*pi]);
    y_wind = y(1:window_size); %take out zero padded bits from analysis
    %y_wind_shifted =  circshift(y_wind, [0, window_size/2]);
    %the new time locations
    frame_begin = 1 + (k-1) * hop_size_synth;
    frame_end = frame_begin + window_size - 1;    
    output_wave(frame_begin:frame_end) = output_wave(frame_begin:frame_end)+y_wind;
end;

%because we appended extra bits at the end, lets truncate it
%to the correct length
output_wave = output_wave(1:output_samples);

% normalize: hann window = 0.5*(OLA)
%  e.g. for OLA of 4 (hope size = wind/4), we expect output is 2x input
max_input = max(abs(input_wave))
max_output = max(abs(output_wave))
ratio = max_output/max_input % this should be 2 for hann window with 4x OLA
output_wave = output_wave/ratio; %reduce amplitude by a teeny bit

length(output_wave)


