%% Johnty Wang - MUMT605 Assignment 2
%% Helper script for demonstration implementation

% For sines:
Fs = 44100;
Dur = 1; % in seconds
t = 1:44100;
FFT_size = 512;
bin_w = Fs/FFT_size;

% Try a sine wave at centre of a bin/channel
sine1 = sin(2*pi*3.5*bin_w*t/Fs);
%process sine waves
sine1_p =0;

%play original, and then stretched:
player = audioplayer(sine1, Fs);
player.playblocking();
%

% Now, try a sine wave at edge of a bin/channel
sine2 = sin(2*pi*3*bin_w*t/Fs);
%process:

%play:
player = audioplayer(sine2, Fs);
player.playblocking();

% Now, try a recorded sample:
[wave1, Fs] = audioread('vocal2.wav');

%apply different stretches:


% Note: we use playblocking so it doesn't play at once!
player = audioplayer(wave1, Fs);
player.playblocking();