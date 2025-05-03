function AllGS = get_GS(inputpath,outputpath,maskDir)
%%% calculate the GS
%%% YZH

subDir = dir(inputpath);
if ~exist(outputpath, 'dir')
    mkdir(outputpath);
end

%% mask data
[maskData, maskHeader] = y_Read(maskDir);
maskData =  reshape(maskData, size(maskData, 1)*size(maskData, 2)*size(maskData, 3), 1);
maskData(maskData~=0) = 1;

%% calculate the GS
for i = 3:length(subDir)
    subName = subDir(i).name;
    fileDir = dir([inputpath, filesep, subName, filesep, '*.nii']);
    num = size(fileDir,1);
    if num == 1
        [subData, ~] = y_Read([inputpath, filesep, subName, filesep, fileDir.name]);
        subData = reshape(subData, size(subData, 1)*size(subData, 2)*size(subData, 3), size(subData, 4));
    else
        for j = 1:num
            [subData1, ~] = y_Read([inputpath, filesep, subName, filesep, fileDir(j).name]);
            subData1 = reshape(subData1, size(subData1, 1)*size(subData1, 2)*size(subData1, 3), 1);
            subData(:,j) = subData1;
            clear subData1
        end
    end   
    subData((maskData==0),:) = []; % get GM signal
    AllGS(i-2,:) = mean(subData,'omitnan'); % get GS
    clear subData subHeader subData1 subName fileDir num
end
%% save results
save([outputpath, filesep, 'AllGS.mat'], 'AllGS'); 
clear inputDir outputDir maskDir



 







