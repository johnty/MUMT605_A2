%% Johnty Wang - MUMT605 Assignment 2
%% Helper script for demonstration implementation

% For sines:
Fs = 44100;
Dur = 1; % in seconds
t = 1:44100*Dur;
%t = 1:FFT_size*4;

% Global parameters
W_SIZE = 512;
FFT_SIZE = 1024;
W_TYPE = 1;

bin_w = Fs/FFT_SIZE;

% Try a sine wave at centre of a bin/channel
sine1 = 0.95*sin(2*pi*3.5*bin_w.*t/Fs);

%process sine waves
c0 = clock;

IN_SIZE = 64;
OUT_SIZE = 70;
sine1_proc = A2_funcB(sine1, FFT_SIZE, W_TYPE, W_SIZE, IN_SIZE, OUT_SIZE);

%some stuff for timing
c1 = clock;
t_proc = c1-c0;
disp('time to process (s):')
disp(t_proc(6));
display('lenght of original (s):')
len_original = length(sine1)/Fs;
disp(len_original);
disp('processing speed (x realtime)');
disp(len_original/t_proc(6));


%play original
player = audioplayer(sine1, Fs);
player.playblocking();
%play result
player = audioplayer(sine1_proc, Fs);
player.playblocking();
%write to file
%audiowrite('input.wav', sine1, Fs);
%audiowrite('result.wav', sine1_proc, Fs);

% Now, try a sine wave at edge of a bin/channel
sine2 = 0.95*sin(2*pi*3*bin_w*t/Fs);
%process:
sine2_proc = A2_funcB(sine2, FFT_SIZE, W_TYPE, W_SIZE, IN_SIZE, OUT_SIZE);
%play input
player = audioplayer(sine2, Fs);
player.playblocking();
%play result
player = audioplayer(sine2_proc, Fs);
player.playblocking();



% Now, try a recorded sample:
[wave1, Fs] = audioread('vocal2.wav');
wave1 = wave1';
vocal_proc = A2_funcB(wave1, FFT_SIZE, W_TYPE, W_SIZE, IN_SIZE, OUT_SIZE);
%play input
player = audioplayer(wave1, Fs);
player.playblocking();
%play result
player = audioplayer(vocal_proc, Fs);
player.playblocking();

[wave2, Fs] = audioread('piano.wav');
wave2 = wave2';
wave2_proc = A2_funcB(wave2, FFT_SIZE, W_TYPE, W_SIZE, IN_SIZE, OUT_SIZE);

%play input:
player = audioplayer(wave2, Fs);
player.playblocking();
%play result
player = audioplayer(wave2_proc, Fs);
player.playblocking();