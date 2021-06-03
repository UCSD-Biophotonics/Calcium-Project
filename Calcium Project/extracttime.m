%clear workspace
clear all, close all;
%extracted all file image names from folder
fileNames = getFiles('/Users/crabbypatties/FOV 1/Image');
%extracted time strings from all files
time = extractBetween(fileNames,"19","_ms");
%convert everything to seconds
hour_sec = 3600 * str2num((char((extractBetween(time, "_","h")))));
minute_sec = 60 * str2num((char((extractBetween(time, "h","m")))));
second = str2num((char((extractBetween(time, "m_","s")))));
totseconds = hour_sec + minute_sec + second

%plot(totseconds) to check

%subtract seconds from first
subtractsecond = totseconds - totseconds(1)

%plot(subtractsecond) to check

%write to a csv file
fid = fopen('/Users/crabbypatties/FOV 1/data/alicia_time.csv', 'wt');
fprintf(fid, '%s\n', 'Time');
fprintf(fid, '%d\n', subtractsecond);   %transpose is important!
fclose(fid);