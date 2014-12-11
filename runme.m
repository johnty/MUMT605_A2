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

[wave1, Fs] = audioread('piano.wav');
sine1 = wave1';

%play original, and then stretched:
player = audioplayer(sine1, Fs);
player.playblocking();

%process sine waves
c0 = clock;
IN_SIZE = W_SIZE/4; %128
OUT_SIZE = round(1.2*W_SIZE/4);  %160

IN_SIZE = 3;
OUT_SIZE = 5;

sine1_proc = A2_funcB(sine1, FFT_SIZE, W_TYPE, W_SIZE, IN_SIZE, OUT_SIZE);
c1 = clock;
t_proc = c1-c0;
disp('time to process (s):')
disp(t_proc(6));
display('lenght of original (s):')
len_original = length(sine1)/Fs;
disp(len_original);
disp('processing speed (x realtime)');
disp(len_original/t_proc(6));

%play result

player = audioplayer(sine1_proc, Fs);
audiowrite('input.wav', sine1, Fs);
audiowrite('result.wav', sine1_proc, Fs);
player.playblocking();
%
return;

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