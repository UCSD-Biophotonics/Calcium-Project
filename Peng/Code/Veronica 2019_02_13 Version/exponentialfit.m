clear all
close all
v=uiimport;

%%
x=v.data(:,1);
y=v.data(:,2);

xint=x(end)-x(1);
N=numel(x);
x=linspace(0,xint,N);
x=x';

dx=1/2*(x(2)-x(1));
dy=input('Enter Approximation of Noise Voltage Error: ');

dx=dx*ones(size(x));
dy=dy*ones(size(y));

%%
errorbarxy(x,y,dx,dy);
model=@(p,x)p(1).*exp(-x./p(2))+p(3);

Ag=input('Enter estimate for parameter A: ');
taug=input('Enter estimate for parameter tau: ');
Bg=input('Enter estimate for parameter B: ');

results=wnlfit(x,y,dx,dy,model,[Ag taug Bg]);

%%
pname={'A','tau','B'};
for i=1:size(pname,2)
    fprintf('Parameter %s = %6e +/- %1e \n',pname{i},results.param(i),results.paramerr(i));
end