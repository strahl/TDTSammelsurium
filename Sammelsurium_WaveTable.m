function Sammelsurium_WaveTable(RP,TDT_fs)
   if (invoke(RP,'LoadCOFsf','Sammelsurium_WaveTable.rcx',TDT_fs) == 0)
      error('Could not load Sammelsurium_WaveTable.rcx');
   end;
   disp('Sammelsurium_WaveTable.rcx was loaded.');
   if (invoke(RP,'Run') == 0)
      error('RP circuit failed to run');
   end;
   disp('RP circuit is running.');
   fprintf('Idle RCX cycle usage: %d\n',invoke(RP,'GetCycUse'));
   
   samplerate  = floor(invoke(RP,'GetSFreq'));
   fprintf('TDT samplerate: %d\n',samplerate);
   wavetable{1}     = wavread('01.wav')';
   wavetable{end+1} = wavread('02.wav')';   
   wavetable{end+1} = wavread('03.wav')';
   wavetable{end+1} = wavread('04.wav')';
   wavetable{end+1} = wavread('05.wav')';
   wavetable{end+1} = wavread('06.wav')';
   wavetable{end+1} = wavread('07.wav')';
   wavetable{end+1} = wavread('08.wav')';
   wavetable{end+1} = wavread('09.wav')';
   wavetable{end+1} = wavread('10.wav')';
   wavetable_idx = [0 cumsum(cellfun(@length,wavetable))];                 % startpos of wavs in table
   
   %transfer stimulus to RP device
   assert(length([wavetable{:}]) <= 4e6,'wavetable larger than 4e6 samples')
   fprintf('Uploading wavetable (%d samples)...',length([wavetable{:}]));
   tic
   if (invoke(RP,'WriteTagVex','WaveTable',0,'F32',[wavetable{:}]) == 0) % size is  4e6 samples in Sammelsurium_ForegroundBackgroundRamBuffer.rcx
      disp('ERROR: Could not transfer wavetable to RP device');
   end;
   fprintf('done in %1.1f seconds.\n',toc);
   
   running = true;
   while (running)       
      query = sprintf('Select from wavetable [1-%d], 0 to exit.\n',length(wavetable));
      temp = input(query);
      if isempty(temp)                                                         % lazy user just pressed enter
         continue
      end;
      if ~isnumeric(temp)                                                      % which part of "number" is it that you didn't understand? ;)
         fprintf('Input "%s" is not numeric!',temp);
      else
         if (temp == 0)                                                        % 0 meanse we shall stop
            running = false;
         elseif temp > length(wavetable)
             fprintf('%d is outside wavetable [1-%d]\n',temp,length(wavetable));
         else
            invoke(RP,'SoftTrg',2);
            disp('if sound did still play it is stopped now.');
            % set where to play within wavetable
            if (invoke(RP,'SetTagVal','StartPos',wavetable_idx(temp)) == 0)
               disp('ERROR: Could not set StartPos');
            end;
            if (invoke(RP,'SetTagVal','StopPos',wavetable_idx(temp+1)-1) == 0)
               disp('ERROR: Could not set StopPos');
            end;   
            invoke(RP,'SoftTrg',1);
            disp('sound started.');            
         end
      end
   end
   
   if (invoke(RP,'Halt') == 0)
      error('RP circuit failed to halt');
   end;
   disp('RP circuit did halt.');
   
   if (invoke(RP,'ClearCOF') == 0)
      error('Could not clear program and data buffers on the processor.'); 
   end; 
   disp('Cleared program and data buffers on the processor.');
end % function ForegroundBackground