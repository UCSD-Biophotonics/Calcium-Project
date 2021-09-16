% % % % Quantifying points from a fixed point on the cell for controls no
% cut
% %  folder for files
filefolder=("/Users/veronicagomez/Desktop/test3")
% pole corresponding/Volumes/admin/Veronica/Ptk2 Lysis test/030521/11_43 C3 to the chromosome cut
cut_side_polepath=(filefolder + "/pole1.csv");
Opp_side_polepath=(filefolder + "/pole2.csv");
fixedpoint_filepath=(filefolder + "/fixed.csv");
% chrom_frag_tippath=(filefolder + "/chrome1.csv");
% sisterpath=(filefolder + "/chrome2.csv");
timepath=(filefolder + "/time.csv")

 pole1=readtable(cut_side_polepath);
 pole2=readtable(Opp_side_polepath);
 fixedpoint=readtable(fixedpoint_filepath);
%  tip1=readtable(chrom_frag_tippath);
%  tip2=readtable(sisterpath);
 time=readtable(timepath);
  % % % % Time extraction 
d=time(:,2)
d1=table2cell(d); 
d1=extractBetween(d1,"_20","_ms");
h=extractBetween(d1,"_", "h");
m=extractBetween(d1,"h", "m");
s=extractBetween(d1, "m_", "s");
h=str2double(h);
hour=h * 3600;
m1=str2double(m);
min=m1 * 60;
s=str2double(s);
total_sec=hour + min + s;

% % % % % % % % Enter last precut image in paranthesis here: 
total_sec1=total_sec - total_sec(5);

% % % 1.) Calculate the Distance using Pythagorean Theorem of pole to pole
 x1 = table2array (pole1(:,5)) ;
 x2 = table2array (pole2(:,5));
y1= table2array(pole1(:,6));
y2=table2array (pole2(:,6)) ;
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 
 CC=AA + BB;
kintokin= sqrt(CC);
 output=horzcat(total_sec1, kintokin);
 
  % % 2) tip to tip
 
%  x1 = table2array (tip2(:,5)); 
%  x2 = table2array (tip1(:,5));
% y1= table2array(tip2(:,6));
% y2=table2array (tip1(:,6));
%   
%   A=  x2 - x1;
%   B=  y2 - y1;
%   
%  AA=A.^2;
%  BB=B.^2;
%  
%  CC=AA + BB;
%  dSistoFrag= sqrt(CC);
%  output=horzcat(output, dSistoFrag);

%  % 3) Calculate the Distance using Pythagorean Theorem of fixed point to pole1. 

 x1 = table2array (pole1(:,5)) ;
 x2 = table2array (fixedpoint(:,5));
y1= table2array(pole1(:,6));
y2=table2array (fixedpoint(:,6));
  
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 CC=AA + BB;
cutkinetochore= sqrt(CC);
 output=horzcat(output, cutkinetochore);
 
% % 4) tip1
%  x1 = table2array (fixedpoint(:,5)); 
%  x2 = table2array (tip1(:,5));
% y1= table2array(fixedpoint(:,6));
% y2=table2array (tip1(:,6));
%   
%   A=  x2 - x1;
%   B=  y2 - y1;
%   
%  AA=A.^2;
%  BB=B.^2;
%  
%  CC=AA + BB;
% fragmenttip= sqrt(CC);
%  output=horzcat(output, fragmenttip); 
 
%  % % 5) fixed point to tip2
%  x1 = table2array (tip2(:,5)); 
%  x2 = table2array (fixedpoint(:,5));
% y1= table2array(tip2(:,6));
% y2=table2array (fixedpoint(:,6));
%   
%   A=  x2 - x1;
%   B=  y2 - y1;
%   
%  AA=A.^2;
%  BB=B.^2;
%  
%  CC=AA + BB;
%  dfragment= sqrt(CC);
%  output=horzcat(output, dfragment);

 
 % % 6) Calculate the Distance using Pythagorean Theorem of fixed point to
 % pole 2
 x1 = table2array (pole2(:,5)); 
 x2 = table2array (fixedpoint(:,5));
y1= table2array(pole2(:,6));
y2=table2array (fixedpoint(:,6));
  
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 
 CC=AA + BB;
 oppKinetochore= sqrt(CC);
 output=horzcat(output, oppKinetochore);



   z=["time",  "kinetochore to kinetochore", "pole 1",  "pole 2"];
 final_output=vertcat(z, output)
 
 locationsave=(filefolder + "/fixedpoint output.csv")
 T=array2table(final_output);
 writetable(T, locationsave)

y=output(:,2:4);
 s=stackedplot(total_sec1, y)
 
 figlocation=(filefolder + "/stackedplot.fig")
 saveas(gcf,figlocation)


