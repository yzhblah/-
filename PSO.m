clc;
clear;
close all;
warning off;
addpath(genpath(pwd));
 
data=load('Oliver30.txt');
 
a=data(:,2);
b=data(:,3);
C=[a b];                %城市坐标矩阵
n=size(C,1);            %城市数目
D=zeros(n,n);           %城市距离矩阵
 
 
%L_best=ones(Nmax,1);
for i=1:n
    for j=1:n
        if i~=j
            D(i,j)=((C(i,1)-C(j,1))^2+(C(i,2)-C(j,2))^2)^0.5;                    
        end
        D(j,i)=D(i,j); 
     end
end
Nmax=200;
m=10;
 
 
 
%% 初始化所有粒子
for i=1:m
    x(i,:)=randperm(n);  %粒子位置
end
F=fitness(x,C,D);         %计算种群适应度 
%xuhao=xulie(F)           %最小适应度种群序号
a1=F(1);
a2=1;
for i=1:m
    if a1>=F(i)
        a1=F(i);
        a2=i;
    end
end
xuhao=a2;
Tour_pbest=x;            %当前个体最优
Tour_gbest=x(xuhao,:) ;  %当前全局最优路径
Pb=inf*ones(1,m);        %个体最优记录
Gb=F(a2);         %群体最优记录
xnew1=x;
N=1;
while N<=Nmax
    %计算适应度 
    F=fitness(x,C,D);
    for i=1:m
        if F(i)<Pb(i)
            Pb(i)=F(i);      %将当前值赋给新的最佳值
            Tour_pbest(i,:)=x(i,:);%将当前路径赋给个体最优路径
        end
        if F(i)<Gb
            Gb=F(i);
            Tour_gbest=x(i,:);
        end
    end
%  nummin=xulie(Pb)           %最小适应度种群序号
    a1=Pb(1);
    a2=1;
    for i=1:m
        if a1>=Pb(i)
            a1=Pb(i);
            a2=i;
        end
    end
    nummin=a2;
    Gb(N)=Pb(nummin);          %当前群体最优长度
    for i=1:m
      %% 与个体最优进行交叉
      c1=round(rand*(n-2))+1;  %在[1,n-1]范围内随机产生一个交叉位
      c2=round(rand*(n-2))+1;
      while c1==c2
          c1=round(rand*(n-2))+1;  %在[1,n-1]范围内随机产生一个交叉位
          c2=round(rand*(n-2))+1;
      end   
      chb1=min(c1,c2);
      chb2=max(c1,c2);
      cros=Tour_pbest(i,chb1:chb2); %交叉区域矩阵
      ncros=size(cros,2);       %交叉区域元素个数
      %删除与交叉区域相同元素
      for j=1:ncros
          for k=1:n
              if xnew1(i,k)==cros(j)
                 xnew1(i,k)=0;
                  for t=1:n-k
                      temp=xnew1(i,k+t-1);
                      xnew1(i,k+t-1)=xnew1(i,k+t);
                      xnew1(i,k+t)=temp;
                  end                 
              end
          end
      end
      xnew=xnew1;
      %插入交叉区域
      for j=1:ncros
          xnew1(i,n-ncros+j)=cros(j);
      end
      %判断产生新路径长度是否变短
      dist=0;
      for j=1:n-1
          dist=dist+D(xnew1(i,j),xnew1(i,j+1));
      end
      dist=dist+D(xnew1(i,1),xnew1(i,n));
      if F(i)>dist
          x(i,:)=xnew1(i,:);
      end
      %% 与全体最优进行交叉
      c1=round(rand*(n-2))+1;  %在[1,n-1]范围内随机产生一个交叉位
      c2=round(rand*(n-2))+1;
      while c1==c2
          c1=round(rand*(n-2))+1;  %在[1,n-1]范围内随机产生一个交叉位
          c2=round(rand*(n-2))+1;
      end   
      chb1=min(c1,c2);
      chb2=max(c1,c2);
      cros=Tour_gbest(chb1:chb2); %交叉区域矩阵
      ncros=size(cros,2);       %交叉区域元素个数
      %删除与交叉区域相同元素
      for j=1:ncros
          for k=1:n
              if xnew1(i,k)==cros(j)
                 xnew1(i,k)=0;
                  for t=1:n-k
                      temp=xnew1(i,k+t-1);
                      xnew1(i,k+t-1)=xnew1(i,k+t);
                      xnew1(i,k+t)=temp;
                  end                 
              end
          end
      end
      xnew=xnew1;
      %插入交叉区域
      for j=1:ncros
          xnew1(i,n-ncros+j)=cros(j);
      end
      %判断产生新路径长度是否变短
      dist=0;
      for j=1:n-1
          dist=dist+D(xnew1(i,j),xnew1(i,j+1));
      end
      dist=dist+D(xnew1(i,1),xnew1(i,n));
      if F(i)>dist
          x(i,:)=xnew1(i,:);
      end
      %% 进行变异操作
      c1=round(rand*(n-1))+1;   %在[1,n]范围内随机产生一个变异位
      c2=round(rand*(n-1))+1;
      temp=xnew1(i,c1);
      xnew1(i,c1)=xnew1(i,c2);
      xnew1(i,c2)=temp;
       %判断产生新路径长度是否变短
      dist=0;
      for j=1:n-1
          dist=dist+D(xnew1(i,j),xnew1(i,j+1));
      end
      dist=dist+D(xnew1(i,1),xnew1(i,n));
      %dist=dist(xnew1(i,:),D);
      if F(i)>dist
          x(i,:)=xnew1(i,:);
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  F=(x,C,D)         %计算种群适应度 
    %xuhao=xulie(F)           %最小适应度种群序号
    a1=F(1);
    a2=1;
    for i=1:m
       if a1>=F(i)
            a1=F(i);
            a2=i;
        end
    end
    xuhao=a2;
    L_best(N)=min(F);
    Tour_gbest=x(xuhao,:);     %当前全局最优路径
    N=N+1;
   figure(1)
    scatter(C(:,1),C(:,2));
    hold on
    plot([C(Tour_gbest(1),1),C(Tour_gbest(n),1)],[C(Tour_gbest(1),2),C(Tour_gbest(n),2)],'ms-','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g')
    for ii=2:n
    plot([C(Tour_gbest(ii-1),1),C(Tour_gbest(ii),1)],[C(Tour_gbest(ii-1),2),C(Tour_gbest(ii),2)],'ms-','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g')
    end
    hold off
    figure(2)
    plot(L_best);
%     set(findobj('tag','N'),'string',num2str(N-1));%当前迭代次数
%     set(findobj('tag','tour'),'string',num2str(Tour_gbest));%当前最优路径
%     set(findobj('tag','L'),'string',num2str(min(L_best)));%当前最优路径长度       %%%这里的L_best是当前最优路径？？？
    
end
for j=1:Nmax
          if j==1
              Nbest=1;
          elseif L_best(j)<L_best(j-1)
              Nbest=j;
          end
end 
