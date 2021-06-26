writeto = "Z:\Shockwave\November 10\data";
for i = 1:30
    A = zeros(1,2);
    filename = num2str(i) + ".csv";
    fullfilename = fullfile(writeto, filename);
    writematrix(A, fullfilename);
  
    
end
