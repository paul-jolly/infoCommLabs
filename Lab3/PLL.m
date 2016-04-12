function [carrFreq, carrError, codeFreq, codeError] = PLL(I_E, I_P, I_L, Q_E, Q_P, Q_L, ...
                                        oldCarrFreq, oldCarrError, carrFreqBasis, ...
                                        oldCodeFreq, oldCodeError, codeFreqBasis);

                                 
    % Carrier loop update                                
    BW = 25; Zeta = 0.7; Gain = 0.25;
    
    omegan = BW * Zeta * 8 / (4*Zeta*Zeta+1);
    tau1 = Gain / (omegan^2);
    tau2 = 2 * Zeta / omegan;
    PDI  = 1e-3; % why
    k1 = tau2 / tau1;
    k2 = PDI/tau1;
%    k1 = 0; k2 = 100;
%    k1 = 0; k2 = 1;
    
    carrError = atan(Q_P/I_P)/(2*pi);
    deltaFCarr = k1* (carrError - oldCarrError) + k2 * carrError;
    carrFreq = oldCarrFreq - deltaFCarr;
    
    % code loop update
    BW = 2; Err = 0.7; Gain = 1;
    
    omegan = BW * Zeta * 8 / (4*Zeta*Zeta+1);
    tau1 = Gain / (omegan^2);
    tau2 = 2 * Zeta / omegan;
    PDI  = 1e-3; % why
    k1 = tau2 / tau1;
    k2 = PDI/tau1;
 %   k1 = 0.002; k2 = 0.0127;
    
    codeError = ((I_E^2 + Q_E^2) - (I_L^2 + Q_L^2))/((I_E^2 + Q_E^2) + (I_L^2 + Q_L^2));
    deltaFCode = k1 * (codeError - oldCodeError) + k2 * codeError;
    codeFreq = oldCodeFreq - deltaFCode;
    