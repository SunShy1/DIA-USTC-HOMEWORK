%% ��ά��覴ü�� SA19006050 ��ʥӡ

% ˼·��һ����ά��ͼת��Ϊ��ֵͼ
%       �����ȱպ�ȥ��������Ȥ����ĸ��������ά��ĺ�ɫ�������ɺ�ɫ����
%       �����ֱ��ں��������Եڶ����õ���ͼ�������ۼӣ�ͨ������ֵ��ֵȷ����ά������
%       �ġ�ԭʼͼ����ѡ����ά������ - ѡ���Ķ�ά�������ȿ���� = 覴õ�
%       �塢�����覴õ�

clear;close all; clc;
warning('off')
%% Binarize the input image

im = imread('test images/barcode_4.png');

% Origin Image
figure;imshow(im);title('Origin Image','FontSize',15);

% Gray Scale Image
im_gray = rgb2gray(im);
level = graythresh(im_gray);

% Binary Image
bw = im2bw(im_gray, level);
figure;imshow(bw);title('Binary Image','FontSize',15);
%% ����ڶ�ֵͼ��bw������ά��覴����������

% Close
se = strel('rectangle',[45,1]);
fc = imclose(bw,se);
% Open
se = strel('rectangle',[3,100]);
fc2 = imopen(fc,se);
% Close
se = strel('rectangle',[2,100]);
fc3 = imclose(fc2,se);
% Open
se = strel('rectangle',[2,50]);
fc4 = imopen(fc3,se);

% Location
sum_x = 0; sum_y = 0;
[fc4_m,fc4_n]=size(fc4);
for i=1:1:fc4_m
sum_data_x(i) = sum(fc4(i,:)); 
end

%% Vertical Range

% Determining the  range from the peak and valley values
figure;
plot([1:1:fc4_m],sum_data_x); 
title('ˮƽ�����ۼ�','FontSize',15);

index_x_1_1 = 0; 
index_x_1_2 = 0; 
index_x_2_1 = 0; 
index_x_2_2 = 0; 
l_temp = 20;

% Difference Method
Delta_sum_data_x = sum_data_x(1:end-l_temp)-sum_data_x((l_temp+1):end);

% Determining the Vertical Range From the Peak and Valley Values
figure;
plot([1:1:fc4_m-l_temp],Delta_sum_data_x);
title('ˮƽ�����ۼ�-���','FontSize',15);

% Choose 
[pks,locs] = findpeaks(Delta_sum_data_x);
[ans_pks,pos] = sort(pks);
index_x(1) = locs(pos(end));
index_x(2) = locs(pos(end-1));

[pks,locs] = findpeaks(-Delta_sum_data_x);
[ans_pks,pos] = sort(pks);
index_x(3) = locs(pos(end));
index_x(4) = locs(pos(end-1));
index_x = sort(index_x,'ascend');

index_x_1_1 = index_x(1); 
index_x_1_2 = index_x(2)+10; 
index_x_2_1 = index_x(3); 
index_x_2_2 = index_x(4)+10; 


%% Horizontal Range

for i=1:1:fc4_n
sum_data_y(i) = sum(fc4(:,i)); 
end

figure;
plot([1:1:fc4_n],sum_data_y);
title('��ֱ�����ۼ�','FontSize',15);

index_y_1 = 0; 
index_y_2 = 0; 
l_temp = 15;

% Difference Method
Delta_sum_data_y = sum_data_y(1:end-l_temp)-sum_data_y((l_temp+1):end);

% Determining the Horizontal Range From the Peak and Valley Values
figure;
plot([1:1:fc4_n-l_temp],Delta_sum_data_y);
title('��ֱ�����ۼ�-���','FontSize',15);

[pks,locs] = findpeaks(Delta_sum_data_y);

if max(pks) < 20
    index_y(1) = 1;
else
    [ans_pks,pos] = sort(pks,'ascend');
    index_y(1) = locs(pos(end));
end

[pks,locs] = findpeaks(-Delta_sum_data_y);
[ans_pks,pos] = sort(pks,'ascend');
index_y(2) = locs(pos(end))* 1.03;
index_y = sort(index_y,'ascend');
index_y_1 = index_y(1);
index_y_2 = index_y(2); 

%% Positioning the Detection Area

A_a = [index_y_1,index_x_1_1];
A_b = [index_y_2,index_x_1_1];
A_c = [index_y_2,index_x_1_2];
A_d = [index_y_1,index_x_1_2];

B_a = [index_y_1,index_x_2_1];
B_b = [index_y_2,index_x_2_1];
B_c = [index_y_2,index_x_2_2];
B_d = [index_y_1,index_x_2_2];

A_x=[A_a(1),A_b(1),A_c(1),A_d(1)];
A_y=[A_a(2),A_b(2),A_c(2),A_d(2)];
v = [A_b; A_c; A_d ; A_a];

figure;imshow(im);title('�������λ','FontSize',15);hold on;
plot([A_a(1) A_b(1)],[A_a(2) A_b(2)],'r-');
plot([A_c(1) A_b(1)],[A_c(2) A_b(2)],'r-');
plot([A_c(1) A_d(1)],[A_c(2) A_d(2)],'r-');
plot([A_a(1) A_d(1)],[A_a(2) A_d(2)],'r-');

plot([B_a(1) B_b(1)],[B_a(2) B_b(2)],'r-');
plot([B_c(1) B_b(1)],[B_c(2) B_b(2)],'r-');
plot([B_c(1) B_d(1)],[B_c(2) B_d(2)],'r-');
plot([B_a(1) B_d(1)],[B_a(2) B_d(2)],'r-');

%% Crop Out the Region of Interest

zero_one=zeros(fc4_m,fc4_n);
for i=1:fc4_m
   for j=1:fc4_n
       if (j>index_y_1)&&(j<index_y_2)&&(i>index_x_1_1)&&(i<index_x_1_2)
           zero_one(i,j) = 1;
       end
       if (j>index_y_1)&&(j<index_y_2)&&(i>index_x_2_1)&&(i<index_x_2_2)
           zero_one(i,j) = 1;
       end
   end
end
bw = bw .* zero_one;
for i=1:fc4_m
   for j=1:fc4_n
       if (j>index_y_1)&&(j<index_y_2)&&(i>index_x_1_1)&&(i<index_x_1_2)
       elseif (j>index_y_1)&&(j<index_y_2)&&(i>index_x_2_1)&&(i<index_x_2_2)
       else
           bw(i,j) = logical(1);
       end
   end
end

%% Defective areas

% Close
se = strel('rectangle',[6,2]);
fc_true = imclose(bw,se);

% Fill
sel =  strel('rectangle',[30,1]);  
fc_fill  =imopen(fc_true,sel);
fc_fill  =imclose(fc_fill,sel);

e = fc_true-fc_fill;

se = strel('square',3);
fe = imopen(e,se);
figure;imshow(fe);title('覴������ֵͼ','FontSize',15);
%% Locating Defective Areas

p=ones(fc4_m,fc4_n);
p = logical(p);
 for i=4:fc4_m-3
      for j=4:fc4_n-3
          if(fe(i,j)==0)&&(fe(i+3,j)==1||fe(i,j-3)==1||fe(i,j+3)==1||fe(i-3,j)==1)
            p(i,j) = 0;
          end
      end
 end
fc_temp = int8(double(im_gray).*double(p));
figure;
imshow(fc_temp);
title('��λ覴�����','FontSize',15)

%% Use the Red Frame to Circle the Defective Area

fe = logical(fe);
stats = regionprops(fe, 'BoundingBox' ,'Area','Centroid' ,'PixelList' );
centroids = cat(1, stats.Centroid);
noiseArea=1;
figure;imshow(im);
hold on
for i=1:size(stats)
    area = stats(i).Area;                                  
    if (area > noiseArea) && ( stats(i).BoundingBox(3) > 2)
        x=centroids(i,1);y=centroids(i,2);
        % Width
        Width = stats(i).BoundingBox(3)* 5;
        % Length
        Length = stats(i).BoundingBox(4)* 5;
        rectangle('Position',[x-Width/2 y-Length/2 Width Length],'LineWidth',2,'LineStyle','-','EdgeColor','r');
        pause(1)
        plot(centroids(i,1), centroids(i,2), 'b*');             
    end
    hold on;
end
title('覴ü����','FontSize',15)