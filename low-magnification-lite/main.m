clc
clear

% %% load images and model
TarFolder='EM images';
list=dir(TarFolder);
list(1:2)=[];

% % Generate Crop images and Annotations
NameDetect=[TarFolder '_AutoDetect']; 
if exist(NameDetect,'dir')
    rmdir(NameDetect,'s')
end
mkdir(NameDetect)

% % --------resolution modification------------
ImScale=0.5;

% % ----------load synapse detocter-----
% [file,path]=uigetfile;
% load(fullfile(path,file))
model = fullfile(pwd,'00_Xlow_resnet18_512_20210621.mat');
load(model)

%%
StatCount=cell(size(list,1),3);
for Count=1:size(list,1)
    disp([Count size(list,1)])
    NamePre=list(Count).name(1:end-4);
    
    Im0 = imread(fullfile(list(Count).folder,list(Count).name));
    Im = imresize(Im0,ImScale);
    [bboxes, scores, labels] = detect(SynapseDetector, Im,...
        'NumStrongestRegions' ,600,...
        'Threshold',0.65,...
        'MiniBatchSize' ,96);
    Flag_1=bboxes(:,1)<1;
    Flag_2=bboxes(:,2)<1;
    Flag_3=bboxes(:,1)+bboxes(:,3)>size(Im0,2);
    Flag_4=bboxes(:,2)+bboxes(:,4)>size(Im0,1);
    Flag_All=Flag_1+Flag_2+Flag_3+Flag_4;
    TR_ind=find(Flag_All==0);
    bboxes_1=bboxes(TR_ind,:);
    StatCount{Count,1}=list(Count).name;
    StatCount{Count,2}=size(bboxes_1,1);
    StatCount{Count,3}=size(bboxes,1);
    Im_1 = insertShape(Im, 'Rectangle', bboxes_1,'Color','blue','LineWidth',5);
    
    ImName=[NamePre '_AutoDetect.jpg'];
    ImPath=fullfile(pwd,NameDetect,ImName);
    imwrite(Im_1,ImPath)
    
    % figure(1);
    % imshow(Im)
    % pause(1)
end
namexls=[TarFolder '_CountStat.xlsx'];
writecell(StatCount,fullfile(pwd,namexls))

disp('----Done----')


