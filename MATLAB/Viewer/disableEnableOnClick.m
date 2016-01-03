% function [hout, output] = disableEnableOnClick(varargin)
% 
%     h = varargin{1};
%     fs = fields(h);
%     
%     if nargin == 1
%         %% ...then we have a handles structure being passed and we should
%         %% remove onclick functions from axes and store in output struct
%         for ind = 1:length(fs)
%             try
%                 if strcmp(get(h.(fs{ind}), 'Type'), 'axes')
%                     output{ind}.Field = fs{ind};
%                     output{ind}.ButtonDownFcn = get(h.(fs{ind}), 'ButtonDownFcn');
%                     set(h.(fs{ind}), 'ButtonDownFcn', '');
%                 end
%             end
%         end
%         hout = h;
%         
%     elseif nargin == 2
%         %% ... then we have both a hanldes structure and a temporary store 
%         %% of onclick functions to be restored. 
%         input =  varargin{2};
%         for ind = 1:length(fs)
%             for jind = 1:length(input)
%                 if strcmp(fs{ind}, input{jind}.Field)
%                     set(h.fs{ind}, 'ButtonDownFcn', input(jind).ButtonDownFcn);
%                 end
%             end
%         end    
%         hout = h;
% 
% end

function [buttonDownFcns, axAndPlotHandles] = disableEnableOnClick(varargin)
%% either axHandles or axHandles and buttonDownFcns passed. 
axAndPlotHandles = varargin{1};

if nargin == 1
    for ind = 1:length(axAndPlotHandles)
        buttonDownFcns{ind} = get(axAndPlotHandles(ind), 'ButtonDownFcn');
    end
elseif nargin == 2
    buttonDownFcns = varargin{2};
    for ind = 1:length(axAndPlotHandles)
        set(axAndPlotHandles(ind), 'ButtonDownFcn', buttonDownFcns(2*ind - 1:2*ind))
    end
end

        
    