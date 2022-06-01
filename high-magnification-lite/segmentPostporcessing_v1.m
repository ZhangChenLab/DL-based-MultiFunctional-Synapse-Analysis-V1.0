function [segResPost] = segmentPostporcessing_v1(segRes,areaThre)
% UNTITLED2 此处显示有关此函数的摘要
%   直接从deeplab模型输出的分割结果，有一些早点，需要进行一些后续处理

% areaThre = 50;

segResUniq = [1 2]; % pre, post-synapse
imSize = size(segRes);
segResPost = zeros(imSize);

for ci = 1:length(segResUniq)
    bw_1 = segRes == segResUniq(ci);
    bw_1 = imfill(bw_1,'holes');
    props = regionprops(bw_1,'Area','PixelList');
    props_area = [props(:).Area]';
    props(props_area<areaThre) = [];
    if ~isempty(props)
        props_ind = {props(:).PixelList}';
        props_ind = cell2mat(props_ind);
        
        bw_modi = sparse(props_ind(:,2),props_ind(:,1),ones(size(props_ind,1),1),imSize(1),imSize(2));
        bw_modi = full(bw_modi);
        segResPost = segResPost + bw_modi*segResUniq(ci);
    end
end
segResPost = uint8(segResPost);
end

