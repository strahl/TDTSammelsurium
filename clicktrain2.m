function train=clicktrain2(dur,F0, fs);
% Creates a clicktrain with the format clicktrain(dur,F0, fs)
% where dur is duration; F0 is the pitch; and fs is the sample rate.
% 
% train=zeros(1,dur*fs);
% interval=round(fs/F0);% * 0.5 cause this is going to have positive and negative impulses
% for ii=1:interval:length(train);
%     train(ii)=1;
%  end; 
% train=train-0.5;
% train=train/max(train);
train=zeros(1,round(dur*fs));
interval=round(fs/F0);% * 0.5 cause this is going to have positive and negative impulses
for ii=1:interval:length(train);
    train(ii)=1;
 end; 
 for ii=2:interval:length(train)
     train(ii)=-1;
 end
