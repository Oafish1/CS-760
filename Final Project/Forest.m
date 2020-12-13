% Read the Data
data = readtable('housing-wildfire.csv');
data = table2array(data);
Y = data(:, 1);
ran=max(Y)-min(Y);
Y = (data(:, 1)>(min(Y)+ran/3))+...
    (data(:, 1)>(min(Y)+2*ran/3));Y=Y';
X = data(:, 2:end).';
names = ["PRI","TYP","SQU","BED","BAT","CAT","DOG",...
    "SMO","WHE","ELE","FUR","LAU","PAR"];

% Transform the Data
thresh=X>[2893 inf 1067 1 1 .5 .5 .5 .5 .5 .5 1 inf].';
apt=X>[inf 1 inf*ones(1,11)].';
park=(X==[inf*ones(1,12) 0].')+(X==[inf*ones(1,12) 6].');
park(end,:)=park(end,:)==0;
X=thresh+apt+park;X=X>=1;

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
X_size=size(X);

% Create Tree
% tree = Node(X, Y, 0, 0);

% -----
% Values for the following forest (k_f is number of trees)
% If an error is thrown, the thresholds are too high.
data_thresh=500;info_thresh=0.015;k_f=5;

fprintf("\nRandom Forest\n");
% Random Forest: K-Fold Cross-Validation
k = 10;
samples = floor(X_size(2) / k);

correct_hist = zeros(k, 1);
for i = 1:samples:(k*samples)
    % Define training and validation subsamples
    X_tra = X;
    X_tra( :, i:(i+samples-1) ) = [];
    Y_tra = Y;
    Y_tra( i:(i+samples-1) ) = [];
    
    X_val = X( :, i:(i+samples-1) );
    Y_val = Y( i:(i+samples-1) );
    
    % Create tree
    % Random forest
    samples_f = floor( .8 * samples );
    trees = {};
    for j = 1:k_f
        r = randperm( samples, samples_f );
        X_tra_f = X_tra(:, r);
        Y_tra_f = Y_tra(r);
        trees{j} = Node(X_tra_f, Y_tra_f, info_thresh, .8*data_thresh/k);
    end
    
    % Test accuracy
    correct = 0;
    for j = 1:samples
        % Predict
        pred = 0;
        for m = 1:k_f
            pred = pred + trees{m}.eval( X_val(:, j) );
        end
        pred = round(pred / k_f);
        
        % Add acc
        correct = correct + ( Y_val(j) == pred );
    end
    
    % Store best forest
    if correct > max(correct_hist)
        trees_max = trees;
    end
    
    % Store historical accuracy
    correct_hist( 1 + (i-1) / samples ) = correct / samples;
end

% Print statistics
% correct_hist
% mean(correct_hist)

% Print Forest
for m = 1:k_f
    fprintf(trees_max{m}.toString(names)+'\n');
end

% Calculate acc
correct = 0;
for j = 1:size(X,2)
    pred = 0;
    for m = 1:k_f
        pred = pred + trees_max{m}.eval( X(:, j) );
    end
    pred = round(pred / k_f);
    correct = correct + ( Y(j) == pred );
end
fprintf("Accuracy: %.4f\n",correct / size(X,2));


% -----
% Values for the following forest (k_f is number of trees)
% If an error is thrown, the thresholds are too high.
data_thresh=500;info_thresh=0.012;k_f=5;

fprintf("\nElimination Forest\n");
% Elimination Forest: K-Fold Cross-Validation
k = 10;
samples = floor(X_size(2) / k);

correct_hist = zeros(k, 1);
for i = 1:samples:(k*samples)
    % Define training and validation subsamples
    X_tra = X;
    X_tra( :, i:(i+samples-1) ) = [];
    Y_tra = Y;
    Y_tra( i:(i+samples-1) ) = [];
    
    X_val = X( :, i:(i+samples-1) );
    Y_val = Y( i:(i+samples-1) );
    
    % Create trees
    trees = {};
    for j = 1:X_size(1)
        X_tra_f = X_tra;
        X_tra_f(j, :) = [];
        trees{j} = Node(X_tra_f, Y_tra, info_thresh, data_thresh);
    end
    
    % Test accuracy
    correct = 0;
    for j = 1:samples
        pred = 0;
        for m = 1:X_size(1)
            X_val_temp = X_val;
            X_val_temp(m, :) = [];
            pred = pred + trees{m}.eval( X_val_temp(:, j) );
        end
        pred = round( pred / X_size(1) );
        correct = correct + ( Y_val(j) == pred );
    end
    
    % Store best tree
    if correct > max(correct_hist)
        trees_max = trees;
    end
    
    % Store historical accuracy
    correct_hist( 1 + (i-1) / samples ) = correct / samples;
end

% Print statistics
% correct_hist
% mean(correct_hist)

% Print Forest
for m = 1:X_size(1)
    fprintf(trees_max{m}.toString(names)+'\n');
end

% Calculate acc
correct = 0;
for j = 1:X_size(2)
    pred = 0;
    for m = 1:X_size(1)
        X_temp = X;
        X_temp(m, :) = [];
        pred = pred + trees_max{m}.eval( X_temp(:, j) );
    end
    pred = round( pred / X_size(1) );
    correct = correct + ( Y(j) == pred );
end
fprintf("Accuracy: %.4f\n",correct / X_size(2));