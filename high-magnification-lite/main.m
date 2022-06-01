clc
clear

% load models

load('00_XHigh_Synapse_resnet18_20210818_1.mat','SynapseDetector')
load('00_SynapseDeeplabv3_focal_resnet50_20210816_4.mat','SynapseSegDeeplab')
load('00_XHigh_Vesicle_resnet18_512_20210708_2.mat','VesicleDetector')

%% 
pathCurr = pwd;
TarFolder = 'EM images';
cd(fullfile(pathCurr,TarFolder));
list=dir('*.tif');
cd(pathCurr)

visualFlag = 0;  % **************
TarFolderVisual = [TarFolder '_ResultsVisual'];
mkdir(TarFolderVisual)

ResStruct=[];
ResStruct.ImName=[];
ResStruct.SynapseBbox=[];
ResStruct.SynapseDetails=[];   % 对每一个synapse bbox进行细致的分析

SynapseDetail=[];
SynapseDetail.SynapseBbox=[];  % 将 ResStruct.SynapseBbox 放大1.2倍 
SynapseDetail.PrePost=[];
SynapseDetail.VesicleBbox=[];

for ci=1 : length(list)
    nameIm=list(ci).name;
    Im=imread(fullfile(list(ci).folder,list(ci).name));
    
    % synapse detection ------------------
    ImScale=0.1;
    ScaleRatio=0.6;
    ImScale=ImScale/ScaleRatio;
    Im_1=imresize(Im,ImScale);
    [bboxes_1, scores, labels] = detect(SynapseDetector, Im_1,  ...
        'NumStrongestRegions' ,600,...
        'Threshold',0.75);
    % figure; imshow(insertShape(Im_1,'Rectangle',bboxes_1,'LineWidth',2,'Color','blue'))
    bboxes_2=round(bboxes_1/ImScale);
    ResStruct(ci).ImName = nameIm;
    ResStruct(ci).SynapseBbox = bboxes_2;
    
    if isempty(bboxes_2)
        continue
    end
    
    % % synapse details ---------------
    SynapseDetail_1 = SynapseDetail;
    for cj=1:size(bboxes_2,1)
        ScaleX=1.3;
        TarBbox=bboxes_2(cj,:);
        WidthHeight_X=round(TarBbox(1,3:4)*ScaleX);
        Center=TarBbox(1,1:2)+TarBbox(1,3:4)/2;
        TarConer=round(Center-WidthHeight_X/2);
        TarBbox_X=[TarConer WidthHeight_X];
        minColRow = max(TarBbox_X(1:2),[1 1]);
        maxColRow = min(TarBbox_X(1:2)+TarBbox_X(3:4),[size(Im,2) size(Im,1)]);
        
        rowMinMax=[minColRow(2) maxColRow(2)];
        colMinMax=[minColRow(1) maxColRow(1)];
        Im_21=Im(rowMinMax(1):rowMinMax(2),colMinMax(1):colMinMax(2));
        TarBbox_X_Modi = [minColRow maxColRow-minColRow];
        
        % pre/post synapse segmentation ---------
        ImScale=0.2;
        ScaleRatio=0.6;
        ImScale=ImScale/ScaleRatio;
        CropSize=[512 512]; 
        Im_41=imresize(Im_21,ImScale);
        % [Im_41_modi,TransXY] = ImPadding_SF_V2_1(Im_41,CropSize);
        [Im_41_modi,~,TransXY] = ImPadding_SF_V4(Im_41,[],CropSize);
        Im_41_modi=uint8(Im_41_modi);
        
        % % % without augmentation
        % C = semanticseg(Im_41_modi,SynapseSegDeeplab);
        % D=uint8(C);  % 1 presynapse; 2 post synapse
        % % withaugmentation
        aug_N= 10;
        pxds_Pred = zeros(512,512,2,aug_N,'single');
        augRotate = linspace(0,360,aug_N+1);
        for aug_i = 1:aug_N
            testImage_1 = imrotate(Im_41_modi,augRotate(aug_i),'crop');
            D = semanticseg(testImage_1,SynapseSegDeeplab);
            D=uint8(D);
            D_1 = zeros(512,512,2,'logical');
            D_1(:,:,1) = D==1;
            D_1(:,:,2) = D==2;
            D_2 = imrotate(D_1,-augRotate(aug_i),'crop');
            pxds_Pred(:,:,:,aug_i) = D_2;
        end
        pxds_Pred_mean = mean(pxds_Pred,4);
        pxds_Pred_mean_1 = single(pxds_Pred_mean>0.5);
        pxds_Pred_mean_2 = pxds_Pred_mean_1(:,:,1)*1 + pxds_Pred_mean_1(:,:,2)*2;
        D = uint8(pxds_Pred_mean_2); % 1 presynapse; 2 post synapse
        
        areaThre = 200;
        D_modi = segmentPostporcessing_v1(D,areaThre);
        D_modi=imtranslate(D_modi,TransXY);
        TR1=zeros(max([size(Im_41) 512]),'uint8');
        TR1(1:size(D,1),1:size(D,2))=D_modi;
        D_modi_1=TR1(1:size(Im_41,1),1:size(Im_41,2));
        
        maskprepost = zeros(size(Im_41,1),size(Im_41,2),2,'logical');
        maskprepost(:,:,1)=D_modi_1==1;
        maskprepost(:,:,2)=D_modi_1==2;
        maskprepost=imresize(maskprepost,[size(Im_21,1) size(Im_21,2)]);
        masklabel = double(maskprepost(:,:,1)) + double(maskprepost(:,:,2))*2;
        % imshow(labeloverlay(Im_21,masklabel,'Transparency',0.75,'IncludedLabels',[1 2]));
        maskprepost_origiSize = zeros([size(Im) 2],'logical');
        maskprepost_origiSize(rowMinMax(1):rowMinMax(2),colMinMax(1):colMinMax(2),:) = maskprepost;
        
        % vesicle detection -------------
        ImScale=1;
        ScaleRatio=0.6;
        ImScale=ImScale/ScaleRatio;
        Im_31=imresize(Im_21,ImScale);
        SizeMax=max([224 size(Im_31)]);
        Im_31_modi=zeros(SizeMax,'uint8');
        Im_31_modi(1:size(Im_31,1),1:size(Im_31,2))=Im_31;
        [bboxes, scores, labels] = detect(VesicleDetector, Im_31_modi,...
            'NumStrongestRegions' ,400,...
            'Threshold',0.5);
        bboxes=bboxes/ImScale;
        bboxes_cen = bboxes(:,1:2) + bboxes(:,3:4)/2;
        bboxes_cen = round(bboxes_cen);
        presynapse_bw = masklabel==1;
        [pi,pj,pk] = find(presynapse_bw);  % row (y),col(x),value
        presynapse_xy = [pj pi];
        [~, ia,ib]=intersect(bboxes_cen,presynapse_xy,'row');
        bboxesVesicle = bboxes(ia,:);
        % figure; imshow(insertShape(Im_21,'Rectangle',bboxesPresynapse,'LineWidth',2,'Color','blue'))
        bboxesVesicle_origiSize = bboxesVesicle;
        bboxesVesicle_origiSize(:,1) = bboxesVesicle_origiSize(:,1)+colMinMax(1);
        bboxesVesicle_origiSize(:,2) = bboxesVesicle_origiSize(:,2)+rowMinMax(1);
        % figure; imshow(insertShape(Im,'Rectangle',bboxesPresynapse_origiSize,'LineWidth',2,'Color','blue'))
        
        % update info
        SynapseDetail_1(cj).SynapseBbox=TarBbox_X_Modi;  % 将 ResStruct.SynapseBbox 放大1.2倍
        SynapseDetail_1(cj).PrePost=maskprepost_origiSize;
        SynapseDetail_1(cj).VesicleBbox=bboxesVesicle_origiSize;
    end
    ResStruct(ci).SynapseDetails = SynapseDetail_1;
    
    % visualize all synapse
    AllSynapseBboxes = ResStruct(ci).SynapseBbox;
    AllVesicleBbox = {SynapseDetail_1(:).VesicleBbox}';
    AllVesicleBbox = cell2mat(AllVesicleBbox);
    AllPrepost = [];
    for cj = 1:length(SynapseDetail_1)
        AllPrepost = cat(4,AllPrepost,SynapseDetail_1(cj).PrePost);
    end
    AllPrepost = sum(AllPrepost,4);
    AllPrepostLabel = double(AllPrepost(:,:,1)) + double(AllPrepost(:,:,2))*2;
    
    CircleXYR = zeros(size(AllVesicleBbox,1),3);
    CircleXYR(:,1:2) = AllVesicleBbox(:,1:2)+AllVesicleBbox(:,3:4)/2;
    CircleXYR(:,3) = mean(AllVesicleBbox(:,3:4),2)*0.75;
    VisualIm = Im;
    VisualIm = labeloverlay(VisualIm,AllPrepostLabel,'Transparency',0.75,'IncludedLabels',[1 2]);
    VisualIm = insertShape(VisualIm,'Rectangle',AllSynapseBboxes,'LineWidth',6,'Color','white');
    % VisualIm = insertShape(VisualIm,'Rectangle',AllVesicleBbox,'LineWidth',6,'Color','blue');
    VisualIm = insertShape(VisualIm,'circle',CircleXYR,'LineWidth',6,'Color','blue');
    if visualFlag
        figure(1); imshow(VisualIm)
    end
    
    impath = fullfile(pwd,TarFolderVisual,nameIm);
    imwrite(VisualIm,impath)
end
disp('----Done----')






