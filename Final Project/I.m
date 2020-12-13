% Mutual information
function r = I(x, y)
    r = H(x) - Hc(x, y);
end

% Entropy (Takes column vectors)
function total = H(x)
    x_unique = unique(x);
    x_size = size(x);
    
    total = 0;
    
    for i = 1:size(x_unique)
        p = sum( x == x_unique(i) ) / x_size(1);
        
        total = total + p * log2(1/p);
    end
end

% Conditional Entropy (Takes column vectors)
function total = Hc(x, y)
    x_unique = unique(x);
    x_size = size(x);
    
    y_unique = unique(y);
    y_size = size(y);
    
    total = 0;
    
    for i = 1:size(x_unique)
        for j = 1:size(y_unique)
            % P(x,y)
            p = sum( ( x == x_unique(i) ) .* ( y == y_unique(j) ) ) / x_size(1);
            % P(x|y)
            pd = sum( ( x == x_unique(i) ) .* ( y == y_unique(j) ) ) / sum( y == y_unique(j) );
            
            temp = p * log2(1/pd);
            if ~isnan(temp)
                total = total + temp;
            end
        end
    end
end