data = csvread('/Users/crabbypatties/FOV 1/data/result.csv');
c1 = data(:,3);
c2 = data(:,4);
c3 = data(:,5);
c4 = data(:,6);
c5 = data(:,7);
c6 = data(:,8);

cell1 = c1 / c6;
cell2 = c2 / c6;
cell3 = c3 / c6;
cell4 = c4 / c6;
cell5 = c5 / c6;

fid = fopen('/Users/crabbypatties/FOV 1/data/ROI/cell1.csv', 'wt');
fprintf(fid, '%s\n', 'Time');
fprintf(fid, '%d\n', cell1);   %transpose is important!
fclose(fid);

fid = fopen('/Users/crabbypatties/FOV 1/data/ROI/cell2.csv', 'wt');
fprintf(fid, '%s\n', 'Time');
fprintf(fid, '%d\n', cell2);   %transpose is important!
fclose(fid);

fid = fopen('/Users/crabbypatties/FOV 1/data/ROI/cell3.csv', 'wt');
fprintf(fid, '%s\n', 'Time');
fprintf(fid, '%d\n', cell3);   %transpose is important!
fclose(fid);

fid = fopen('/Users/crabbypatties/FOV 1/data/ROI/cell4.csv', 'wt');
fprintf(fid, '%s\n', 'Time');
fprintf(fid, '%d\n', cell4);   %transpose is important!
fclose(fid);

fid = fopen('/Users/crabbypatties/FOV 1/data/ROI/cell5.csv', 'wt');
fprintf(fid, '%s\n', 'Time');
fprintf(fid, '%d\n', cell5);   %transpose is important!
fclose(fid);


