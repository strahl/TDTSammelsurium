function Sammelsurium_SoundOutSerSource(RP,TDT_fs)
   if (invoke(RP,'LoadCOFsf','Sammelsurium_SoundOutSerSource.rcx',TDT_fs) == 0)
      error('Could not load Sammelsurium_SoundOutSerSource.rcx');
   end;
   disp('Sammelsurium_SoundOutSerSource.rcx was loaded. Samplingrate was set to 25kHz.');
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
   if (invoke(RP,'WriteTagVex','WaveformL',0,'F32',sound(1,:)) == 0) % size is  4e6 samples in Sammelsurium_SoundOutSerSource.rcx
      disp('ERROR: Could not transfer Signal to RP device');
   end;
   disp('stimulus uploaded.');

   % start stimulus
   invoke(RP,'SoftTrg',1);
   disp('stimulus started.');
   
   % wait until TDT did play finish playing sound
   while (invoke(RP,'GetTagVal','soundPlaying') == 1)
      fprintf('Sound still playing (%d%% done). RX cycle usage: %d\n',round(100*invoke(RP,'GetTagVal','StimIndex')/nSamples),invoke(RP,'GetCycUse'));
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
end % function SoundOutSerSource