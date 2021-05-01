clear;
clc;

NUM_PIC = 142;
%���ݵĳ�ʼ��
%��HSV�ռ��У���������ɫ�����ϳ�Ϊһά��������ʱ��һά�����Ĵ�С
v_count=193;
N=500;
%�������ӵĸ���
n=252;%179;%400;%52;
%��Ƶ�����е�ͼ��֡��
first=1;
%��һ֡ͼ����������
new_sita=0.20;
%��new_sita��^2��ʾ��ɫ��Ϣ�ĸ�˹�ֲ����
vx=[0,0,0];
vy=[0,0,0];
%�ó�Ŀ����ƶ��ٶ�
runtime=0;%��ȡĿ���ٶȵ�ʱ����
struct_index=0;%�洢�ṹ���ָ��
%����������ӵķ���
sigma_x=3.5;
sigma_y=3.5;
%��ǰ10֡ͼ����Ŀ��ģ������ƶ�
pre_probability=zeros(1,NUM_PIC-1);
%�ж��Ƿ�������ز���
resample_judge=0;

%�õ�Ŀ��ģ��ĳ�ʼ����
I=imread('.\videoImage1\0001.jpg');
imshow(I);
rect = getrect();
x1 = rect(1); 
x2 = rect(1) + rect(3);
y1 = rect(2);
y2 = rect(2) + rect(4);
%�õ���ʼ����Ŀ������������
 x=round((x1+x2)/2);
 y=round((y1+y2)/2);
%�õ�����Ŀ����������Բ�ĳ��̰����ƽ��
hx=((x2-x1)/3)^2;
hy=((y2-y1)/3)^2;
sizeimage=size(I);
image_boundary_x=int16(sizeimage(2));
image_boundary_y=int16(sizeimage(1));

% %����һ֡����ѡ�񱻸���Ŀ���ͼƬ����ָ�����ļ�����
F = getframe;
mkdir('C:\Users\lenovo\Desktop\�������\result');
image_source=strcat('C:\Users\lenovo\Desktop\�������\result\','1.jpg');
imwrite(F.cdata,image_source);

%�ڵ�һ֡���ֶ�ѡ����Ŀ����г�ʼ������
[H S V]=rgb_to_rank(I);
[Sample_Set,Sample_probability,Estimate,target_histgram]=initialize(x,y,hx,hy,H,S,V,N,image_boundary_x,image_boundary_y,v_count,new_sita);
pre_probability(1)=Estimate(1).probability;


%�ӵڶ�֡����ѭ�������Ľ�����ȥ
for loop=2:NUM_PIC
    struct_index=struct_index+1;
    a=(loop+first-1); disp(a)
    b = sprintf('./videoImage1/%04d.jpg', a); %����Ŀ¼�µ�ͼ����
    I=imread(b);
    [H,S,V]=rgb_to_rank(I);
    %�����������
    [Sample_Set,after_prop]=reproduce(Sample_Set,vx,vy,image_boundary_x,image_boundary_y,I,N,sigma_x,sigma_y,runtime);
    
    %�ó�������Ŀ����ڵ�ǰ֡��Ԥ��λ��
    [Sample_probability,Estimate,vx,vy,TargetPic,Sample_histgram]=evaluate(Sample_Set,Estimate,target_histgram,new_sita,loop,after_prop,H,S,V,N,image_boundary_x,image_boundary_y,v_count,vx,vy,hx,hy,Sample_probability);
    %ģ�����ʱ���ز����ж�ʱ����Ҫ�õ���һ����ȨֵSample_probability
    
    %ģ�����
    if(loop<=200)%ǰ10֡���������������Ҫ������д���
        sum_probability=0;
        for p=1:loop-1
            sum_probability=sum_probability+pre_probability(p);
        end 
        mean_probability=sum_probability/(loop-1);
    else%ֱ����ȡ��ֵ
        mean_probability=mean(pre_probability);
    end
    mean_probability;
    Estimate(loop).probability;
    resample_judge=0;
    
    
    %�ж��Ƿ���Ҫ�ز���
    back_sum_weight=0;
    for judge=1:N
        back_sum_weight=back_sum_weight+(Sample_probability(judge))^2;
    end
    sum_weight=1/back_sum_weight;
    if(sum_weight<N/2)
        %�ز�������
        usetimes=reselect(Sample_Set,Sample_probability,N);
        [Sample_Set,Sample_probability]=assemble(Sample_Set,usetimes,Sample_probability,N);%�����������
        resample_judge=1;
    end
    
    
    %�õ�Ŀ���˶��Ĺ켣
if(struct_index==1)
    routine.x=round(Estimate(loop).x);
    routine.y=round(Estimate(loop).y);
else
    routine(struct_index).x=round(Estimate(loop).x);
    routine(struct_index).y=round(Estimate(loop).y);
end
i=1;
j=1;
while(j<=struct_index)
    for new_x=routine(j).x-i:routine(j).x+i
       for new_y=routine(j).y:routine(j).y+i
            TargetPic(new_y,new_x,1)=0;
            TargetPic(new_y,new_x,2)=0;
            TargetPic(new_y,new_x,3)=255;
       end
    end   
    j=j+1;
end

%����ÿһ֡ͼ���и���Ŀ���Ԥ�����ĵ�
i=1;
for new_x=round(Estimate(loop).x)-i:round(Estimate(loop).x+i)
       for new_y=round(Estimate(loop).y)-i:round(Estimate(loop).y+i)
          TargetPic(new_y,new_x,1)=255;
          TargetPic(new_y,new_x,2)=255;
          TargetPic(new_y,new_x,3)=255;
       end
end

     imshow(TargetPic);
     F = getframe;
     image_source=strcat('C:\Users\lenovo\Desktop\�������\result\',num2str(loop),'.jpg');
     imwrite(F.cdata,image_source);  
end

