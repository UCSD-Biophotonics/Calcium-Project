% % % % Quantifying points from a fixed point on the cell. 
% %  folder for files
filefolder=("/Volumes/admin/Veronica/Ptk2 Lysis test/041921/12_39")
% pole corresponding/Volumes/admin/Veronica/Ptk2 Lysis test/030521/11_43 C3 to the chromosome cut
cut_side_polepath=(filefolder + "/cut pole.csv");
Opp_side_polepath=(filefolder + "/opp pole.csv");
fixedpoint_filepath=(filefolder + "/fixed2.csv");
chrom_frag_tippath=(filefolder + "/fragment tip.csv");
sisterpath=(filefolder + "/sis.csv");
timepath=(filefolder + "/time.csv")

 cent_cut_side=readtable(cut_side_polepath);
 cent_opp_side=readtable(Opp_side_polepath);
 fixedpoint=readtable(fixedpoint_filepath);
 chrom_frag_tip=readtable(chrom_frag_tippath);
 Sister=readtable(sisterpath);
 time=readtable(timepath);
  % % % % Time extraction 
d=time(:,2)
d1=table2cell(d); 
d1=extractBetween(d1,"_21","_ms");
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
total_sec1=total_sec - total_sec(6);

% % % 1.) Calculate the Distance using Pythagorean Theorem of Centrosome to Centrosome
 x1 = table2array (cent_cut_side(:,5)) ;
 x2 = table2array (cent_opp_side(:,5));
y1= table2array(cent_cut_side(:,6));
y2=table2array (cent_opp_side(:,6)) ;
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 
 CC=AA + BB;
kintokin= sqrt(CC);
 output=horzcat(total_sec1, kintokin);
 
  % % 2) Fragment to Sister distance
 
 x1 = table2array (Sister(:,5)); 
 x2 = table2array (chrom_frag_tip(:,5));
y1= table2array(Sister(:,6));
y2=table2array (chrom_frag_tip(:,6));
  
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 
 CC=AA + BB;
 dSistoFrag= sqrt(CC);
 output=horzcat(output, dSistoFrag);

%  % 3) Calculate the Distance using Pythagorean Theorem of fixed point to
% kinetochore of chromosome cut. 

 x1 = table2array (cent_cut_side(:,5)) ;
 x2 = table2array (fixedpoint(:,5));
y1= table2array(cent_cut_side(:,6));
y2=table2array (fixedpoint(:,6));
  
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 CC=AA + BB;
cutkinetochore= sqrt(CC);
 output=horzcat(output, cutkinetochore);
 
% % 4) Calculate the Distance using Pythagorean Theorem of fixed point
% cut fragment tip
 x1 = table2array (fixedpoint(:,5)); 
 x2 = table2array (chrom_frag_tip(:,5));
y1= table2array(fixedpoint(:,6));
y2=table2array (chrom_frag_tip(:,6));
  
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 
 CC=AA + BB;
fragmenttip= sqrt(CC);
 output=horzcat(output, fragmenttip); 
 
 % % 5) fixed point to sister
 x1 = table2array (Sister(:,5)); 
 x2 = table2array (fixedpoint(:,5));
y1= table2array(Sister(:,6));
y2=table2array (fixedpoint(:,6));
  
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 
 CC=AA + BB;
 dfragment= sqrt(CC);
 output=horzcat(output, dfragment);

 
 % % 6) Calculate the Distance using Pythagorean Theorem of fixed point to op
 %  pole
 x1 = table2array (cent_opp_side(:,5)); 
 x2 = table2array (fixedpoint(:,5));
y1= table2array(cent_opp_side(:,6));
y2=table2array (fixedpoint(:,6));
  
  A=  x2 - x1;
  B=  y2 - y1;
  
 AA=A.^2;
 BB=B.^2;
 
 CC=AA + BB;
 oppKinetochore= sqrt(CC);
 output=horzcat(output, oppKinetochore);



   z=["time",  "kinetochore to kinetochore",  "fragment to sis", "cut kinetochore", "fragment tip", "sister tip", "sis kinetochore"];
 final_output=vertcat(z, output)
 
 locationsave=(filefolder + "/fixedpoint output.csv")
 T=array2table(final_output);
 writetable(T, locationsave)

y=output(:,2:7);
 s=stackedplot(total_sec1, y)
 
 figlocation=(filefolder + "/stackedplotfixedpoint.fig")
 saveas(gcf,figlocation)


