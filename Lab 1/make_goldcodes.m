function codes = make_goldcodes
% makes an array containing the 1023-bit C/A codes
% for the 37 Space Vehicles (SVs)

% G1 = 1 + X^3 + X^10
% G2 = 1 + X^2 + X^3 + X^6 + X^8 + X^9 + X^10

taps = [2 6;
        3 7;
        4 8;
        5 9;
        1 9;
        2 10; 
        1 8;
        2 9;
        3 10;
        2 3;
        3 4;
        5 6;
        6 7;
        7 8;
        8 9;
        9 10;
        1 4;
        2 5;
        3 6;
        4 7;
        5 8;
        6 9;
        1 3;
        4 6;
        5 7;
        6 8;
        7 9;
        8 10;
        1 6;
        2 7;
        3 8;
        4 9;
        5 10;
        4 10;
        1 7;
        2 8;
        4 10];
    
    % Initializing vectors/matrices
    lfsr1 = [1 1 1 1 1 1 1 1 1 1];
    lfsr2 = [1 1 1 1 1 1 1 1 1 1];
    codes = zeros(37,1023);
    
    % Loop to create first chip for 37 satellites
    for i = 1:37
        G1n = lfsr1(10);
        G2n = xor(lfsr2(taps(i,1)),lfsr2(taps(i,2)));
        codes(i,1) = xor( G1n , G2n );
    end
    
    % Loop to create gold code matrix (37x1023)
    for i=2:1023   
		% Updating LFSRs (new chips)
        fb1 = xor(lfsr1(3), lfsr1(10));
        fb2 = xor(lfsr2(2), xor(lfsr2(3), xor(lfsr2(6), xor(lfsr2(8), xor(lfsr2(9), lfsr2(10))))));
        lfsr1 = [fb1 lfsr1(1:9)];
        lfsr2 = [fb2 lfsr2(1:9)];
        
        % Loop for 37 satellites
        for k = 1:37
            G1n = lfsr1(10);
            G2n = xor(lfsr2(taps(k,1)),lfsr2(taps(k,2)));
            codes(k,i) = xor( G1n , G2n );
        end       
    end
end
 
