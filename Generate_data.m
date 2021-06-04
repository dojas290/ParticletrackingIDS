clc
close all
clear all
format compact

name_list=dir('*.mat');
%name_list= [name_list;subdir('MNL*.mat')];
fprintf('Processing %d files\n',length(name_list))
%%

for i=1:length(name_list)
    disp(i);
    disp(name_list(i).name);
end


%%
for i_name= 1:length(name_list)
%     for i_name= 32
    matName = name_list(i_name).name;
    load(matName)
    % Make folder for saving particle images
    %mkdir(matName(1:end-4))
    disp(matName)
    
    % Variables initialization
    Area_Array = [];
    Centroid_Array=[];
    Eccentricity_Array =[];
    Frame_Array=[];
    MeanIntensity_Array = [];
    SumIntensity_Array = [];
    MajorAxisLength_Array = [];
    MinorAxisLength_Array = [];
    
    %stack= stack(:,101:600,:);
    
    %stack = stack(:,:,1:100);
    % figure(1)
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    
    
    background = median(stack(:,:,:),3);
    
    % For each frame, find cells
%     for frame_num = 1  :400
    for frame_num = 1  :size(stack,3)
        disp(frame_num)
        
        % Show the background
        % if mod(frame_num,100)==1 && frame_num+9 <=size(stack,3)
        %     background = median(stack(:,:,frame_num:frame_num+9),3);
        % end
        % figure(1),subplot(2,2,1),imshow(background,[0 100])
        I = stack(:,:,frame_num);
        %figure(1),subplot(2,2,2), imshow(I,[0 100])
        I2 = uint8(abs(double(I)-double(background(:,:))));
        %figure(1),subplot(2,2,3), imshow(I2,[0 10])
        bwCells = im2bw(I2,0.02);
        %h = fspecial('gaussian', 7);
        %I3 = imfilter(double(I2),h);
        %bwCells = I3>=5;
        %figure(1),subplot(1,5,4), imshow(I3,[0 10])
        %figure(1),subplot(2,2,4), imshow(bwCells,[0 1])
        cellObject = bwconncomp(bwCells, 8);
        cellArea = regionprops(cellObject, 'FilledArea');
        cellCentroid = regionprops(cellObject, 'Centroid');
        cellEccentricity = regionprops(cellObject, 'Eccentricity');
        cellMajorAxisLength = regionprops(cellObject, 'MajorAxisLength');
        cellMinorAxisLength = regionprops(cellObject, 'MinorAxisLength');
        
        % Filtering cellObject based on properties
        for i = 1:cellObject.NumObjects
            %     if (cellArea(i).FilledArea> 10 & cellEccentricity(i).Eccentricity >0.5 )
            if (cellArea(i).FilledArea > 20 & cellEccentricity(i).Eccentricity > 0.8 )
                %     if (1)
                Area_Array = [Area_Array; cellArea(i).FilledArea;];
                Centroid_Array = [Centroid_Array; cellCentroid(i).Centroid];
                Eccentricity_Array = [Eccentricity_Array; cellEccentricity(i).Eccentricity];
                Frame_Array = [Frame_Array; frame_num;];
                Intensity = double(I2(cellObject.PixelIdxList{i}));
                MeanIntensity_Array = [MeanIntensity_Array; mean(Intensity)];
                SumIntensity_Array = [SumIntensity_Array; sum(Intensity)];
                MajorAxisLength_Array = [MajorAxisLength_Array; cellMajorAxisLength(i).MajorAxisLength];
                MinorAxisLength_Array = [MinorAxisLength_Array; cellMinorAxisLength(i).MinorAxisLength];
            end
        end
        
    end
    
    [savePath,saveName,EXT]=fileparts(matName);
    % Save feature arrays
    % save(fullfile(sprintf('data_%02d_%s.mat',i_name,saveName)),'Area_Array','Centroid_Array','Eccentricity_Array','Frame_Array','paramsStack','MeanIntensity_Array','background')
    save(fullfile(sprintf('data_%02d_%s.mat',i_name,saveName)),'Area_Array','Centroid_Array','Eccentricity_Array','Frame_Array','MeanIntensity_Array','SumIntensity_Array','MajorAxisLength_Array', 'MinorAxisLength_Array', 'background')
    clear stack
    %pause(0.1)
end

