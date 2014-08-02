function Sammelsurium_ForegroundBackgroundSerSource(RP,TDT_fs)
   if (invoke(RP,'LoadCOFsf','Sammelsurium_ForegroundBackgroundSerSource.rcx',TDT_fs) == 0)
      error('Could not load Sammelsurium_ForegroundBackgroundSerSource.rcx');
   end;
   disp('Sammelsurium_ForegroundBackgroundSerSource.rcx was loaded.');
   if (invoke(RP,'Run') == 0)
      error('RP circuit failed to run');
   end;
   disp('RP circuit is running.');
   fprintf('Idle RCX cycle usage: %d\n',invoke(RP,'GetCycUse'));
   
   samplerate  = floor(invoke(RP,'GetSFreq'));
   fprintf('TDT samplerate: %d\n',samplerate);
   soundFg    = newMakeVowel(0.3, samplerate, 125, 225, 800,2300,3500);  % uu vowel
   soundBg    = newMakeVowel(0.5, samplerate, 125, 270,2150,2600,3500);  % ee vowel
   nSamplesFg = length(soundFg);
   nSamplesBg = length(soundBg);

   %set nSamples for schmitt trigger
   if (invoke(RP,'SetTagVal','nSamplesFg',nSamplesFg) == 0)
      disp('ERROR: Could not set nSamplesFg');
   end;
   if (invoke(RP,'SetTagVal','nSamplesBg',nSamplesBg) == 0)
      disp('ERROR: Could not set nSamplesBg');
   end;

   %transfer stimulus to RP device
   if (invoke(RP,'WriteTagVex','WaveformFg',0,'F32',soundFg(1,:)) == 0) % size is  4e6 samples in Sammelsurium_ForegroundBackgroundSerSource.rcx
      disp('ERROR: Could not transfer foreground signal to RP device');
   end;
   if (invoke(RP,'WriteTagVex','WaveformBg',0,'F32',soundBg(1,:)) == 0) % size is  4e6 samples in Sammelsurium_ForegroundBackgroundSerSource.rcx
      disp('ERROR: Could not transfer background signal to RP device');
   end;   
   disp('stimuli uploaded.');

   % start stimulus
   invoke(RP,'SoftTrg',1);
   disp('background stimulus started.');
   
   % wait until TDT did play finish playing sound
   while (invoke(RP,'GetTagVal','BgPlaying') == 1)
      fprintf('Background Sound still playing (%d%% done). RX cycle usage: %d\n',round(100*invoke(RP,'GetTagVal','StimIndexBg')/nSamplesBg),invoke(RP,'GetCycUse'));
      pause(0.1);
   end
   disp('stimulus finished.');

   % start stimulus
   invoke(RP,'SoftTrg',2);
   disp('foreground stimulus started.');
   
   % wait until TDT did play finish playing sound
   while (invoke(RP,'GetTagVal','FgPlaying') == 1)
      fprintf('Foreground Sound still playing (%d%% done). RX cycle usage: %d\n',round(100*invoke(RP,'GetTagVal','StimIndexFg')/nSamplesFg),invoke(RP,'GetCycUse'));
      pause(0.1);
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
end % function ForegroundBackground