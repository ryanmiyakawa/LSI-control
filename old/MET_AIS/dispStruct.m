function dispStruct(sStruct, sIndent, depth)

if nargin < 2
    sIndent = '';
    depth = 0;
end

if depth == 0
    fprintf('\nSTRUCTURE DATA:\n\n');
end

sFieldNames = fieldnames(sStruct);
for k = 1:length(sFieldNames)
    oVal = sStruct.(sFieldNames{k});
    fprintf('%s %12s: ', sIndent, sFieldNames{k});
    
    if isstruct(oVal)
        fprintf('--> \n');
        dispStruct(oVal, [sIndent '              '], depth + 1);
        
    else
        writeType(oVal);
    end
end
if depth > 0
    fprintf('%s %12s ', ' ', ' ');
    fprintf('<--\n');
end



function writeType(oVal)
if isempty(oVal)
    fprintf('[]\n');
elseif islogical(oVal)
    fprintf('%d\n', oVal);
    return
elseif isnumeric(oVal)
    
    if oVal > 1e6 || oVal < .01
        fprintf('%0.2e\n', oVal);
    else
        fprintf('%0.2f\n', oVal);
    end
    return
elseif ischar(oVal)
    fprintf('%s\n', oVal);
    return
end

% unrecognized type:
fprintf('Unknown value \n', oVal);


