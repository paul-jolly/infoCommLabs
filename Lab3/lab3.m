%% Lab 3
clear
close all

load('tracking_data.mat');

% Creating preample and upsampling
preamble = [1 -1 -1 -1 1 -1 1 1 zeros(1,292)];
preamble = repelem(preamble,20);

% Repeating preamble for longer correlation
% Comment line below for manual correlation
preambleSubframe = repmat(preamble,[1 6]);

% Uncomment line below for manual correlation
% preambleSubframe = repmat(preamble,[1 5]); 

% Manual Correlation (Uncomment below section)
% Icorr = zeros(1,6000);
% for i=1:6000
%     temp = data.I_E(i:end);
%     Icorr(i) = sum(temp(1:30000).*preambleSubframe);
% end
% 
% [~,ind] = max(abs(Icorr));

% Correlation using xcorr
[r,lags] = xcorr(data.I_E,preambleSubframe);


% Finding offset
[~,sampleOffset] = max(abs(r));
lagdiff = lags(sampleOffset);

% Applying correction
dataSamp = data.I_E(lagdiff:end);

% Converting 1ms to 20ms data bits through averaging
dataBits = zeros(1,27940/20);
for i=1:27940/20
    ind = 1+20*(i-1);
    avg = mean(dataSamp(ind:ind+20));
    if avg > 0
        dataBits(i) = 1;
    else
        dataBits(i) = 0;
    end
end

% Extracting relevant information
TLM = dataBits(1:30);
TOW = dataBits(31:47); %11000010010111010
sID = dataBits(50:52);
        