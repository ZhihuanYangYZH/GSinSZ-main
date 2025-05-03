Inputpath = ''; % data
Outputpath = '';
greymaskDir = '';

%% load grey mask data
[greymaskData, greymaskHeader] = y_Read(greymaskDir);
greymaskData(greymaskData~=0) = 1;
greymaskInd = find(greymaskData~=0);
greymaskHeader.dt=[16,0];
clear greymaskDir 
parpool('local',15);

%% calculate the FCS
subDir = dir(Inputpath);
subNum = length(subDir) - 2;
voxelNum = size(greymaskInd,1);
AllFCSOrignal = zeros(voxelNum,subNum);
AllFCSFisherZ = zeros(voxelNum,subNum);
parfor i = 1:subNum
    subName = subDir(i+2).name;
    fileDir = dir([Inputpath, filesep, subName, filesep, '*.nii']);
    subData = icatb_read_data([Inputpath, filesep, subName, filesep, fileDir.name],[],greymaskInd);
    FCSOrignal = zeros(voxelNum,1);
    for j = 1:voxelNum
        corrOrignal = zeros(voxelNum,1);
        for k = 1:voxelNum
            corrOrignal(k,1) = corr(subData(j,:)',subData(k,:)');
        end
        disp( ["The subject number is", num2str(i),"The voxel number is", num2str(j)] );
        corrOrignal(isnan(corrOrignal)) = 0;  
        corrOrignal(j,:) = []; % Delete the autocorrelation r value 1
        FCSOrignal(j,1) = mean(corrOrignal);
    end
    FCSFisherZ = 0.5*log((1+FCSOrignal)./(1-FCSOrignal)); % fisher_Z
    AllFCSOrignal(:,i) = FCSOrignal;
    AllFCSFisherZ(:,i) = FCSFisherZ;
    % FCS map
    FCS_map(greymaskData,FCSFisherZ,greymaskHeader,Outputpath,i);
%     brainMask = zeros(size(greymaskData, 1),size(greymaskData, 2),size(greymaskData, 3));
%     brainMask(greymaskData==1) = GBCFisherZ;
%     greymaskHeader.fname = strcat([Outputpath,filesep,'Sub',num2str(i,'%03d'),'_Z_FCS','.nii']);
%     spm_write_vol(greymaskHeader,brainMask);
%     clear brainMask FCSOrignal subName fileDir subData FCSFisherZ
end
delete(gcp('nocreate'));

%% Average FCS map
AverageFCS = mean(AllFCSFisherZ,2);
brainMask = zeros(size(greymaskData, 1),size(greymaskData, 2),size(greymaskData, 3));     
brainMask(greymaskData==1) = AverageFCS;    
greymaskHeader.fname = strcat([Outputpath,filesep,'AverageFCS','.nii']);
spm_write_vol(greymaskHeader,brainMask);
clear brainMask

function FCS_map(greymaskData,FCSFisherZ,greymaskHeader,Outputpath,subName)
    brainMask = zeros(size(greymaskData, 1),size(greymaskData, 2),size(greymaskData, 3));
    brainMask(greymaskData==1) = FCSFisherZ;
    greymaskHeader.fname = strcat([Outputpath,filesep,subName,'_Z_FCS','.nii']);
    spm_write_vol(greymaskHeader,brainMask);
end



