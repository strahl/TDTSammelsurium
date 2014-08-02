% Sammelsurium.m contains Matlab code to control example circuits stored in Sammelsurium_<name>.rcx
% $Id$
function Sammelsurium
   fig     = figure;                             % open figure where TDT ActiveX control needs to live on
   TDT     = getTDTENums();                      % store some TDT interna in human readable format
   
   RP = actxcontrol('RPco.x');
   zBUS = actxcontrol('ZBUS.x');
   invoke(RP,'ClearCOF');
   disp('Trying to connect to RM1 via USB...');
   if (invoke(RP,'ConnectRM1','USB',1) == 1) % first try to connect to RM1 via USB
      disp('RM1 connected via USB. Now connecting with zBUS.');
      if zBUS.ConnectZBUS('USB') 
         disp('Connected with ZBUS.');
      else 
         error('Unable to connect ZBUS.');
      end      
   else
      disp('No RM1 via USB found. Trying to connect to RP2 via GB/OB...');
      if (invoke(RP,'ConnectRP2','GB',1) == 1)
         disp('RP2 connected via GB. Now connecting with zBUS.');
         if zBUS.ConnectZBUS('GB') 
            disp('Connected with ZBUS.'); 
         else 
            error('Unable to connect ZBUS.');
         end      
      else
         error('No RM1 via USB or RP2 via GB/OB found.');
      end
   end
            
   temp = dir('Sammelsurium_*.rcx');                                           % automatically get what example circuits are available
   query = 'Please select TDT circuit to run by entering its number:\n';       % auto-generate menu containing example circuits
   TDT_circuits = {};
   for i=1:length(temp)                                                        % for all found Sammelsurium_*.rcx files
      TDT_circuits{i} = temp(i).name(14:end-4);                                % remember their name
      query = [query num2str(i) ': ' TDT_circuits{i} '\n'];                    % add the to the menu :P
   end
   query = [query 'Enter 0 to exit.\n'];
   
   running = true;   
   while(running)
      fprintf('\n=== Menu === (Current cycle usage: %d)\n',invoke(RP,'GetCycUse'));
      temp = input(query);                                                     % get user input
      if isempty(temp)                                                         % lazy user just pressed enter
         continue
      end;
      if ~isnumeric(temp)                                                      % which part of "number" is it that you didn't understand? ;)
         fprintf('Input "%s" is not numeric!',temp);
      else
         if (temp == 0)                                                        % 0 meanse we shall stop
            running = false;
         elseif (temp > length(TDT_circuits)) || (temp < 0)                    % it was a number but nothing we could use...
            fprintf('Input %d is not an option!',temp);
         else
            fprintf('== %s ==\n',TDT_circuits{temp});
            eval(['Sammelsurium_' TDT_circuits{temp} '(RP,TDT.fs_50K);']);     % call the accompanying Matlab code to the selected RCX
         end % if (temp == 0)
      end % ~isnumeric(temp)
   end %  while(running)
   invoke(RP,'Halt');                                                          % tidy up...
   invoke(RP,'ClearCOF');
   close (fig);
end % function Sammelsurium

function TDT = getTDTENums
   TDT = [];
   % see ActiveX Reference Manual "LoadCOFsf"
   TDT.fs_6K   = 0;
   TDT.fs_12K  = 1;
   TDT.fs_25K  = 2;
   TDT.fs_50K  = 3;
   TDT.fs_100K = 4;
   TDT.fs_200K = 5;
   TDT.fs_400K = 6; 
end % function getTDTENums