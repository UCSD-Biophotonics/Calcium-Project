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
for i=1:22
    filenum = "Normalize_TOM_Divide12Mean" + num2str(i); %since the files were titled 1.csv, 2.csv, etc., it will be used in the next line
    
    filepath = strcat(root, filenum, filetype); %this creates/puts together the filename
    wholematrix = csvread(filepath, 1, 0); %reads the files
    x = wholematrix(:,1); %creates an array of x values (times)
    y = wholematrix(:,2); %creates an array of y values (intensities)
    
    % clear max %makes sure no variables called "max" exist so the "max" function can be used
    %plot(x,y) %this was the visualize step
    
    %cuttime= x(y==1); %this was the 1st cut time
    cuttime = 184;
    next_cuttime = 296;
    %CHANGE HERE!!!!!
    %enter the cuttime mannually if there are other cuts.
    
    cutindex = find(x==cuttime); %this indexes the value where the cut time is
    
    %cutmin = min(y(cutindex:end)); %finds the "base" of the peak after cut (essentially because the half time is between the peak after cut and the base of the peak)
    %cutminindex = find(y==cutmin); %finds the index location of this minimum value
    
    %if cutminindex > cutindex %accounts for special cases like csv 8
        %cy = y(cutindex:cutminindex); %this creates the intensity array that has the peak and half peak in it, making it easier to find the time values for both to later subtract
        %cx = x(cutindex:cutminindex); %this creates the time array that has indexes corresponding to the intensity array I just created, so I can use the same index values I find for "cy" on this one
    %else %for special cases like csv 8 where half intensity is never reached, it just takes all intensities from cut time to end
        cy = y(cutindex:end);
        cx = x(cutindex:end);
    %end
    
    responese_index = cutindex + 12; %15 images are about the range of 45 seconds, the peak has to occur within 45s after the cut to be considered as a response to the cut.
    last_image_time = cx(end,:);
    last_image_index = find(x==last_image_time);
    if responese_index < last_image_index
        cy_peak_range = y(cutindex:responese_index);%creates a new intensity array that only contains possible range of peak.
    else
        cy_peak_range = y(cutindex:end);
    end
    
    peak = max(cy_peak_range); %finds the value of the intensity of the peak
    peakindex = find(cy==peak); %indexes the value so we can locate the corresponding time in "cx" for this peak
    
    next_cuttime_index = find(cx==next_cuttime); %find the index location of the following cut
    plateau = min(cy(peakindex:next_cuttime_index)); %find the mininum between the peak and the following cut as the plateau
    plateau_index = find(cy==plateau); %find the index location of the plateau
    
    intensity = cy(peakindex:plateau_index); %create an intensity array from the peak to the plateau
    time = cx(peakindex:plateau_index); %create an time array from the peak to the plateau
    
    peaktime = cx(peakindex); %locates the corresponding time to the peak and saves that value
    plateau_time = cx(plateau_index);
    
    points_num = numel(intensity);%number of intensity array elements
    if points_num < 2
        half_life = "NA"; %need at least 2 data points to fit this exp1 model
        r2 = "NA";
    else
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        %opts.Normalize = 'on';
        
        [f, gof] = fit(time,intensity,'exp1',opts); %1 phase exponential decay fitting
        %Lamda1 = -f.b;
        %Lamda2 = -f.d;
        a = f.a;
        b = f.b;
        
        syms x;
        f1(x) = f.a*exp(f.b*x);
        g = finverse(f1);
        
        half_peak = (peak - plateau)/2 + plateau;
        half_life = g(half_peak) - peaktime;
        %half_life = log(half_peak/f.a)/f.b - peaktime;
        %half_life = log(2)/(Lamda1+Lamda2);
        %half_life = f((peak-plateau)/2+plateau)-peaktime;
        r2 = gof.rsquare;
    end
    final(i,1) = i; %this serves as a label to identify the time with the csv file
    final(i,2) = peaktime;
    final(i,3) = peak;
    final(i,4) = plateau_time; %saves the subtracted time between the peaks to a location in the matrix
    final(i,5) = plateau;
    final(i,6) = half_life;
    final(i,7) = r2;
    final(i,8) = points_num;
end
    output = array2table(final,'VariableNames',{'Cell','Peak_Time','Peak_Value','Plateau_Time','Plateau_Value','Half_Life','Rsquare','Num_Points'}); %writes the matrix containing all subtracted times to a single csv file containing all the times
    %CHANGE HERE!!!!!
    output_filename = "Half-life for the "+cuttime+"s cut1";
    finalwrite = strcat(root,output_filename,filetype); %will write to the location where all the csv files are
    %finalwrite = strcat(root,'/Half-life for 2nd cut',".csv");
    %finalwrite = strcat(root,'/Half-life for 3rd cut',".csv");
    %finalwrite = strcat(root,'/Half-life for 4th cut',".csv");
    %finalwrite = strcat(root,'/Half-life for 5th cut',".csv");
    %finalwrite = strcat(root,'/Half-life for 6th cut',".csv");
    %finalwrite = strcat(root,'/Half-life for 7th cut',".csv");
    %finalwrite = strcat(root,'/Half-life for 8th cut',".csv");
    
    %finalwrite = strcat(root,'/Half-life for 1st perfusion',".csv");
    %finalwrite = strcat(root,'/Half-life for 2nd perfusion',".csv");
    %finalwrite = strcat(root,'/Half-life for 3rd perfusion',".csv");
    %finalwrite = strcat(root,'/Half-life for 4th perfusion',".csv");
    
    writetable(output,finalwrite);

