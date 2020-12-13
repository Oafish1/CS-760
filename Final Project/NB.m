% Read the data
data = readtable('housing-wildfire.csv');
data = table2array(data);
Y = data(:, 1);
ran=max(Y)-min(Y);
Y = (data(:, 1)>(min(Y)+ran/3))+...
    (data(:, 1)>(min(Y)+2*ran/3));Y=Y';
X = data(:, 2:end).';
type = ['g' 11 'g' 'g' 'g' 'b' 'b' 'b' 'b' 'b' 'b' 6 8];

% Random Subset
Y_unique=unique(Y);sub=[];
for i=1:size(Y_unique,2)
    f=find(Y==Y_unique(i));
    sub=[sub f(randperm(size(f,2),3000))];
end
% Shuffle
sub(randperm(size(sub,2),size(sub,2)))=sub;
% Implement
Y=Y(sub);
X=X(:,sub);

% Naive Bayes sample
% price type sqft bed bath cat dog smoking wheelchair electric_vehicle
% furnished laundry parking
% u = [1000 1 750 1 1 1 1 0 1 0 0 5 3].';
% nb(X,Y,u,type)

% Test Reliability (Takes a while)
Y_unique=unique(Y);
for i=1:size(Y_unique,2)
    ex=X(:,find(Y==Y_unique(i)));sum=0;corr=0;
    for x=1:size(ex,2)
        u=ex(:,x);
        eval=nb(X,Y,u,type);
        sum=sum+nb(X,Y,u,type);
        if eval==Y_unique(i)
            corr=corr+1;
        end
    end
    fprintf("Average output for y=%d: %.4f, %.4f accuracy\n",...
        Y_unique(i),sum/size(ex,2),corr/size(ex,2));
end

% Find Examples
% for x=1:size(X,2)
%     u=X(:,x);
%     if nb(X,Y,u,type) == 0 || nb(X,Y,u,type) == 2
%         nb(X,Y,u,type)
%         u
%     end
% end


% Naive Bayes
function r = nb(X,Y,u,type)
    % Calculate P(y)
    Y_unique = unique(Y);
    P_y = zeros( size(Y_unique) );
    
    for i = 1:size(Y_unique,2)
        P_y(i) = sum( Y == Y_unique(i) ) / size(Y,2);
    end
    
    % Calculate Product P(x|y)
    prod = ones( size(Y_unique) );
    for i = 1:size( X, 1 )
        if type(i) == 'g'
            prod = prod .* g( X(i,:),Y,u(i) );
        elseif type(i) == 'b'
            prod = prod .* b( X(i,:),Y,u(i) );
            prod = prod .* m( X(i,:),Y,u(i), type(i) );
        end
    end
    
    % Calculate P(y) * Product P(x|y)
    res = P_y .* prod;
    
    % Return most likely y
    r = Y_unique( res == max(res) );
    if size(r,2)>1
        r=mean(Y_unique);
    end
end

% Multinomial Prior Probability
function r = m(x,Y,u,K)
    Y_unique = unique(Y);
    r = zeros( 1,size(Y_unique,2) );
    
    for i = 1:size(Y_unique,2)
        r(i) = ( 1+sum( x( Y == Y_unique(i) ) == u ) )...
            / ( K+size( Y( Y == Y_unique(i) ),2 ) );
    end
end

% Bernoulli Prior Probability
function r = b(x,Y,u)
    r = m(x,Y,u,2);
end

% Gaussian Prior Probability
function r = g(x,Y,u)
    Y_unique = unique(Y);
    r = zeros( 1,size(Y_unique,2) );
    
    for i = 1:size(Y_unique,2)
        var = std( x( Y == Y_unique(i) ) )^2;
        me = mean( x( Y == Y_unique(i) ) );
        r(i) = ( ( 1/sqrt( 2*pi*var ) ) * ...
            exp( -(1/2) * ( ( u - me )^2 ) / ( var ) ) );
    end
end





