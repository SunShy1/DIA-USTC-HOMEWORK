%% VLAD
% ����ռ�
clear;
close all; 
clc; 

%% SIFT
% ��ȡ
srcFolderPath = './SIFT';
allFiles = dir(srcFolderPath);
imgCount = 0;
for i = 3 : length(allFiles) %��3��ʼ
    fileName = allFiles(i).name;
    if length(fileName) > 3 && strcmp(fileName(end-9 : end-6), '.jpg') == 1 % find JPG image file
        imgCount = imgCount + 1;
        imgPath = [srcFolderPath, '/', fileName(1:end-6)];
        fprintf('File %d: %s\n', imgCount, imgPath);
        sift = readsift(imgPath); % read sift--> ��ȡ�洢��sift����
        [sm,sn]=size(sift);
        SiftFeat{imgCount} = sift(randperm(sm, floor(sm*1)),:);%�����һ�����sift,  �����Ѿ���ת�Ʋ������ȡ300��
    end
end

%% KMEANS
% ��ȡ�뱾
sift_all = [];
num_pic=1000;
KM=8;

for i=1:num_pic
    sift_all = [sift_all;SiftFeat{i}];
end
[Idx_all,C] = kmeans(sift_all,KM,'MaxIter',100,'display','iter');

size_sift=zeros(1,num_pic);
for i=1:num_pic
     m = size(SiftFeat{i});
     size_sift(i) = m(1);
end
sum_size = 1;
for i=1:num_pic 
    temp_Idx = Idx_all(sum_size:sum_size+size_sift(i)-1);
    sum_size = sum_size+size_sift(i);
    Idx{i} = temp_Idx;
end

%% ����ÿ��ͼ�;۵���ۼƲв�
for i=1:num_pic  
    temp_v = zeros(KM,128);
    temp_sift = SiftFeat{i};
    for num_1=1:size_sift(i) 
        temp_v(Idx{i}(num_1),:)=temp_v(Idx{i}(num_1),:)+temp_sift(num_1,:)-C(Idx{i}(num_1),:);
    end
    v_chuan = [];
    for num_2=1:KM
        v_chuan = [v_chuan,temp_v(num_2,:)];
    end
    v_chuan = bsxfun(@times, v_chuan, 1./sqrt(sum(v_chuan.^2,2)));
    v{i}= v_chuan;
end

%% ����ÿ��ͼ�ۼƲв��L2����
result_Ech = zeros(num_pic,num_pic);
for i=1:num_pic
    for j=1:num_pic
        result_Ech(i,j) = sum((v{i}-v{j}).^2);
    end
end

%% ��ȡ������С��ǰ�ķ�ͼ
temp_result = sort(result_Ech,2);
result = zeros(num_pic,4);
for i=1:num_pic
    for j=1:4
        temp_find = find(result_Ech(i,:)==temp_result(i,j));
        result(i,j) = temp_find(1);
    end
end

%% ����ǰ�ķ�ͼ��س̶�
for i=1:(num_pic/4) 
    class{i} = [(i-1)*4+1:(i-1)*4+4];
end

for i=1:num_pic
    num_result = 1;
    for j=2:4
        temp = find(class{ceil(i/4)}==result(i,j));
        if ~isempty(temp)
            num_result = num_result+1;
        end
        result_one(i) = num_result;
    end
end

%% ������
result_average = mean(result_one)./4