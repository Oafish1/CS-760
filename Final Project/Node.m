% Tree creation and storage class
classdef Node
    properties
        next % Array containing the next node for each option
        index % Variable to split
        leaf % Return value if leaf
    end
    methods
        function obj = Node(X, Y, thresh, min_samples)
            X_size = size(X);
            
            obj.leaf = -1;
            
            max_index = -1;
            max = 0;
            
            % Determine var with most mutual information
            if (X_size(2) >= min_samples) % Negatives produce errors
                for i = 1:X_size(1)
                    temp = I( X(i, :).', Y.');
                    
                    if temp > max
                        max = temp;
                        max_index = i;
                    end
                end
            end
            
            % Determine leaf or not
            if ( max > thresh )
                obj.index = max_index;
                
                % Separate the data
                X_0 = X(:, X(obj.index, :) == 0);
                X_1 = X(:, X(obj.index, :) == 1);
                Y_0 = Y(X(obj.index, :) == 0);
                Y_1 = Y(X(obj.index, :) == 1);
                
                % Remove datapoints from input
                X_0(obj.index, :) = [];
                X_1(obj.index, :) = [];
                obj.next = [Node(X_0, Y_0, thresh, min_samples), ...
                    Node(X_1, Y_1, thresh, min_samples)];
            else
                % floor() is needed here to resolve ties
                obj.leaf = floor(median(Y));
            end
        end
        
        function r = eval(obj, x)
            if obj.leaf == -1
                % Get next node
                n = obj.next( x(obj.index) + 1 );
                
                % Remove datapoint from input
                x_new = x;
                x_new(obj.index, :) = [];
                
                % Recurse
                r = n.eval(x_new);
            else
                r = obj.leaf;
            end
        end
        
        function str = toString(obj, names)
            space = '';
            new_names = names;
            new_names(obj.index) = [];
            
            if obj.leaf == -1
                str = names(obj.index) + ...
                    '(' + space + ...
                    obj.next(1).toString(new_names) + ...
                    space + ',' + space + ...
                    obj.next(2).toString(new_names) + ...
                    space + ')';
            else
                str = obj.leaf;
            end
        end
    end
end