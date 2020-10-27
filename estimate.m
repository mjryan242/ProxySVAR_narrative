clear;
clc
addpath('functions');
datac=xlsread('data_for_proxysvar.xlsx');  %two datasets:  data_for_proxysvar (my narrative iv ) and data_for_proxysvar_bloom (bloom variables)

L=4;       %number of lags
HORZ=20;    %number of periods to compute the impulse response for
Bootstrap=1;   % 1 if error bands are to be produced
Reps=2000;      % Number of replications for bootstrap




%Estimate proxy VAR                                %Variables in the VAR %Instrument
[ m3save,m3saveL,m3saveH,m3fevd,m3base,m3hd,VAR01 ] = runproxyvar( datac(:,1:end-1),datac(:,end),L,HORZ,Bootstrap,Reps );
save results_av_m3D