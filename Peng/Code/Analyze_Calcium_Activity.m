% Analyze_Calcium Activity ver. 2.2
% Last Modified 12/28/2018
%
% Inputs:
%
% directory: characer array indicating path to folder that containes csv 
%   files to be read in by program
%
% files: cell array of strings containing names of csv files being read 
%   in by funciton
%
% method: indicates execution of code: 
%   (1) or "plot" Generates plots for the provided directory of csv files. 
%   (2) or "extract" Extracts parameters from the provided csv files using
%   Extract_Peak_Parameters() then, either appends or writes to Output.csv.
%
% neurons: numeric array of numbers used to indicate which files are being
%   read in by function
%
% append: boolean variable indicating whether or not to append to exsisting
%   Output.csv file.
%
% stim_pos: NOT CURRENTLY USED. Will indicate starting position of
% experimentally applied stimulus in data sets. 
%
% user_data: cell array of user inputted data for the given set of csv files
%   that notes details of image acquistion. Used to help create figure labels and
%   for later analysis of Output.csv:
%   {1} acquisition date of given data set.
%   {2} day in vitro. 
%   {3} genotype.
%   {4} sample dish number.
%   {5} trial number for given sample dish.
%   {6} objective magnification.
%   {7} sample chamber style.
%   {8} frame rate of image acquisition.
%   {9} bitdepth of camera during image acquistion.
%
% Key Updates:
%
%   12/28/18
% - write: boolean user-input for deciding whether to write to file in 'extract' mode
% - user_data{10}: threshold used in findpeaks() for
%   Extract_Peak_Parameters().
%
%   12/24/18
% - Peak paramters for each peak found in raw data is stored in output file
%   with peak number listed alongside in an additional column. Size of data
%   categories reduced as no statistics are carried out. Note that 0 values
%   for meanrise and meanfall indicate it couldn't be calculated.
%   Similarly, 0 values for freq indicate either none could be calculated
%   or that it is associated with the first peak.
%
% Potential Improvements:
%
% - Query user whether or not to write data during "extract" method.
%
% - Restrict number of subplots per figure to aid data visualization as
%   well as remove unused positions of subplot and resize if no peaks are
%   found while using Extract_Peak_Parameters().
% 
function Analyze_Calcium_Activity(directory,files,method,neurons,append,stim_pos,user_data,write)
global f1 f2 f3 sub

% User inputted parameters for identifying and categorizing data
date = user_data{1};
genotype = user_data{3};
dish = strcat("Dish ", user_data{4}); 
trial = strcat("Trial ", user_data{5});
frame_rate = str2double(user_data{8}); %Hz
bitdepth = str2double(user_data{9});
height = str2double(user_data{10});
prom = str2double(user_data{11});

% Labeling and naming of figures with subplots
figname = strcat(date," ",genotype," ",dish," ",trial);
f1 = figure('Name',figname,'NumberTitle','off','Visible','off');
f2 = figure('Name',"Derivative of Relative Emissions Intensity",'NumberTitle','off');
f3 = figure('Name',"Raw Emissions Intensity",'NumberTitle','off');

% Allocation of space for images in sublplot.
plotnum = length(neurons);
[m,n] = subplot_tiling(plotnum);

% Value of method selects cases for analysis: 
% - "plot" case generates plots of raw emissions intensity data for
%   all neurons without any analysis.
% - "extract" case generates plots of analysis and generates peak
%   parameters for each neuron specified in file.pp.
anum = method; 
analysis = ["plot","extract"]; 

% All but one figure made invisible for "plot" case
if lower(analysis(anum))=="plot"
    set(figure(f1),'Visible','on');
    set(figure(f2),'Visible','off');
    set(figure(f3),'Visible','off');
end

% Creation of structure containing file name information
file = struct();
file.neuron = [];   % file names for csv data on each neuron in FOV for respective trial #
file.data = [];     % raw_data for each neuron listed in file.neuron
file.pp = [];       % peak parameters extracted for each neuron

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Counting number of csv files.
% Generating names of plot csv file in folder.
% Here, names of user selected files are identified and 
% stored for generating subplots
for(i=1:length(neurons))
    file.neuron = [file.neuron; {fullfile(directory,files{neurons(i)})}];
end


for(k=1:length(file.neuron))
    % Subplot label nID
    nID = strcat("Neuron ",num2str(neurons(k)));

    % Reading data from file
    % try and catch in case of 1st row with X Y characters
    try
        filename = file.neuron{k};
        raw_data = [file.data; csvread(filename)];
    catch 
        raw_data = [file.data, csvread(filename,1,0)];
    end

    % "extract" method calculates peak paramters and generates plots
    if(lower(analysis(anum))=="extract")
        file.pp = [file.pp, Extract_Peak_Parameters(raw_data,frame_rate,bitdepth,nID,m,n,k,height,prom)];         
    
    % "plot" method generats plot of '\Delta F/ F_{min}'
    else
    abs_min = min(raw_data(:,2));
    figure(f1)
    sub = subplot(m,n,k);    
    % tray and catch in order to continue plotting for subsequent csv
    % files.
    try
        %deltaF = (raw_data(:,2)./abs_min)-1;
        deltaF = raw_data(:,2);
        time = raw_data(:,1)./frame_rate;
        plot(sub,time,deltaF);
    catch
        fprintf("\n Error attempting to plot data! Re-check entries to  \n ensure Framerate and Neurons have valid entries.\n");
        return
    end
    title(nID,'FontSize',20);
    xlabel('Time (s)','FontSize',16);
    ylabel('A.U.','FontSize',16);
    % here ylim is determined on neuron-by-neuron basis
    ymax = max(deltaF); 
    ylim([0 ymax]);
    hold on
    end
end

% Final labelling of figures and writing to output file
if(lower(analysis(anum))=="extract") && write ==1
%     % Supertitle for subplots in figure(f1)
%     figure(f1);
%     subplot(sub);
%     suptitle('\Delta F/ F_{min}');
% 
%     figure(f2);
%     subplot(sub);
%     suptitle('d/dt(\Delta F/ F_{min})');
    % Opening and writing peak parameters to Output.csv file.
    % Cell arrays with column names classify datatype in formatSpec, which
    % is utilized for values written to Output.csv.
    % Input: strings or '%s'; typically user-inputted data in user_data{}
    % Num: signed integer or '%d';
    % Extract: floating-point number or '%f';typically fields in peak_parameters

    Input = {'Acquisition Date','DIV','Genotype','Dish','Trial',...
        'Magnification','Chamber'};
    Num = {'Neuron','FPS','Bitdepth','Peak Num'};
    Extract ={'Peak Location (s)', 'Peak Value',...
            'Amplitude',...
            'FWHM (s)',...
            'Mean Rise Rate (s^-1)','Stdev Mean Rise Rate(s^-1)',...
            'Peak Rise Rate (s^-1)',...
            'Mean Fall Rate(s^-1)','Stdev Mean Fall Rate(s^-1)',...
            'Peak Fall Rate (s^-1)',...
            'Frequency (Hz)',...
            'I - Maximum','I - Minimum','I - Mean','I - Stdev','dI/dt - Maximum',...
            'dI/dt - Minimum','dI/dt - Mean','dI/dt - Stdev','I - Start','I - End'};  
    format = [];
    if(lower(analysis(anum))=='extract')
        if append == 0 || exist('Output.csv','file') == 0
            fid = fopen('Output.csv','w');
            C=[Input,Num,Extract];
            for i = 1:length(C)
                format = [format,'%s,'];
            end
            format = [format,'%s\n'];
            fprintf(fid,format,C{:});
        else
            fid = fopen('Output.csv','a');
        end
    end

    %Datatype for variables writtent to Output.csv
    
    formatSpec = '\n'; %selects next row 
    Input
    length(Input)
    
    for i = 1:length(Input)
        formatSpec = [formatSpec,'%s,'];
    end

    for i = 1:length(Num)
        formatSpec = [formatSpec,'%d,'];
    end

    for i =1:length(Extract)-1
        formatSpec = [formatSpec,'%f,'];
    end
    formatSpec = [formatSpec,'%f']; %last entry has no comma

    length(file.pp)
    
    for row = 1:length(file.pp)
        
        row
        
        length(file.pp)
        
        for peak = 1:file.pp(row).pknum
            
            peak
          C={user_data{1},user_data{2},user_data{3},user_data{4},user_data{5},...
              user_data{6},user_data{7},...%Input
              neurons(row),frame_rate,bitdepth,peak,... %Num
              file.pp(row).pks(peak,1), file.pp(row).pks(peak,2),...%Extract
              file.pp(row).amp(peak),...
              file.pp(row).period(peak),...
              file.pp(row).mrrate(peak,1), file.pp(row).mrrate(peak,2),...
              file.pp(row).rrate(peak)...
              file.pp(row).mfrate(peak,1), file.pp(row).mfrate(peak,2),...
              file.pp(row).frate(peak),...
              file.pp(row).freq(peak),...
              file.pp(row).max(1), file.pp(row).min(1),file.pp(row).mean(1),file.pp(row).std(1),...
              file.pp(row).max(2), file.pp(row).min(2),file.pp(row).mean(2),file.pp(row).std(2),...
              file.pp(row).ends(1), file.pp(row).ends(2)};
          fprintf(fid,formatSpec,C{:});  
        end
    end
    fclose(fid);
elseif (lower(analysis(anum))=="plot")
%     figure(f1);
%     subplot(sub);
%     suptitle('\Delta F/ F_{min}');
    return
else
    fprintf('\n\t Extraction of Peak Parameters Successful. No output file has been appended or overwritten.\n');
end

fprintf('\n');
end
    
    