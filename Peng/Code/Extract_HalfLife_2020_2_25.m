%User Mannual: (Updated 2/13/2020)
%1. Change the root. (line 6)
%2. Change the number for i. (line 12)
%3. Change the filename. (line 13)
%5. Change the cutindex & next cutindex. (line 20/21)
root1 = "Z:\Veronica\AST1 Fluo-4\06132019 APB 5uM have Thalf\D1 FOV 2 drug @ 38, cut c1 @ 152, c3 @ 186\data\";
root2 = "sub ROI\";
root = root1 + root2;
filetype = '.csv';
final = zeros(1,2); %creates an empty matrix to be filled later with values
cutindex = 50;%CHANGE the cuts here
for i= 3
    filenum = num2str(i); 
    %
    filepath = strcat(root, filenum, filetype); %this creates/puts together the filename
    wholematrix = csvread(filepath, 1, 0); %reads the files
    x = wholematrix(:,1); %creates an array of x values (times)
    y = wholematrix(:,2); %creates an array of y values (intensities)
    
    
    %next_cutindex = 221;
    next_cutindex = numel(x); %If it's the last cut, all the way to the last image 
    cuttime = x(cutindex);
    next_cuttime = x(next_cutindex);
    
    %cuttime = 144;
    %next_cuttime = 696;
    %cutindex = find(x==cuttime);
    
    cy = y(cutindex:end);%this creates the intensity array that has the peak and half peak in it, making it easier to find the time values for both to later subtract
    cx = x(cutindex:end);%this creates the time array that has indexes corresponding to the intensity array I just created, so I can use the same index values I find for "cy" on this one

    %FIND PEAK
    %----------------------------------------
    last_image_time = cx(end,:);
    peakrange_time = cuttime + 100;
    if peakrange_time > last_image_time
        peakrange_time = last_image_time;
    end
       
    after_peakrange = find(cx>=peakrange_time); %this takes all the indexes of all the intensities in findrange that are less than or equal to the peak value
    peakrange_onsheet = cx(after_peakrange(1)); %after_peakrange(1) is essentially the index of the first value after the peakrange
    peakrange_index = find(x==peakrange_onsheet,1, 'first'); %this takes the actual index of the peakrange
    
    last_image_index = find(x==last_image_time);
    cy_peak_range = y(cutindex:peakrange_index);%creates a new intensity array that only contains possible range of peak.

    peak = max(cy_peak_range); %finds the value of the intensity of the peak
    peakindex = find(cy==peak,1,'first'); %indexes the value so we can locate the corresponding time in "cx" for this peak
    %----------------------------------------
    
    %FIND PLATEAU
    %----------------------------------------
    peaktime = cx(peakindex); %locates the corresponding time to the peak and saves that value
    %NEED A IF STATEMENT HERE
    
    plateaurange_time = peaktime + 250;%next_cuttime;
    if plateaurange_time > next_cuttime
        plateaurange_onsheet = next_cuttime;
    else
        after_plateaurange = find(cx>=plateaurange_time); %this takes all the indexes of all the intensities in findrange that are less than or equal to the plateau value
        plateaurange_onsheet = cx(after_plateaurange(1)); %after_plateaurange(1) is essentially the index of the first value after the plateaurange
    end
    plateaurange_index = find(cx==plateaurange_onsheet,1, 'first'); %this takes the actual index of the plateaurange

    plateau = min(cy(peakindex:plateaurange_index)); %find the mininum between the peak and the following cut as the plateau
    
    plateau_index = find(cy==plateau,1,'first');%find the index location of the plateau
    
    if plateau_index < peakindex %In case there is a image before peak which has extact same intensity as plateau
        plateau_index = find(cy==plateau,1,'last');%find the index location of the plateau
    %else
        %plateau_index_real = plateau_index;
    end 
    %----------------------------------------

    %FITTING
    %----------------------------------------
    intensity_array = cy(peakindex:plateau_index); %create an intensity array from the peak to the plateau
    time_array = cx(peakindex:plateau_index); %create an time array from the peak to the plateau
    
    plateau_time = cx(plateau_index);
    
    points_num = numel(intensity_array);%number of intensity array elements
    try
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        %opts.Normalize = 'on';
        
        [f, gof] = fit(intensity_array,time_array,'exp2',opts); %2 phase exponential decay fitting
   
        half_peak = (peak - plateau)/2 + plateau;
        half_life = f(half_peak) - peaktime;

        r2 = gof.rsquare; %Obtain R-square to examine the goodness of fitting.
    catch %Any error goes to NA
        half_life = "NA";
        r2 = "NA";
    end
    %----------------------------------------
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
    output_filename = "Half-life for the "+cuttime+"s cut";

    finalwrite = strcat(root1,output_filename,filetype); %will write to the location where all the csv files are
    
    writetable(output,finalwrite);

