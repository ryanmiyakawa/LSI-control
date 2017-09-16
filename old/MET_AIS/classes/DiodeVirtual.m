classdef DiodeVirtual < HandlePlus
%DIODEVIRTUAL Class that simulates the behaviour of a diode
%
% See also DIODE, AXISVIRTUAL

    properties
        cName   % name identifier
        dVolts  % current virtual reading
    end
    
    
    properties (Access = private)
        cl              % clock
        dPeriod = 0.1   % self-refresh period
    end

    
    methods
        
        function this = DiodeVirtual(cName, cl)
        %DIODEVIRTUAL Class constuctor
        %   dv = DiodeVirtual('name', clock)

            this.cName = cName;
            this.dVolts = 5;
            this.cl = cl;

            %{
            this.t = timer( ...
                'TimerFcn', @this.cb, ...
                'Period', 0.2, ...
                'ExecutionMode','fixedRate',...
                'Name', sprintf('DiodeVirtual (%s)', this.cName) ...
                );
            start(this.t);
            %}
            
            this.cl.add(@this.handleClock, this.id(), this.dPeriod);
        end

        function out = volts(this)
        %VOLTS Outputs the current virtual reading
        %   out = DiodeVirtual.volts()
        
           out = this.dVolts; 
        end

        
        function handleClock(this)
        %HANDLECLOCK Callback used by the clock to update the reading
            this.dVolts = 5 + 0.3*rand(1);
        end
        
        
        function delete(this)
        %DELETE Class destructor
        %   DiodeVirtual.delete()
        %   Removes the diode from the clock tasklist
        
            if ~isempty(this.cl) && this.cl.has(this.cName)
                this.cl.remove(this.id());
            end

            this.msg('DiodeVirtual.delete()');

            %{
            % timer
            if isvalid(this.t)
                if strcmp(this.t.Running, 'on')
                    stop(this.t);
                end
                set(this.t, 'TimerFcn', '');
                delete(this.t);
            end
            %}
        end
        
        %% LEGACY
        %{
        % Legacy timerFcn
        function cb(this, evt, src)
            this.dVolts = 5 + 0.3*rand(1);
        end
        %}
        
%         function enable(this)
%         end
% 
%         function disable(this)
%         end
    end
end





