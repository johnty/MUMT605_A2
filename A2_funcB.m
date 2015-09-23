function [output_wave] = A2_funcB(input_wave, N, window_type, window_size, IN_SIZE, OUT_SIZE)
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


time_str = OUT_SIZE/IN_SIZE
hop_size = 1;

N
window_size

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

num_stfts = ceil(length(input_wave)/hop_size);

old_len = length(input_wave);

output_samples = floor(old_len*time_str);

% pad the end of the input wave with zeros, so we don't
% have overflow (and still get a complete FFT frame at the end...
% if we pad by N we definite have enough... (lazy, but definitely enough!)
input_wave = [input_wave zeros(1, N)];

%create empty array to hold STFTS, and freq estimates
X = zeros(N, num_stfts);
Wk = zeros(N, num_stfts);

%now we go through and fill it with windowed, FFT'ed values
for k=1:num_stfts
    %frame_begin = 1 + (k-1) * hop_size - N/2
    %frame_end = frame_begin + N - 1
    %x = getTimeStartEnd(input_wave, frame_begin, frame_end); %windowed time series in frame
    frame_begin = 1 + (k-1) * hop_size;
    frame_end = frame_begin + window_size - 1;
    x = input_wave(frame_begin:frame_end);
    x_w = x.*wind'; %apply window
    %x_w_shifted = circshift(x_w, [0, window_size/2]);
    
    %%zero pad:
    %if (N>window_size) %zero pad if FFT size larger than window size
    %    x_w = [x_w zeros(1, N - window_size)];
    %   
    %end
    % turns out we don't need above, since we can simply call fft with N
    % and the zero padding is automatic!
    X_w = fft(x_w, N); %FFT the windowed time series
    X(:,k) = X_w'; %place the transpose into the k_th column

end



%we now have all the "analysis frames" needed in the array X.
% now we need to get Y, which is the same array but with corrected
% phase values for each channel given the time stretch factor
% which places each consecutive frame at a new location (so that when
% we resynthesize with a different hop size, the phase coherence is
% maintained...

Y = zeros(size(X)); % Y is same size as X;



% Y_ang_res_accum = zeros(N,1); %variable for holding accumulated angle
% 
% %unwrap helper: an interger amount of this value is the potential
% %wrap-around amount for a frequency in a particular bin.
% unwrap_helper = ((0:N-1)*2*pi*hop_size/N)';
% 
% Y_mag = zeros(size(X));
% prev_ang = zeros(size(X));
% %The manual way...
% for k=1:num_stfts
%     Y_mag = abs(X(:,k));
%     prev_ang = Y_ang_res_accum;
%     if (k==1) % for the first one, we just take the input
%         Y_ang_res_accum = angle(X(:,k));
%     else
%         Y_unwrapped = angle(X(:,k)) - prev_ang - unwrap_helper;
%         Y_unwrapped = Y_unwrapped - round(Y_unwrapped/(2*pi))*2*pi;
%         Y_unwrapped = (Y_unwrapped + unwrap_helper) * time_str;
%         Y_ang_res_accum = Y_ang_res_accum + Y_unwrapped;
%     end
%     Y_ui = Y_mag.*exp(1i*Y_ang_res_accum);
%     Y(:,k) = Y_ui; %store in output spectra array
% end

use_puckette = true;
% method from Puckette's paper; only works for t_i-s_i=u_i - u_i-1;
if (use_puckette)
    for k=1:(num_stfts/IN_SIZE-1)
        if (k==1) % initial bin: just use first frame from analysis!
            Y_ui = X(:,k);
        else
            %equation on pg 2, bottom 1st column:
            Y_ui = X(:,IN_SIZE*(k-1)+OUT_SIZE).*Y(:,k-1)./X(:,IN_SIZE*(k-1))./(abs(Y(:,k-1)./X(:,IN_SIZE*(k-1))));
            %put into output array:
        end
        Y(:,k) = Y_ui;
    end
end


% when we resynthesize, we place each inverse FFT at the stretched hop locations,
% window, overlap and add into the time series at the new (stretched) locations
new_len = ceil((num_stfts)*OUT_SIZE/IN_SIZE + 2*N)

%the length of output is dependent on new hop size
output_wave = zeros(1, new_len);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trying to use the method of calculating each phase value:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%the length of output is dependent on new hop size
output_wave = zeros(1, new_len);

for k=1:num_stfts/IN_SIZE-1
    y = ifft(Y(:,k)'); %!!!!! the line that cost me nearly a week of work
                        %!!!!! ifft(X') != ifft(X)' !!!!!!
    %plot(y);                    
    y_wind = y(1:window_size);
    %y_wind_shifted =  circshift(y_wind, [0, window_size/2])
    %the new time locations
    frame_begin = 1 + (k-1) * OUT_SIZE;
    frame_end = frame_begin + window_size - 1;    
    output_wave(frame_begin:frame_end) = output_wave(frame_begin:frame_end)+y_wind;
end;

%because we appended extra bits at the end, lets truncate it
%to the correct length
%output_wave = output_wave(1:output_samples);

% normalize: hann window = 0.5*(OLA)
%  e.g. for OLA of 4 (hope size = wind/4), we expect output is 2x input
max_input = max(abs(input_wave));
max_output = max(abs(output_wave));
ratio = max_output/max_input; % this should be 2 for hann window with 4x OLA
output_wave = output_wave/ratio;

length(output_wave);


