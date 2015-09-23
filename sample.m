WindowLen = 256;
AnalysisLen = 64;
SynthesisLen = 90;
Hopratio = SynthesisLen/AnalysisLen;

hAudioSource = dsp.AudioFileReader(...
  which('speech_dft_8kHz.wav'), ...
  'SamplesPerFrame', AnalysisLen, ...
  'OutputDataType', 'double');

hbuf = dsp.Buffer(WindowLen, WindowLen - AnalysisLen);

% Create a Window System object, which is used for the ST-FFT. This object
% applies a window to the buffered input data.
hwin = dsp.Window('Hanning', 'Sampling', 'Periodic');

hfft = dsp.FFT;

% Create an IFFT System object, which is used for the IST-FFT.
hifft = dsp.IFFT('ConjugateSymmetricInput', true, ...
  'Normalize', false);

Fs = 8000;
hAudioOut = dsp.AudioPlayer('SampleRate', Fs);

% Create a System object to log your data.
hslg = dsp.SignalSink;

yprevwin = zeros(WindowLen-SynthesisLen, 1);
gain = 1/(WindowLen*sum(hanning(WindowLen,'periodic').^2)/SynthesisLen);
unwrapdata = 2*pi*AnalysisLen*(0:WindowLen-1)'/WindowLen;
yangle = zeros(WindowLen, 1);
firsttime = true;

while ~isDone(hAudioSource)
    y = step(hAudioSource);

    step(hAudioOut, y);    % Play back original audio

    % ST-FFT
    % FFT of a windowed buffered signal
    yfft = step(hfft, step(hwin, step(hbuf, y)));

    % Convert complex FFT data to magnitude and phase.
    ymag       = abs(yfft);
    yprevangle = yangle;
    yangle     = angle(yfft);

    % Synthesis Phase Calculation
    % The synthesis phase is calculated by computing the phase increments
    % between successive frequency transforms, unwrapping them, and scaling
    % them by the ratio between the analysis and synthesis hop sizes.
    yunwrap = (yangle - yprevangle) - unwrapdata;
    yunwrap = yunwrap - round(yunwrap/(2*pi))*2*pi;
    yunwrap = (yunwrap + unwrapdata) * Hopratio;
    if firsttime
        ysangle = yangle;
        firsttime = false;
    else
        ysangle = ysangle + yunwrap;
    end

    % Convert magnitude and phase to complex numbers.
    ys = ymag .* complex(cos(ysangle), sin(ysangle));

    % IST-FFT
    ywin  = step(hwin, step(hifft,ys));    % Windowed IFFT

    % Overlap-add operation
    olapadd  = [ywin(1:end-SynthesisLen,:) + yprevwin; ...
                ywin(end-SynthesisLen+1:end,:)];
    yistfft  = olapadd(1:SynthesisLen,:);
    yprevwin = olapadd(SynthesisLen+1:end,:);

    % Compensate for the scaling that was introduced by the overlap-add
    % operation
    yistfft = yistfft * gain;

    step(hslg, yistfft);     % Log signal
end

release(hAudioSource);
release(hAudioOut);

loggedSpeech = hslg.Buffer(200:end)';
% Play time-stretched signal
p2 = audioplayer(loggedSpeech, Fs);
disp('Playing time-stretched signal...');
playblocking(p2);

% Play pitch-scaled signal
% The pitch-scaled signal is the time-stretched signal played at a higher
% sampling rate which produces a signal with a higher pitch.
Fs_new = Fs*(SynthesisLen/AnalysisLen);
p3 = audioplayer(loggedSpeech, Fs_new);
disp('Playing pitch-scaled signal...');
playblocking(p3);
