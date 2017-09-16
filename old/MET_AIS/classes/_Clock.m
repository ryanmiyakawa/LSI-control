classdef _Clock < HandlePlus
    
    % add pause
    % 
    
    % Clock is the class that allow coherent dispatching of task over an
    % ensemble of procedures
    %
    % cl = Clock(cName)
    
    %% Properties
    
	properties
        dPeriod = 2000/1000;                 % Period
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        lEcho = false;                      % Print statements
        t                                   % Timer
        cName
        
        % Store tasks as an array of structures
        
        % Initialize 0x0 struct array with fields:
        %       fhFcn
        %       cName
        %       dPeriod
        %       dLastExecution
        %       lRemove
        stTasks = struct('fhFcn', {}, 'cName', {}, 'dPeriod', {}, 'dLastExecution', {}, 'lRemove', {}) 
        dTicks = 0;
    
    end
    
    

    
    events
        
    end
    
    methods
%% Constuctor
        
        function this = Clock(cName)
            
            this.cName = cName;
            this.init();
            
        end
        
        function init(this)
            
            % timer
            this.t =  timer( ...
                'TimerFcn', @this.timerFcn, ...
                'Period', this.dPeriod, ...
                'ExecutionMode', 'fixedRate', ...
                'Name', sprintf('Clock (%s)', this.cName) ...
                );
            start(this.t);

        end
        
%% Methods
        function lReturn = has(this, cName)
        % Clock.has(cName)  check if the task 'cName' is in the tasklist
        %
        %   cName:char         name of task (must be unique)
        %   lReturn:logical    true if the task is on the list, false otherwise

            for n = 1:length(this.stTasks)
                if strcmp(this.stTasks(n).cName, cName)
                    lReturn = true;
                    return;
                end
            end
            
            lReturn = false;
            
        end
        
        function add(this, fhFcn, cName, dPeriod)
        % Clock.remove(fhFcncName, cName, dPeriod) adds the task fhFcn to
        % the tasklist, naming it cName
        %   
        % fhFcn:function_handle;     function to call 
        % cName:char;                name of task (must be unique)
        % dPeriod:double;            execution period in seconds

        % If cName is not unique, throw an error. Uniqueness is
        % required because cName is the property that is used to remove
        % tasks from the list (because comparing function_handles does
        % not work)
            for n = 1:length(this.stTasks)
                
                %{
                cMsg = sprintf( ...
                    'Clock.add() comparing %s to %s', ...
                    this.stTasks(n).cName, ...
                    cName ...
                );
                this.msg(cMsg);
                %}
                    
                if strcmp(this.stTasks(n).cName, cName)
                    
                    % If the item is 
                    
                    err = MException( ...
                        'Clock:add', ...
                        sprintf('cName of %s already exists.  It must be unique', cName) ...
                    );
                
                    throw(err)
                end
            end
                         
            stTask.fhFcn = fhFcn;
            stTask.cName = cName;
            
            % 2013.07.31 CNA
            % Round dPeriod to nearest multiple of clock period.  This
            % makes it easier to check if the task needs to be executed in
            % the timer handler
            
            stTask.dPeriod = round(dPeriod/this.dPeriod)*this.dPeriod;
            
            
            %AW2013-7-22 : Added a warning when the added a task faster
            %than the clock refresh reate 
            %(I had some strange results from time to time...)
            if (dPeriod<this.dPeriod)
                warning('%s task has a refreshing rate faster than the clock.\nIf you use this task, you might get unexpected results\n', ...
                    cName)
            end
            stTask.dLastExecution = 0;
            stTask.lRemove = false;
            
            this.stTasks(length(this.stTasks) + 1) = stTask;
            
            cMsg = sprintf( ...
                'Clock.add() %s', ...
                this.stTasks(end).cName ...
            );
        
            this.msg(cMsg);

        end
        
        
        function remove(this, cName)
            % Clock.remove(cName) removes the task cName from the tasklist
            
            % Originally, the plan was to pass in a function handle and
            % then compare it to the stored function handles in stTasks but
            % this doesn't work.  Two handles to the same method of a class
            % instance are not the same.  
            
            % Instead, I'm passing in a unique cName to identify which task
            % we want to remove
            
            % Loop through and compare function handles in task list to the
            % function handle passed in
            
            %{
            cMsg = sprintf( ...
                'Clock.remove() %s', ...
                cName ...
            );
            this.msg(cMsg);
            %}
                                
            for n = 1:length(this.stTasks)
                
                % Attempt to use fhFcn (used to pass in fhFcn) but this
                % does not work.  
                
                %{
                
                this.stTasks(n).fhFcn
                fhFcn
                isequal(this.stTasks(n).fhFcn, fhFcn)
                
                if(isequal(this.stTasks(n).fhFcn, fhFcn))
                    this.msg('Clock.remove() %s', this.stTasks(n).cName);
                    this.stTasks(n) = [];
                    break; % terminate for loop
                end
                
                %}
                

                if strcmp(this.stTasks(n).cName, cName)
                    
                    % Flag for removal in the timerFcn
                    
                    cMsg = sprintf( ...
                        'Clock.remove() flagging %s for removal', ...
                        this.stTasks(n).cName ...
                    );
                    this.msg(cMsg);
                    
                    this.stTasks(n).lRemove = true;
                   
                    break; % terminate for loop
                    
                end %if
            end  %for loop          
        end %remove
        
        
        function stop(this)
            if isvalid(this) && ...
                    isvalid(this.t)
                
                if strcmp(this.t.Running, 'on')
                    stop(this.t);
                end
            end
        end
        
        function listTasks(this)
            cStr = 'List of running tasks :\n';
            for n = 1:length(this.stTasks)
                cStr = sprintf('%s\t%s\n',cStr,this.stTasks(n).cName);
            end
            fprintf(cStr);
        end
        
        
        
%% Modifiers
        
%% Event handlers
        function timerFcn(this, src, evt)
            if  ~isvalid(this) || ...
                ~isvalid(this.t)
                return
            end

            % dElapsedTime = this.t.TasksExecuted*this.dPeriod;
            dElapsedTime = this.dTicks*this.dPeriod;
            
            if this.lEcho
                 cMsg = sprintf( ...
                    'Clock.timerFcn() @ %1.2f with %1.0f tasks', ...
                    dElapsedTime, ...
                    length(this.stTasks) ...
                );
                this.msg(cMsg);
             end
            
            % Loop through task list. If an item is flagged for removal,
            % purge it.  It the delta time between the last execution and
            % elapsed time is larger than the period of the task, execute
            % the task, otherwise skip it.
            for n = 1:length(this.stTasks)
                
                % If a task is removed in the middle of the loop, n will be
                % one larger than length when it gets to the end.  Need to
                % escape out of this.  Should probably change to a while
                % loop with a counter.
                if n > length(this.stTasks)
                    break;
                end
                
                % If the task has been flagged for removal, remove it
                if this.stTasks(n).lRemove
                     
                    % if this.lEcho
                        cMsg = sprintf( ...
                            'Clock.timerFcn() removing %s', ...
                            this.stTasks(n).cName ...
                        );
                        this.msg(cMsg);
                    % end
                    
                    this.stTasks(n) = [];
                    continue;
                end                
                
                
                if mod(dElapsedTime, this.stTasks(n).dPeriod) == 0
                    
                % if(dElapsedTime >= this.stTasks(n).dLastExecution + this.stTasks(n).dPeriod)
                    
                    % Execute fhFcn() and update dLastExecution
                    try
                        
                        
                        %{
                        % Message
                        f = functions(this.stTasks(n).fhFcn);
                        cMsg = sprintf( ...
                            'Clock.timerFcn() executing %s.%s file: %s', ...
                            this.stTasks(n).cName, ...
                            f.function, ...
                            f.file ...
                        );
                        %}
                        
                        %{
                        if this.lEcho
                            cMsg = sprintf( ...
                                'Clock.timerFcn() executing %s.%s', ...
                                this.stTasks(n).cName, ...
                                f.function ...
                            );
                            this.msg(cMsg);
                        end
                        %}
                        
                        if this.lEcho
                            cMsg = sprintf( ...
                                'Clock.timerFcn() executing %s', ...
                                this.stTasks(n).cName ...
                            );
                            this.msg(cMsg);
                        end
                        
                        
                        
                        % Execute
                        this.stTasks(n).fhFcn();
                        this.stTasks(n).dLastExecution = dElapsedTime;
                        
                    catch err
                        this.msg(getReport(err));
                        rethrow(err);
                    end
                                        
                else
                    % Message
                    if this.lEcho
                        cMsg = sprintf( ...
                            'Clock.timerFcn() skipping %s', ...
                            this.stTasks(n).cName, ...
                            dElapsedTime ...
                        );
                        this.msg(cMsg);
                    end
                    
                end
            end
            
            this.dTicks = this.dTicks + 1;
            
        end
%% Save & Load
        function save(this)
            %
        end
        
        function load(this)
            %
        end
        

        
%% Destructor
        function delete(this)
            
            this.msg('Clock.delete()');
            
            try
                if isvalid(this.t)
                
                    if strcmp(this.t.Running, 'on')
                        stop(this.t);
                    end
                    
                    this.msg('Clock.delete() deleting timer');

                    set(this.t, 'TimerFcn', '');
                    delete(this.t);
                end
                
            catch err
                this.msg(getReport(err));
            end
                
            
        end
        
%% Prototyping zone



    end
    
    
end