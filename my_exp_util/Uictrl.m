classdef Uictrl<handle
    
    properties (GetAccess = public, SetAccess = private)
        func,argName,argValue
        h_uictrls,h_axes
        args_imshow
    end
    
    methods (Static)
        
    end
    
    methods (Access = public)
        function obj = Uictrl(func, varargin)
            obj.func = func;
            obj.argName = cell(1,numel(varargin));
            for n = 1:numel(varargin)
                obj.argName{n} = inputname(n+1);
            end
            obj.argValue = varargin;
        end
        
        function imshow(obj,varargin) % handle
            obj.h_uictrls = cell(1,numel(obj.argValue));
            obj.args_imshow = varargin;
            idx = 0;
            for n = 1:numel(obj.argValue)
                arg = obj.argValue{n};
                switch class(arg)
                    case 'Uiview'
                        idx = idx + 1;
                        obj.h_uictrls{n} = arg.plot(gca, obj.argName{n}, idx);
                        arg.setCallbackFunc(obj.h_uictrls{n},@(h,ev)obj.callback_func());
                        %obj.h_uictrls{n}.Callback = @(h,ev)obj.callback_func();
                    otherwise
                        % fixed param
                end%switch
            end%for
            
            obj.h_axes = gca;
            obj.callback_func(); % call once
            % nested callback_func is also ok
        end
        
        function callback_func(obj)
            % arg/args: read the uicontrol values
            args = obj.argValue; % do not change argValue
            
            % load args value
            fprintf(char(obj.func));
            for n = 1:numel(args)
                arg = args{n};
                switch class(arg)
                    case 'Uiview'
                        args{n} = arg.getValue(obj.h_uictrls{n});%
                        %args{n} = obj.h_uictrls{n}.Value;
                    otherwise
                        % fixed param
                end%switch
                %str = [str evalc('disp(arg)') ','];
                if n == 1, fprintf('(');
                else fprintf(',');
                end
                
                if isscalar(args{n})
                    switch class(args{n})
                        case 'function_handle'
                            fprintf('@%s',char(args{n}));
                        otherwise
                            fprintf('%f',args{n});
                    end
                elseif ischar(args{n})
                    fprintf('''%s''',args{n});
                elseif size(args{n},1)==1&&size(args{n},2)==2
                    fprintf('[%f,%f]',args{n}(1),args{n}(2));
                else fprintf('%s',obj.argName{n});
                end
            end%for
            
            %if gca ~= h, axes(h);end
            %hold on; % keep the title
            fprintf(');\n');
            imshow(obj.func(args{:}),'Parent',obj.h_axes, obj.args_imshow{:});
        end
    end% methods
end% classdef