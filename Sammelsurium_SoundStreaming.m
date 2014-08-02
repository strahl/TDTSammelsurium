function Sammelsurium_SoundStreaming(RP,TDT_fs)
   if (invoke(RP,'LoadCOFsf','Sammelsurium_SoundStreaming.rcx',TDT_fs) == 0)
      error('Could not load Sammelsurium_SoundStreaming.rcx');
   end;
   disp('Sammelsurium_SoundStreaming.rcx was loaded.');
   if (invoke(RP,'Run') == 0)
      error('RP circuit failed to run');
   end;
   disp('RP circuit is running.');
   fprintf('Idle RCX cycle usage: %d\n',invoke(RP,'GetCycUse'));
   
   samplerate  = floor(invoke(RP,'GetSFreq'));
   fprintf('TDT samplerate: %d\n',samplerate);
   
% USB transfers are limited to 100,000 samples per second of 32-bit data.
% Data reduction techniques, such as CompTo16 (Compress to 16) and ShufTo16 (Shuffle to 16), reduce the data size. 
% The Gigabit transfer rate is limited to 400,000 samples per second of 32-bit data.
% This should allow 50 kHz even without ComTo16 bitpacking :)

   waveforms{1}     = newMakeVowel(0.25, samplerate, 125, 250, 595,0,0);  % 0.25 sec u vowel
   waveforms{end+1} = newMakeVowel(0.25, samplerate, 125, 390,2300,0,0);  % 0.25 sec e vowel
   waveforms{end+1} = newMakeVowel(0.25, samplerate, 125, 240,2400,0,0);  % 0.25 sec i vowel
   waveforms{end+1} = newMakeVowel(0.25, samplerate, 125, 820,1610,0,0);  % 0.25 sec a vowel
   waveforms{end+1} = newMakeVowel(0.25, samplerate, 125, 360, 640,0,0);  % 0.25 sec o vowel
   
   if (invoke(RP,'SetTagVal','nSamples',ceil(samplerate)) == 0) % set streaming buffer to 1 second
      disp('ERROR: Could not set nSamples');
   end;

   %transfer stimulus to RP device
   id = 0;
   fprintf('Uploading into 0-0.25 sec of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
   tic
   if (invoke(RP,'WriteTagVex','StreamRingBuffer',0,'F32',waveforms{id+1}) == 0)
      disp('ERROR: Could not transfer waveform to RP device');
   end;
   fprintf('done in %1.1f seconds.\n',toc);
    
   %transfer stimulus to RP device
   id = mod(id + 1,length(waveforms));
   fprintf('Uploading into 0.25-0.5 of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
   tic
   if (invoke(RP,'WriteTagVex','StreamRingBuffer',length(waveforms{id+1}),'F32',waveforms{id+1}) == 0)
      disp('ERROR: Could not transfer waveform to RP device');
   end;
   fprintf('done in %1.1f seconds.\n',toc);

   %transfer stimulus to RP device
   id = mod(id + 1,length(waveforms));
   fprintf('Uploading into 0.5-0.75 of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
   tic
   if (invoke(RP,'WriteTagVex','StreamRingBuffer',2*length(waveforms{id+1}),'F32',waveforms{id+1}) == 0)
      disp('ERROR: Could not transfer waveform to RP device');
   end;
   fprintf('done in %1.1f seconds.\n',toc);

   %transfer stimulus to RP device
   id = mod(id + 1,length(waveforms));
   fprintf('Uploading into 0.75-1.0 of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
   tic
   if (invoke(RP,'WriteTagVex','StreamRingBuffer',3*length(waveforms{id+1}),'F32',waveforms{id+1}) == 0)
      disp('ERROR: Could not transfer waveform to RP device');
   end;
   fprintf('done in %1.1f seconds.\n',toc);
   
   running = true;
   invoke(RP,'SoftTrg',3); % stop audio playing
   invoke(RP,'SoftTrg',1); % reset streaming ring buffer to start with first sample
   invoke(RP,'SoftTrg',2); % start audio playing
   
   while (running)             
      % wait until first 25% of buffer has been played
      pos = invoke(RP,'GetTagVal','Position');
      while (pos < length(waveforms{id+1}))
          fprintf('current pos: %1.1f seconds.\n',pos/samplerate);
          pause(0.1);
          pos = invoke(RP,'GetTagVal','Position');
      end
      %transfer stimulus to RP device
      id = mod(id + 1,length(waveforms));
      fprintf('Uploading into 0-0.25 sec of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
      tic
      if (invoke(RP,'WriteTagVex','StreamRingBuffer',0,'F32',waveforms{id+1}) == 0)
          disp('ERROR: Could not transfer waveform to RP device');
      end;
      fprintf('done in %1.1f seconds.\n',toc);

      % wait until second 25% of buffer has been played
      pos = invoke(RP,'GetTagVal','Position');
      while (pos < 2*length(waveforms{id+1}))
          fprintf('current pos: %1.1f seconds.\n',pos/samplerate);
          pause(0.1);
          pos = invoke(RP,'GetTagVal','Position');
      end
      %transfer stimulus to RP device
      id = mod(id + 1,length(waveforms));
      fprintf('Uploading into 0.25-0.5 of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
      tic
      if (invoke(RP,'WriteTagVex','StreamRingBuffer',length(waveforms{id+1}),'F32',waveforms{id+1}) == 0)
          disp('ERROR: Could not transfer waveform to RP device');
      end;
      fprintf('done in %1.1f seconds.\n',toc);

      % wait until 3rd 25% of buffer has been played
      pos = invoke(RP,'GetTagVal','Position');
      while (pos < 3*length(waveforms{id+1}))
          fprintf('current pos: %1.1f seconds.\n',pos/samplerate);
          pause(0.1);
          pos = invoke(RP,'GetTagVal','Position');
      end
      
      %transfer stimulus to RP device
      id = mod(id + 1,length(waveforms));
      fprintf('Uploading into 0.5-0.75 of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
      tic
      if (invoke(RP,'WriteTagVex','StreamRingBuffer',2*length(waveforms{id+1}),'F32',waveforms{id+1}) == 0)
          disp('ERROR: Could not transfer waveform to RP device');
      end;
      fprintf('done in %1.1f seconds.\n',toc);

      % wait until last 25% of buffer has been played
      pos = invoke(RP,'GetTagVal','Position');
      while (pos > length(waveforms{id+1}))
          fprintf('current pos: %1.1f seconds.\n',pos/samplerate);
          pause(0.1);
          pos = invoke(RP,'GetTagVal','Position');
      end

      %transfer stimulus to RP device
      id = mod(id + 1,length(waveforms));
      fprintf('Uploading into 0.75-1.0 of streaming ring buffer (%d samples)...',length(waveforms{id+1}));
      tic
      if (invoke(RP,'WriteTagVex','StreamRingBuffer',3*length(waveforms{id+1}),'F32',waveforms{id+1}) == 0)
          disp('ERROR: Could not transfer waveform to RP device');
      end;
      fprintf('done in %1.1f seconds.\n',toc);
      
   end % while running
   
   if (invoke(RP,'Halt') == 0)
      error('RP circuit failed to halt');
   end;
   disp('RP circuit did halt.');
   
   if (invoke(RP,'ClearCOF') == 0)
      error('Could not clear program and data buffers on the processor.'); 
   end; 
   disp('Cleared program and data buffers on the processor.');
end % function