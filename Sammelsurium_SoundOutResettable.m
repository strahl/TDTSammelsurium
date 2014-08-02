function Sammelsurium_SoundOutResettable(RP,TDT_fs)
   if (invoke(RP,'LoadCOFsf','Sammelsurium_SoundOutResettable.rcx',TDT_fs) == 0)
      error('Could not load Sammelsurium_SoundOutResettable.rcx');
   end;
   disp('Sammelsurium_SoundOutResettable.rcx was loaded.');
   if (invoke(RP,'Run') == 0)
      error('RP circuit failed to run');
   end;
   disp('RP circuit is running.');
   fprintf('Idle RCX cycle usage: %d\n',invoke(RP,'GetCycUse'));
   
   samplerate  = floor(invoke(RP,'GetSFreq'));
   fprintf('TDT samplerate: %d\n',samplerate);
   sound       = newMakeVowel(0.5, samplerate, 125, 225, 800,2300,3500);  % play uu vowel
   nSamples    = length(sound);

   %set nSamples for schmitt trigger
   if (invoke(RP,'SetTagVal','nSamples',nSamples) == 0)
      disp('ERROR: Could not set nSamples');
   end;

   %transfer stimulus to RP device
   if (invoke(RP,'WriteTagVex','WaveformL',0,'F32',sound(1,:)) == 0) % size is  4e6 samples in Sammelsurium_SoundOutResettable.rcx
      disp('ERROR: Could not transfer Signal to RP device');
   end;
   disp('stimulus uploaded.');

   % start stimulus
   invoke(RP,'SoftTrg',9); % reset SerialBuf
   invoke(RP,'SoftTrg',1); % switch to "Go"
   disp('stimulus started.');
   
   % wait until TDT did play finish playing sound
   stimIndex = 1;          % assume a successfull start
   while (stimIndex > 0)
      fprintf('Sound still playing (%d%% done). RX cycle usage: %d\n',round(100*stimIndex/nSamples),invoke(RP,'GetCycUse'));
      pause(0.1);
      stimIndex = invoke(RP,'GetTagVal','StimIndex');
   end
   disp('stimulus finished.');
   
   if (invoke(RP,'Halt') == 0)
      error('RP circuit failed to halt');
   end;
   disp('RP circuit did halt.');
   
   if (invoke(RP,'ClearCOF') == 0)
      error('Could not clear program and data buffers on the processor.'); 
   end; 
   disp('Cleared program and data buffers on the processor.');
end % function SoundOutResettable