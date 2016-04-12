function [trackResults]= tracking
% Performs code and carrier tracking
%
%[trackResults] = tracking
%
%   Outputs:
%       trackResults    - tracking results (structure array). Contains
%                       observation data from the tracking loops. All are
%                       saved every millisecond.
%
% Adapted from Borre's textbook
% Daniel Pivonka and David_Harris@hmc.edu 19 Feb 2007

%% Initialize tracking variables ==========================================

codePeriods = 37000;    % For GPS one C/A code is one ms

codePeriods = 2000;    % For GPS one C/A code is one ms

earlyLateSpc = .5;


%% Main Tracking ========================================
    
        
        % Get a vector with the C/A code sampled 1x/chip
        caCode = generateCAcode(5);

        % Then make it possible to do early and late versions
        caCode = [caCode(1023) caCode caCode(1)];

        %--- Perform various initializations ------------------------------

        % define initial code frequency basis of NCO
        codeFreq      = 1.023e6;
        codeFreqBasis = codeFreq;
        % define residual code phase (in chips)
        remCodePhase  = 0.0;
        % define carrier frequency which is used over whole tracking period
        carrFreq      = 4.1291e6;
        carrFreqBasis = 4.1291e6;
        % define residual carrier phase
        remCarrPhase  = 0.0;

        %code tracking loop parameters
        oldCodeNco   = 0.0;
        oldCodeError = 0.0;

        %carrier/Costas loop parameters
        oldCarrNco   = 0.0;
        oldCarrError = 0.0;
        sampleNum = 4507;
        sampleNum = 4504;
        
        oldCodeFreq = codeFreq;
        oldCarrFreq = carrFreq;
        
        fid = fopen('/Users/harris/Documents/Classes/E168b/E156/Charlie/TrimbleDataSet2/TrimbleDataSet2.bin');
        
        fseek(fid, ...
              sampleNum, ...
              'bof');
        %=== Process the number of specified code periods =================
        for loopCnt =  1:codePeriods-1
            

%% Read next block of data ------------------------------------------------            
            % Find the size of a "block" or code period in whole samples
            
            % Update the phasestep based on code freq (variable) and
            % sampling frequency (fixed)
            codePhaseStep = codeFreq / 16.3676e6;
            blksize = ceil((1023-remCodePhase) / codePhaseStep);
            
            [rawSignal, samplesRead] = fread(fid, ...
                                             blksize, 'int8');
            rawSignal = rawSignal';  %transpose vector
            
            if (samplesRead ~= blksize)
                disp('Not able to read the specified number of samples  for tracking, exiting!')
                return
            end
            

%% Set up all the code phase tracking information -------------------------
            % Define index into early code vector
            tcode       = (remCodePhase-earlyLateSpc) : ...
                          codePhaseStep : ...
                          ((blksize-1)*codePhaseStep+remCodePhase-earlyLateSpc);
            tcode2      = ceil(tcode) + 1;
            earlyCode   = caCode(tcode2);
            
            % Define index into late code vector
            tcode       = (remCodePhase+earlyLateSpc) : ...
                          codePhaseStep : ...
                          ((blksize-1)*codePhaseStep+remCodePhase+earlyLateSpc);
            tcode2      = ceil(tcode) + 1;
            lateCode    = caCode(tcode2);
            
            % Define index into prompt code vector
            tcode       = remCodePhase : ...
                          codePhaseStep : ...
                          ((blksize-1)*codePhaseStep+remCodePhase);
            tcode2      = ceil(tcode) + 1;
            promptCode  = caCode(tcode2);
            
            remCodePhase = (tcode(blksize) + codePhaseStep) - 1023.0;

%% Generate the carrier frequency to mix the signal to baseband -----------
            time    = (0:blksize) ./ 16.3676e6;
            
            % Get the argument to sin/cos functions
            trigarg = ((carrFreq * 2.0 * pi) .* time) + remCarrPhase;
            remCarrPhase = rem(trigarg(blksize+1), (2 * pi));
            
            % Finally compute the signal to mix the collected data to bandband
            carrCos = cos(trigarg(1:blksize));
            carrSin = sin(trigarg(1:blksize));

%% Generate the six standard accumulated values ---------------------------
            % First mix to baseband
            iBasebandSignal = carrCos .* rawSignal;
            qBasebandSignal = carrSin .* rawSignal;

            % Now get early, late, and prompt values for each
            I_E = sum(earlyCode  .* iBasebandSignal);
            Q_E = sum(earlyCode  .* qBasebandSignal);
            I_P = sum(promptCode .* iBasebandSignal);
            Q_P = sum(promptCode .* qBasebandSignal);
            I_L = sum(lateCode   .* iBasebandSignal);
            Q_L = sum(lateCode   .* qBasebandSignal);
            
%% Code and Carrier Tracking Loop ----------------------------------
            
            [carrFreq, carrError, codeFreq, codeError] = PLL(I_E, I_P, I_L, Q_E, Q_P, Q_L, ...
                                        oldCarrFreq, oldCarrError, carrFreqBasis, ...
                                        oldCodeFreq, oldCodeError, codeFreqBasis);
            oldCarrFreq   = carrFreq;
            oldCarrError = carrError;
            
            oldCodeFreq   = codeFreq;
            oldCodeError = codeError;
            
            trackResults.carrFreq(loopCnt) = carrFreq;          
            trackResults.codeFreq(loopCnt) = codeFreq;

%% Record various measures to show in postprocessing ----------------------
            % Record sample number
            trackResults.absoluteSample(loopCnt) = sampleNum;
            
            trackResults.dllDiscr(loopCnt)       = codeError;
%            trackResults.dllDiscrFilt(loopCnt)   = codeNco;
            trackResults.pllDiscr(loopCnt)       = carrError;
%            trackResults.pllDiscrFilt(loopCnt)   = carrNco;

            trackResults.I_E(loopCnt) = I_E;
            trackResults.I_P(loopCnt) = I_P;
            trackResults.I_L(loopCnt) = I_L;
            trackResults.Q_E(loopCnt) = Q_E;
            trackResults.Q_P(loopCnt) = Q_P;
            trackResults.Q_L(loopCnt) = Q_L;
        end % for loopCnt

end 




