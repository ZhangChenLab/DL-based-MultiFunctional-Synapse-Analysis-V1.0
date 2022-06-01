function [Im_out,bboxes_out,LeftCornerTrans] = ImPadding_SF_V4(Im_in,bboxes_1,SizeOut)
%UNTITLED2 此处显示有关此函数的摘要
%   Size=[SizeRow SizeCol]

% Im_out=zeros([SizeOut size(Im_in,3)]);
bboxes_out=bboxes_1;
LeftCornerTrans = [nan nan];
% row, y
ImSize=size(Im_in);
if size(Im_in,3) == 1
    ImSize(3) = 1;
end
if ImSize(1)~=SizeOut(1)
    if  ImSize(1)>SizeOut(1)  % 实际尺寸比目标尺寸 大
        TR1= floor((ImSize(1)-SizeOut(1))/2);
        Im_in=Im_in(1+TR1:TR1+SizeOut(1),:,:);
        if ~isempty(bboxes_out)
            bboxes_out(:,2)=bboxes_out(:,2)-TR1;
        end
        LeftCornerTrans(1,2) = TR1;
    end
    if  ImSize(1)<SizeOut(1)  % 实际尺寸比目标尺寸 小
        TR1= floor((SizeOut(1)-ImSize(1))/2);
        Im_in=[zeros(TR1,ImSize(2),ImSize(3)); Im_in; zeros(SizeOut(1)-ImSize(1)-TR1,ImSize(2),ImSize(3))];
        if ~isempty(bboxes_out)
            bboxes_out(:,2)=bboxes_out(:,2)+TR1;
        end
        LeftCornerTrans(1,2) = -TR1;
    end
else
    LeftCornerTrans(1,2) = 0; % row,y
end

% column, x
ImSize=size(Im_in);
if size(Im_in,3) == 1
    ImSize(3) = 1;
end
if ImSize(2)~=SizeOut(2)
    if  ImSize(2)>SizeOut(2)  % 实际尺寸比目标尺寸 大
        TR1= floor((ImSize(2)-SizeOut(2))/2);
        Im_in=Im_in(:,1+TR1:TR1+SizeOut(2),:);
        if ~isempty(bboxes_out)
            bboxes_out(:,1)=bboxes_out(:,1)-TR1;
        end
        LeftCornerTrans(1,1) = TR1;
    end
    if  ImSize(2)<SizeOut(2)  % 实际尺寸比目标尺寸 小
        TR1= floor((SizeOut(2)-ImSize(2))/2);
        Im_in=[zeros(ImSize(1),TR1,ImSize(3)) Im_in zeros(ImSize(1),SizeOut(2)-ImSize(2)-TR1,ImSize(3))];
        if ~isempty(bboxes_out)
            bboxes_out(:,1)=bboxes_out(:,1)+TR1;
        end
        LeftCornerTrans(1,1) = -TR1;
    end
else
    LeftCornerTrans(1,1) = 0;
end
Im_out=Im_in;

end

