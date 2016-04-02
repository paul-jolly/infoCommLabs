%% Lab 1
% Collaborators: Jerry H. and Paul J.
clear
close all
%% Part 1: PRN code offset
load('data1.mat');
% Definitions and constants
chipRate = 1023/1e-3;
fs = 16.3676e6;              % sampling rate of PRN code
chipSamp = fs/chipRate;      % samples per chip
gold_codes = make_goldcodes; % array of gold codes for 37 satellites

% Extracting gold codes for SV1, SV2, and SV3
sv1Code = gold_codes(1,:);
sv2Code = gold_codes(2,:);
sv3Code = gold_codes(3,:);

% Extending gold codes to match samples per chip
% (Repeating each chip n times)
t = ceil(chipSamp); % Samples per chip
sv1CodeSamp = repelem(sv1Code,t);
sv2CodeSamp = repelem(sv2Code,t);
sv3CodeSamp = repelem(sv3Code,t);

% Correlating data1 with each satellite code
[r1,lags1] = xcorr(data1,sv1CodeSamp);
[r2,lags2] = xcorr(data1,sv2CodeSamp);
[r3,lags3] = xcorr(data1,sv3CodeSamp);

% Choosing correct satellite
if (max(r3)>max(r2))
    if (max(r3)>max(r1))
        r = r3;
        lags = lags3;
        sv = 3;
    else
        r = r1;
        lags = lags1;
        sv = 1;
    end
elseif (max(r2)>max(r1))
    r = r2;
    lags = lags2;
    sv = 2;
else
    r = r1;
    lags = lags1;
    sv = 1;
end

% Finding offset
[~,sampleOffset] = max(r);
lagdiff = lags(sampleOffset);
chipDelay = lagdiff/chipSamp;   % Convert to chip
phaseOffset = 1023 + chipDelay; % Delay in next code cycle

% Display answers
display('Part 1: PRN code offset')
display('1) chip rate = 1.023 MHz');
display('2) number of samples/chip = 15.996');
fprintf('3) The matching satellite is SV%d\n',sv);
fprintf('4) phase offset = %d\n',round(phaseOffset));

%% Part 2: Carrier Frequency Modulation
load('data2.mat');
fif = 4.1304e6;
L = length(data2);
f = fs*(0:(L/2))/L;

% Demodulate signal
t = (0:length(data2)-1)/fs;
xif = cos(2*pi*fif*t+pi/3);
x_bb = data2.*xif;

% Plots limited to .02 ms
figure
plot(t,data2)
title('Data before Demodulation')
xlabel('Samples(n)')
ylabel('Amplitude')
xlim([0,2e-5])

figure
plot(t,x_bb)
title('Data after Demodulation')
xlabel('Samples(n)')
ylabel('Amplitude')
xlim([0,2e-5])

% Extracting gold codes for SV7, SV8, and SV9
sv7Code = gold_codes(7,:);
sv8Code = gold_codes(8,:);
sv9Code = gold_codes(9,:);

% Extending gold codes to match samples per chip
% (Repeating each chip n times)
t = ceil(chipSamp); % Samples per chip
sv7CodeSamp = repelem(sv7Code,t);
sv8CodeSamp = repelem(sv8Code,t);
sv9CodeSamp = repelem(sv9Code,t);

% Correlating data2 with each satellite code
[r7,lags7] = xcorr(x_bb,sv7CodeSamp);
[r8,lags8] = xcorr(x_bb,sv8CodeSamp);
[r9,lags9] = xcorr(x_bb,sv9CodeSamp);

% Choosing correct satellite
if (max(r9)>max(r8))
    if (max(r9)>max(r7))
        r = r9;
        lags = lags9;
        sv = 9;
    else
        r = r7;
        lags = lags7;
        sv = 7;
    end
elseif (max(r8)>max(r7))
    r = r8;
    lags = lags8;
    sv = 8;
else
    r = r7;
    lags = lags7;
    sv = 7;
end

% Finding offset
[~,sampleOffset] = max(r);
lagdiff = lags(sampleOffset);
chipDelay = lagdiff/chipSamp;   % Convert to chip
phaseOffset = 1023 + chipDelay; % Delay in next code cycle

% Display answers
display('Part 2: Carrier Frequency Modulation')
display('5) The first 4 chips of the signal are 0111');
fprintf('6) The matching satellite is SV%d\n',sv);
display('7) phase offset = 807.5');

%% Part 3: GPS satellite acquisition with known carrier frequency and phase
load('TrimbleDataSet.mat')
fif = 4.12891e6;

figure
plot(samples)

% Extracting gold codes for SV4 and SV5
sv4Code = gold_codes(4,:);
sv5Code = gold_codes(5,:);

% Extending gold codes to match samples per chip
% (Repeating each chip n times)
t = ceil(chipSamp); % Samples per chip
sv4CodeSamp = repelem(sv4Code,t);
sv4CodeSamp = repmat(sv4CodeSamp,1,5);
sv5CodeSamp = repelem(sv5Code,t);
sv5CodeSamp = repmat(sv5CodeSamp,1,5);

close all

% Demodulate signal
t = (0:length(samples)-1)/fs;
xif = (cos(2*pi*fif*t+5*pi/4))';
x_bb = samples.*xif;

% Correlating data1 with each satellite code
[r4,lags4] = xcorr(x_bb,sv4CodeSamp);
[r5,lags5] = xcorr(x_bb,sv5CodeSamp);