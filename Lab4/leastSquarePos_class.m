function [phi, lambda, h] = leastSquarePos_class(satpos, obs)
  
nmbOfIterations = 7;

X     = zeros(4, 1);
nmbOfSatellites = size(satpos, 2);
A       = zeros(nmbOfSatellites, 4);
b = obs';

%=== Iteratively find receiver position ===================================
for iter = 1:nmbOfIterations
    
    for i = 1:nmbOfSatellites
        if iter == 1
            %--- Initialize variables at the first iteration --------------
            S = satpos(:, i);
            rho2 = (satpos(1, i) - X(1))^2 + (satpos(2, i) - X(2))^2 + ...
                   (satpos(3, i) - X(3))^2;
        else
            %--- Update equations -----------------------------------------
            rho2 = (satpos(1, i) - X(1))^2 + (satpos(2, i) - X(2))^2 + ...
                   (satpos(3, i) - X(3))^2;
            traveltime = sqrt(rho2) / 299792458;
            S = e_r_corr(traveltime, satpos(:, i));
        end % if iter == 1 ... ... else 
        b(i) = (obs(i) - X(4) - ...
                sqrt((S(1)-X(1))^2 + (S(2)-X(2))^2 + (S(3)-X(3))^2));
        %--- Construct the A matrix ---------------------------------------\
        % Insert your code here
        A(i,:) = [(X(1) - S(1))/sqrt(rho2),...
                  (X(2) - S(2))/sqrt(rho2),...
                  (X(3) - S(3))/sqrt(rho2),...
                  1];

    end % for i = 1:nmbOfSatellites

    % These lines allow the code to exit gracefully in case of any errors
    if rank(A) ~= 4
        X     = zeros(1, 4);
        return
    end

    %--- Find position update ---------------------------------------------
    % Insert your code here to compute solve Adelta = b for delta using least
    % squares.
    delta = A\b;
    
    %--- Apply position update --------------------------------------------
    X = X + delta;
    
end % for iter = 1:nmbOfIterations

X = X';
[phi, lambda, h] = cart2geo(X(1), X(2), X(3), 5);




