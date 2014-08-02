function Sammelsurium_WaveTableSequencer(RP,TDT_fs)
   if (invoke(RP,'LoadCOFsf','Sammelsurium_WaveTableSequencer.rcx',TDT_fs) == 0)
      error('Could not load Sammelsurium_WaveTableSequencer.rcx');
   end;
   disp('Sammelsurium_WaveTableSequencer.rcx was loaded.');
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
       query = sprintf('Enter sequence of wavetable numbers [1-%d] separated by "," (e.g. 1,2,3) - 0 to exit.\n',length(wavetable));
       temp = input(query,'s');
       if isempty(temp)                                                         % lazy user just pressed enter
           continue
       end;
       if strcmp(temp,'0')
           running = false;
           continue
       end;
       sequence = sscanf(temp,'%d,');
       if (invoke(RP,'SetTagVal','SeqLen',length(sequence)) == 0)
           disp('ERROR: Could not set SeqLen');
       end;
       if (invoke(RP,'WriteTagVex','StartPos',0,'F32',wavetable_idx(sequence)) == 0)
           disp('ERROR: Could not set StartPos');
       end;
       if (invoke(RP,'WriteTagVex','StopPos',0,'F32',wavetable_idx(sequence+1)-1) == 0)
           disp('ERROR: Could not set StopPos');
       end;
       invoke(RP,'SoftTrg',2); % stop possible audio play
       invoke(RP,'SoftTrg',3); % reset Counter and Sequence Start/Stop List
       invoke(RP,'SoftTrg',1); % start audio play (will loop)
       temp = input('sound started. Please press Return to stop');
       invoke(RP,'SoftTrg',2); % stop possible audio play
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