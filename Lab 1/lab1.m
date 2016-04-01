%% Lab 1
% Collaborators: Jerry H. and Paul J.
clear
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
n = ceil(chipSamp); % Samples per chip
sv1CodeSamp = repmat(sv1Code,n,1);
sv1CodeSamp = sv1CodeSamp(:);

sv2CodeSamp = repmat(sv2Code,n,1);
sv2CodeSamp = sv2CodeSamp(:);

sv3CodeSamp = repmat(sv3Code,n,1);
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
[max,phaseOffset] = max(r);

dataCorrect = data1(phaseOffset:end);

display('Part 1: PRN code offset')
display('a) chip rate = 1.023 MHz');
display('b) number of samples/chip = 15.996');
fprintf('c) The matching satellite is SV%d\n',sv);
fprintf('d) phase offset = %d\n',phaseOffset);



