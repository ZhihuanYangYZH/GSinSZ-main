%%

Inputpath = ''; % data path
Outputpath = '';
greymaskDir = '';

AllGS = get_GS(inputpath,outputpath,maskDir);

%%
inputpath = ''; % data path
outputpath = '';
maskDir = ''; % whole brain
greymaskDir = '';

[AllmeanGMsig,AllcorrFisherZ,AllPcorr,AllHCcorrFisherZ,AllSZcorrFisherZ,AverageHCcorrFisherZ,AverageSZcorrFisherZ ] ...
         = get_GSCORR(inputpath,outputpath,maskDir,greymaskDir);

%% 

TR = 2;
Fs = 1/TR; % sampling_frequency
[Pxx, freq] = pwelch(AllGS,[],[],[],Fs);


%% 
Allx = Alltc;  % x: IC' time series
% Allx = All_spatial_maps;  % x: IC' spatial pattern
Ally = AllGS; %  y: GS;
% Ally = AllGSCORR; %  y: GSCORR
xnum = size(Allx,1);
subNum = size(Alltc,3);
for i = 1:subNum
    y = Ally(:,i);
    x = Allx(:,:,i);
    y = normalize(y,1,'zscore');
    x = normalize(x,1,'zscore');
    x = [ones(xnum,1), x];
    [b,bint,r,rint,stats] = regress(y,x);
    Allb(i,:) = b;
    Allbint(i,:) = bint;
    Allr(i,:) = r;
    Allrint(i,:) = rint;
    Allstats(i,:) = stats;
    clear y x b bint r rint stats
end



     