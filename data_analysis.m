data_path = 'horse-data.txt';
%读入数据
attribute = textread(data_path);
attribute_name = {'surgery','Age','Hospital Number','rectal temperature','pulse',...
 'respiratory rate','temperature of extremities','peripheral pulse',...
 'mucous membranes','capillary refill time','pain','peristalsis',...
 'abdominal distension','nasogastric tube','nasogastric reflux','nasogastric reflux PH',...
 'rectal examination','abdomen','packed cell volume','total protein',...
 'abdominocentesis appearance','abdomcentesis total protein','outcome',...
 'surgical lesion','lesion1','lesion2','lesion3','cp data'};
number = [4,5,6,16,19,20,22]; %数值属性索引
 
%利用函数tabulate计算每个标称属性可能值的频数
for i = 1:28
    display(attribute_name(i));
    tabulate(attribute(:,i));   
end

%数值属性：最大(max)、最小(min)、均值(mean)、中位数(median)、四分位数(prctile)及缺失值的个数(-1的个数)
fp = fopen('C:\研究生阶段资料\course\数据挖掘\2017\马的疝病分析\attribute.txt','w');
for i = 1:7
    name = attribute_name{number(i)};
    fprintf(fp,'%s\r\n',name);
    temp = attribute(:,number(i));
    z = numel(find(isnan(temp)));    
    temp = temp(~isnan(temp));
    fprintf(fp,'max: %s\r\n',num2str(max(temp)));
    fprintf(fp,'min: %s\r\n',num2str(min(temp)));
    fprintf(fp,'mean: %s\r\n',num2str(mean(temp)));
    fprintf(fp,'median: %s\r\n',num2str(median(temp)));
    fprintf(fp,'quartile-1/4: %s\r\n',num2str(prctile(temp,25)));
    fprintf(fp,'quartile-3/4: %s\r\n',num2str(prctile(temp,75)));
    fprintf(fp,'missing: %s\r\n',num2str(z));  
    fprintf(fp,'\r\n');
end
fclose(fp);

%绘制各标称属性直方图
for i = 1:7
   subplot(2,4,i);
   hist(attribute(:,number(i)));
   title(attribute_name{number(i)});
end

%绘制各标称属性qq图
for i = 1:7
     subplot(2,4,i);
    qqplot(attribute(:,number(i)));
    title(attribute_name{number(i)});
end

%绘制各标称属性盒图
for i = 1:7
    subplot(2,4,i);
    boxplot(attribute(:,number(i)));
    title(attribute_name{number(i)});
end

%缺失值处理——剔除
%查找缺失数据项
k = 1;
mis = find(~isnan(attribute(:,1)));
for i = 1:28
    temp = find(~isnan(attribute(:,i)));
    mis = intersect(mis,temp);
end
fp = fopen('C:\研究生阶段资料\course\数据挖掘\2017\马的疝病分析\delete_missing_data.txt','w');
for i = 1:length(mis);
    temp = attribute(mis(i),:);
    temp = num2str(temp);
    fprintf(fp,'%s\r\n',temp);
end
fclose(fp);
attribute_temp = textread('C:\研究生阶段资料\course\数据挖掘\2017\马的疝病分析\delete_missing_data.txt');
%绘制各标称属性直方图
for i = 1:7
   subplot(2,4,i);
   hist(attribute_temp(:,number(i)));
   title(attribute_name{number(i)});
end


%缺失值处理——最高频率值填补
 for i = 1:28
     a = tabulate(attribute(:,i));
     m = max(a(:,2));
     for j = 1:length(a(:,2))
         if a(j,2)==m
             num = a(j,1);
             break;
         end
     end
     temp = find(isnan(attribute(:,i)));
     for k = 1:length(temp)
         attribute(temp(k),i) = num;
     end
 end
 fp = fopen('highest_missing_data.txt','w');
 for i = 1:368;
     temp = attribute(i,:);
    temp = num2str(temp);
     fprintf(fp,'%s\r\n',temp);
 end
 fclose(fp);
% %绘制各标称属性直方图
 for i = 1:7
    subplot(2,4,i);
    hist(attribute(:,number(i)));
    title(attribute_name{number(i)});
 end


%缺失值处理——属性的相关关系填补
 cc = corr(attribute(:,2),attribute(:,3))
 for i = 1:28
     for j = 1:28
         c(j,i)=corr(attribute(:,i),attribute(:,j)); 
     end
 end
 %计算关系式
 figure;  
 t=attribute(:,3);  
 c=attribute(:,2);  
 a=polyfit(t,c,1);  
 ti=1:9;  
 ci=polyval(a,ti);  
 plot(t,c,'go','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',6);  
 xlabel('Hospital Number');  
 ylabel('Age');   
 hold on  
 plot(ti,ci,'linewidth',2,'markersize',16)  
 legend('原始数据点','拟合曲线')  
 plot(t,c,'-r.')  
 sprintf('曲线方程：Age=+(%0.5g)*Hospital Number+(%0.5g)',a(1),a(2))
 figure;  
 t=attribute(:,2);  
 c=attribute(:,3);  
 a=polyfit(t,c,1);  
 ti=1:2;  
 ci=polyval(a,ti);  
 plot(t,c,'go','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',6);  
 xlabel('Age');  
 ylabel('Hospital Number');    
 hold on  
 plot(ti,ci,'linewidth',2,'markersize',16)  
 legend('原始数据点','拟合曲线')  
 plot(t,c,'-r.')  
 sprintf('曲线方程：Hospital Number=+(%0.5g)*Age+(%0.5g)',a(1),a(2)) 
 
 for i = 1:28
    subplot(4,7,i);
    hist(attribute(:,i));
    title(attribute_name{i});
 end

%缺失值处理——数据对象之间的相似性填补
 sim = pdist(attribute,'euclidean');
 k = 1;
 i = 1;
 while( i < (length(similarity)-1) ) 
     loc = find(min(similarity(i:(i+368-k))));
     nan = find((attribute(k,:)==-1));
     for j = 1:length(nan)
         attribute(k,nan(j)) = attribute((k+loc),nan(j));
     end
     i = i+368-k;
     k = k+1;   
end

attribute = textread('similarity_missing_data.txt');

for i = 1:7
   subplot(2,4,i);
   hist(attribute(:,number(i)));
   title(attribute_name{number(i)});
end
