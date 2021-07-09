clc
clear all
close all
F=12;

%Coefficients
b=fir1(12,0.3,'high');    
bqR=a2dR(b,F);         %Coefficients after rounding

%Original Signal and its DFT after filtering
y=wgn(1,1000,1);          %Noise signal to be used as input
l=0;                      %Keeps track of normalization constant for input
while(1)                  %This loop normalizes the input so that it can be represented 
   l=l+1;
   y=y./2; 
   if (all(abs(y)<1))
       break;
   end
end
y_bin=floor(y*2^7);       %Quantizing input to 8 bits (1-sign,7-Fractional)
y=y_bin*2^(-7);           %Decimal equivalent of quantized Input
fileID = fopen('exp.txt','w');
for i=1:length(y_bin)     %Writes Quantized input into file specified in above line
    y1_bin=dec2bin(y_bin(i),8);
    fprintf(fileID,'%s \n',y1_bin(length(y1_bin)-7:end));
end


%Filter
y_filt1=filter(b,1,y);
x1=[zeros(1,12) y zeros(1,12)];
y1=zeros(1,length(y));  %Output Direct form1
y2=zeros(1,length(y));  %Output Direct form2
for i=1:length(y)       %Loop calculates output
    [y1(i),y2(i)] =calcout(x1(1,i:i+12),bqR,13);  %Function for output calculation
end


%output binary
fileID = fopen('verify.txt','w');
y11=floor(y1*2^13);          %This line is not needed since output can already be represented using specified bits
for i=1:length(y)
    y11_bin=dec2bin(y11(i),14);
    y1(i)*2^13-y11(i); % This output when 0 proves that output is same if Quantized or not and only needs bits alloted to it.
    fprintf(fileID,'%s  \n',y11_bin(length(y11_bin)-13:end));
end



%Quantization Function Rounding
function beq = a2dR(d,n)  
beq=round(d*2^n);
dec2bin(beq)
beq=beq.*2^(-n);
end 

%Quantization Function Truncating
function beq = a2dT(d,n)   
beq=floor(d*2^n);
beq=beq.*2^(-n);
end 

function [temp1,temp2] =calcout(x1,bqR,F)
temp1=0;
temp2=0;
%temp1=x1*bqR';

for i=1:13
    temp1=temp1+a2dT(x1(1,14-i)*bqR(i),F);
    temp2=temp2+a2dT(x1(1,i)*bqR(14-i),F);
end
end
