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
sv1CodeSamp = repmat(sv1Code,t,1);
sv1CodeSamp = sv1CodeSamp(:);

sv2CodeSamp = repmat(sv2Code,t,1);
sv2CodeSamp = sv2CodeSamp(:);

sv3CodeSamp = repmat(sv3Code,t,1);
sv3CodeSamp = sv3CodeSamp(:);

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
display('a) chip rate = 1.023 MHz');
display('b) number of samples/chip = 15.996');
fprintf('c) The matching satellite is SV%d\n',sv);
fprintf('d) phase offset = %d\n',round(phaseOffset));

%% Part 2: Carrier Frequency Modulation
load('data2.mat');
fif = 4.1304e6;
L = length(data2);
f = fs*(0:(L/2))/L;

figure
DATA = fftshift(fft(data2));
% P2 = abs(DATA/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
plot(real(DATA));
% plot(f,P1)

t = (0:length(data2)-1)/fs;

xif = cos(-2*pi*fif*t+pi/3);

x_bb = data2.*xif;

figure
X_bb = fftshift(fft(x_bb));
% P2 = abs(X_bb/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% plot(f,P1)
X_bb(1:7149) = zeros(1,7149);
X_bb(9219:end) = zeros(1,7149);
plot(real(X_bb))

% plot(x_bb);

x_bb1 = ifft(X_bb);

plot(real(x_bb1))

%8184, 9219, 7149
