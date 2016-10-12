function hs = myScatter(x, y, S, C, parent)

hold(parent, 'on');

% check that lengths are the same (USE CHECKS STOLEN FROM SCATTER!)
if length(x) > 3 % to deal with possibility of length being misused for short color matrix
    
    if (length(x) ~= length(y)) || ( (length(x) ~= length(S)) && (length(S) > 1) ) || ...
             ( (length(x) ~= length(C)) && (length(C) > 1) ) 
         disp('Length mismatch!');
    end
end

hs = zeros(length(x),1);

% get scale factor which will keep circles looking like circles when axes
% are not equal. 
set(parent, 'Units', 'pixels');
pos = get(parent, 'Position');
xlim = get(parent, 'XLim');
ylim = get(parent, 'YLim');
sfx = diff(ylim);
sfy = diff(xlim);
ar = get(parent, 'DataAspectRatio');
sfx = pos(3);
sfy = pos(4);

for ind = 1:length(x)
    
    if numel(S) > 1
        szx = sfx/S(ind);
        szy = sfy/S(ind);
    else
        szx = sfx/S;
        szy = sfy/S;
    end
    
    if size(C,1) > 1
        c = C(ind,:);
    else
        c = C;
    end
    
   hs(ind) = rectangle('Position', [(x(ind) - szx/2), (y(ind) - szy/2), szx, szy], ...
       'Curvature', [1, 1], ...  % for circle
       'FaceColor', c, ...
       'EdgeColor', 'none', ...
       'Parent', parent);

end

hold(parent, 'off');
set(parent, 'XLim', xlim);
set(parent, 'YLim', ylim);

%--------------------------------------------------------------------------
function msg = Lxychk(x,y)
msg = [];
% Verify {X,Y) data is correct size
if any([length(x) length(y) ...
        numel(x) numel(y) ] ~= length(x))
    msg = message('MATLAB:scatter:InvalidXYData');
end

 %--------------------------------------------------------------------------
function msg = Lcchk(x,c)
msg = [];
% Verify CData is correct size
if ischar(c) || isequal(size(c),[1 3]); 
    % string color or scalar rgb 
elseif length(c)==numel(c) && length(c)==length(x)
    % C is a vector
elseif isequal(size(c),[length(x) 3]), 
    % vector of rgb's
else
    msg = message('MATLAB:scatter:InvalidCData');
end

%--------------------------------------------------------------------------
function msg = Lschk(x,s)
msg = [];
% Verify correct S vector
if length(s) > 1 && ...
              (length(s)~=numel(s) || length(s)~=length(x))
    msg = message('MATLAB:scatter:InvalidSData');
end

%--------------------------------------------------------------------------

    