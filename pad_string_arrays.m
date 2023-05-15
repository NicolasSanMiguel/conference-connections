function [out1, out2] = pad_string_arrays(str1, str2)
% Nicolas San Miguel
% May 2023

% Pad two string arrays with empty strings to make them the same length.
% NOTE: TAKES IN VERTICAL STRING ARRAYS e.g. 15x1 and 7x1.
% Get the lengths of the input arrays
% n1 = length(str1);
% n2 = length(str2);
r1 = size(str1,1); % number of rows, input 1
r2 = size(str2,1); % number of rows, input 2
c1 = size(str1,2); % number of columns, input 1
c2 = size(str2,2); % number of columns, input 2

% Pad the shorter array with empty strings
if r1 < r2
    str1_padded = [str1; repmat("", r2-r1, c1)];
    str2_padded = str2;
elseif r2 < r1
    str1_padded = str1;
    str2_padded = [str2; repmat("", r1-r2, c2)];
else
    % If the arrays are already the same length, don't pad them
    str1_padded = str1;
    str2_padded = str2;
end

out1 = str1_padded;
out2 = str2_padded;
end
