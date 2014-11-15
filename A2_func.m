function [output_wave] = A2_func(input_wave, N, window_type, window_size, hop_size, time_str)
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
%  window_size - the length of window
%  hope_size - the size of hops between each analysis STFT
%  time_str - the amount of time stretch

H_val; %
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