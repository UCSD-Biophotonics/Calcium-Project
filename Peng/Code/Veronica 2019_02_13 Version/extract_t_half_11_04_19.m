%User Mannual:
%1. Change the root. (line 9)
%2. Change the number of row of the matrix. (line 11)
%3. Change the number for i. (line 13)
%Do the following only when there are multiple cuts.
%4. Change the cuttime. (line 23/24)
%5. Change the output file name. (at the end)

root = 'Z:\Veronica\SALSA 09272019\FOV 4 Cut at 12, 56, 89, 134\data\ROI\'; %filepath to the folder containing your csv files, you will want to change this when running on your own computer
filetype = '.csv'; %specifies the type of file
final = zeros(22,2); %creates an empty matrix to be filled later with values
%CHANGE HERE!!!!!
for i=3:3
    filenum = "Normalize_TOM_Divide12Mean" + num2str(i); %since the files were titled 1.csv, 2.csv, etc., it will be used in the next line
    
    filepath = strcat(root, filenum, filetype); %this creates/puts together the filename
    wholematrix = csvread(filepath, 1, 0); %reads the files
    x = wholematrix(:,1); %creates an array of x values (times)
    y = wholematrix(:,2); %creates an array of y values (intensities)
    
    % clear max %makes sure no variables called "max" exist so the "max" function can be used
    %plot(x,y) %this was the visualize step
    
    cuttime= x(y==1); %this was the 1st cut time
    %cuttime = 798;
    %CHANGE HERE!!!!!
    %enter the cuttime mannually if there are other cuts.
    
    cutindex = find(x==cuttime); %this indexes the value where the cut time is
    
    cutmin = min(y(cutindex:end)); %finds the "base" of the peak after cut (essentially because the half time is between the peak after cut and the base of the peak)
    cutminindex = find(y==cutmin); %finds the index location of this minimum value
    
    %if cutminindex > cutindex %accounts for special cases like csv 8
        %cy = y(cutindex:cutminindex); %this creates the intensity array that has the peak and half peak in it, making it easier to find the time values for both to later subtract
        %cx = x(cutindex:cutminindex); %this creates the time array that has indexes corresponding to the intensity array I just created, so I can use the same index values I find for "cy" on this one
    %else %for special cases like csv 8 where half intensity is never reached, it just takes all intensities from cut time to end
        cy = y(cutindex:end);
        cx = x(cutindex:end);
    %end
    %Next 3 lines was edited by Peng
    
    responese_index = cutindex + 15; %15 images are about the range of 45 seconds, the peak has to occur within 45s after the cut to be considered as a response to the cut.
    last_image_time = cx(end,:);
    last_image_index = find(x==last_image_time);
    if responese_index < last_image_index
        cy_peak_range = y(cutindex:responese_index);%creates a new intensity array that only contains possible range of peak.
    else
        cy_peak_range = y(cutindex:end);
    end
    
    peak = max(cy_peak_range); %finds the value of the intensity of the peak
    peakindex = find(cy==peak); %indexes the value so we can locate the corresponding time in "cx" for this peak
    
    halfpeak = peak/2+0.5; %this is the exact value of the half peak intensity
    findrange = cy(peakindex:end); %I narrowed down the intensity array to only from the max intensity to minimum intensity because I know the half value has to be within this range
    if min(findrange)< halfpeak %if statement checks if the intensities actually reach the half intensity
        afterhalfpeak = find(findrange<=halfpeak); %this takes all the indexes of all the intensities in findrange that are less than or equal to the half value (because in some cases, in the csv data there might not be an exact half value)
        halfpeak = findrange(afterhalfpeak(1)); %afterhalfpeak(1) is essentially the index of the first value after the peak where the intensity is less than or equal to the half value, and half peak is then set to that intensity
        halfindex = find(cy==halfpeak,1, 'first'); %this takes the actual index of the halfpeak so we can use it later in "cx" to find the corresponding time of this halfpeak
        %'first' allows the find fuction to return only the first value
        %when there are two identical half peaks. ---Peng
        
    else %if intensities never reach half intensity, it takes the minimum intensity index
        halfindex = find(cy==min(findrange));
    end
    
    peaktime = cx(peakindex); %locates the corresponding time to the peak and saves that value
    halftime = cx(halfindex); %locates the corresponding time to the half peak and saves that value
    final(i,2) = cuttime;
    final(i,3) = peaktime;
    final(i,4) =  halftime - peaktime; %saves the subtracted time between the peaks to a location in the matrix
    final(i,1) = i; %this serves as a label to identify the time with the csv file
    final(i,5) = peak;
end
    output = array2table(final,'VariableNames',{'Cell','Cut_time','Peak_time','T_half','Peak_value'}); %writes the matrix containing all subtracted times to a single csv file containing all the times
    %CHANGE HERE!!!!!
    finalwrite = strcat(root,'/T_half for 1st cut',".csv"); %will write to the location where all the csv files are
    %finalwrite = strcat(root,'/T_half for 2nd cut',".csv");
    %finalwrite = strcat(root,'/T_half for 3rd cut',".csv");
    %finalwrite = strcat(root,'/T_half for 4th cut',".csv");
    %finalwrite = strcat(root,'/T_half for 5th cut',".csv");
    %finalwrite = strcat(root,'/T_half for 6th cut',".csv");
    %finalwrite = strcat(root,'/T_half for 7th cut',".csv");
    %finalwrite = strcat(root,'/T_half for 8th cut',".csv");
    
    %finalwrite = strcat(root,'/T_half for 1st perfusion',".csv");
    %finalwrite = strcat(root,'/T_half for 2nd perfusion',".csv");
    %finalwrite = strcat(root,'/T_half for 3rd perfusion',".csv");
    %finalwrite = strcat(root,'/T_half for 4th perfusion',".csv");
    
    writetable(output,finalwrite);

