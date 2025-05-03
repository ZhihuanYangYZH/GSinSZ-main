function [AllmeanGMsig,AllcorrFisherZ,AllPcorr,AllHCcorrFisherZ,AllSZcorrFisherZ,AverageHCcorrFisherZ,AverageSZcorrFisherZ ] ...
         = get_GSCORR(inputpath,outputpath,maskDir,greymaskDir)
%%% calculate the GSCORR

subDir = dir(inputpath);
if ~exist(outputpath, 'dir')
    mkdir(outputpath);
end

%% mask data
[maskData, maskHeader] = y_Read(maskDir);
maskInd = find(maskData~=0);
maskHeader.dt=[16,0];
maskData(maskData~=0) = 1;
greymaskData = icatb_read_data(greymaskDir,[],maskInd);
greymaskData(greymaskData~=0) = 1;
clear maskDir greymaskDir
parpool('local',5);

%% calculate the GSCORR
for i = 3:length(subDir)
    subName = subDir(i).name;
    fileDir = dir([inputpath, filesep, subName, filesep, '*.nii']);
    num = size(fileDir,1);%judge 3D/4D
    if num == 1
        subData = icatb_read_data([inputpath, filesep, subName, filesep, fileDir.name],[],maskInd);
    else
        for j = 1:num
            subData1 = icatb_read_data([inputpath, filesep, subName, filesep, fileDir(j).name],[],maskInd);
            subData(:,j) = subData1;
            clear subData1
        end
    end 
%     subData((maskData==0),:) = []; % get GM signal
    subgreyData = subData.*greymaskData;
    subgreyDataOnly = subgreyData;
    subgreyDataOnly((greymaskData==0),:) = [];
    AllmeanGMsig(i-2,:) = mean(subgreyDataOnly); % get GS
    corrOrignal = zeros(size(subgreyData,1),1);  
    Pcorr= zeros(size(subgreyData,1),1);
    parfor j = 1:size(subgreyData,1)
        [corrOrignal(j,:), Pcorr(j,:)] = corr(subgreyData(j,:)',AllmeanGMsig(i-2,:)');
    end
    corrOrignal(isnan(corrOrignal)) = 0;
    corrFisherZ = 0.5*log((1+corrOrignal)./(1-corrOrignal)); % fisher_Z
%     save([outputpath, filesep, 'corrOrignal_Sub',num2str(i-2, '%03d')], 'corrOrignal');
%     save([outputpath, filesep, 'corrFisherZ_Sub',num2str(i-2, '%03d')], 'corrFisherZ');
%     save([outputpath, filesep, 'Pcorr_Sub',num2str(i-2, '%03d')], 'Pcorr');
    AllcorrOrignal(:,i-2) = corrOrignal;
    AllcorrFisherZ(:,i-2) = corrFisherZ;
    AllPcorr(:,i-2) = Pcorr;
    % GSCORR map
    brainMask = zeros(size(maskData, 1),size(maskData, 2),size(maskData, 3));
    brainMask(maskData==1) = corrFisherZ;
    maskHeader.fname = strcat([outputpath,filesep,'Sub',num2str(i-2,'%03d'),'_Z_GSCORR','.nii']);
    spm_write_vol(maskHeader,brainMask);
    clear subData corrFisherZ corrOrignal Pcorr brainMask subgreyDataOnly
end
delete(gcp('nocreate'));
clear subDir subName subData corrOrignal Pcorr brainMask corrFisherZ inputpath 

%% group average GSCORR map
AllHCcorrFisherZ = AllcorrFisherZ(:,1:109);
AllSZcorrFisherZ = AllcorrFisherZ(:,110:200);
AverageHCcorrFisherZ = mean(AllHCcorrFisherZ,2);
AverageSZcorrFisherZ = mean(AllSZcorrFisherZ,2);    

HCbrainMask = zeros(size(maskData, 1),size(maskData, 2),size(maskData, 3));     
HCbrainMask(maskData==1) = AverageHCcorrFisherZ;    
maskHeader.fname = strcat([outputpath,filesep,'GroupHCcorrFisherZ','.nii']);
spm_write_vol(maskHeader,HCbrainMask);

SZbrainMask = zeros(size(maskData, 1),size(maskData, 2),size(maskData, 3));     
SZbrainMask(maskData==1) = AverageSZcorrFisherZ;    
maskHeader.fname = strcat([outputpath,filesep,'GroupSZcorrFisherZ','.nii']);
spm_write_vol(maskHeader,SZbrainMask);
clear HCbrainMask SZbrainMask subHeader maskDataRaw i j ans
%% save results
save([outputpath,filesep, 'AllGSCORRresults.mat']);



 







