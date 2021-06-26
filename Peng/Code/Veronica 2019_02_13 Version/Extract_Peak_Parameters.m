% Extract_Peak_Parameters ver. 2.2
% Last Modified: 12/28/2018
% Takes raw emissions intensity data of size Nx2 with column 1 containing 
% frame numbers associated with column 2 that containins raw emissions intensity 
% values. All output values are converted to SI units before being stored
% in peak_paramters struct. 
%
% Inputs:
%
% raw_data: input to function is X Y data from CSV plot of raw fluorescent emissions
% intensity.
%
% frame_rate: acquisition rate of images used to calculate relevant peak
%   parameters as well as determine x-axis scale in plots.
%
% bitdepth: used to calculate ymax limit on raw data figure plot
% 
% nID: used to label subplots.
% 
% row, col, and pos: used to access appropriate subplot in figure
% 
% Key Updates:
%
%   12/28/2018
% - Inclusion of user-inputted threshold/prominence value for findpeaks().
%
%   12/24/2018
% - No longer uses peak_isolate.m or peakdet.m rather all peak locations
%   are determined using findpeaks().
% - Isolated peaks are segmented and plotted onto figure 1 as opposed to
%   having its own figure.
% - Output fields of peak_parameters are for each peak found and  include:
%   pks: Nx2 1) location of peak in seconds from start of image acquisition
%   and 2) associated value of peak in deltaF/Fmin data.
%   amp: Amplitudes calculated by doubling average 
%       of half-height measured on both sides of peak FWHM.
%   period (s): FWHM from findpeaks().
%   rrate (s^-1): peak rise rates along left side of FWHM.
%   frate (s^-1): peak fall rate along right side of FWHM.
%   mfrate (s^-1): mean fall rate along left side of FWHM.
%   mrrate (s^-1): mean rise rate along right side of FWHM.
%   freq (s^-1): frequency calculated by inverting distance
%       between two subsequent peaks found using findpeaks().
%   min,max,std: contain absolute minima,maxima,and stdev of raw emissions
%       intensity data and its respective derivative.
%   ends: contains (1) start and (2) end values for raw emissions intesnity
%       data.
%   - Figures: 
%    (f1) DeltaF/F_min with local maxima and peak FWHM ranges highlighted.
%    (f2) Derivative of DeltaF/F_min with local maxima and minima
%       highlighted. Values indicate peak rise and peak fall.
%    (f3) Raw emissions intesnity data is plotted with location of peaks 
%       found for reference.  
%
% Potential Improvements:
%
% - Improve accuracy of period since, segemented peaks seem right side
%   skewed along FWHM. However, consistency of the segementation 
%   may be compensatory to this visual deficit.
%
% - Given some user input(s) for stimulation, distinguish peak parameters 
%   between baseline and stimulus conditions. May need to add fields to
%   peak_parameters.
%
% - Make prominence a user-adjusted value. Con is lack of consistency, but 
%   need to ensure this is sorted out in later analysis. Or adjust in while
%   loop until number of peaks are consistent.
%
%-  Add notes indicating why values might be zero to write to output file
%   for each peak.
%
function peak_parameters = Extract_Peak_Parameters(raw_data,frame_rate,bitdepth,nID,row,col,pos,height,prominence)
global f1 f2 f3 sub

% Defining parameters struct with all variables zero to catch any errors
peak_parameters = struct();
peak_parameters.pknum = 0;
peak_parameters.pks = [0 0];
peak_parameters.amp = [0];
peak_parameters.period = [0];
peak_parameters.rrate = [0];
peak_parameters.frate = [0];
peak_parameters.mrrate = [0, 0];
peak_parameters.mfrate = [0, 0];
peak_parameters.freq = [0];
peak_parameters.pks = [0,0];
peak_parameters.min = [0,0];
peak_parameters.max = [0,0]; 
peak_parameters.std = [0,0];
peak_parameters.mean = [0,0];
peak_parameters.ends = [0,0];



% Taking statistical values for raw intensity data and respective derivative
abs_min = min(raw_data(:,2));
abs_max = max(raw_data(:,2));
abs_std = std(raw_data(:,2));
abs_mean = mean(raw_data(:,2));
abs_start = raw_data(1,2);
abs_end = raw_data(end,2);



% Determing deltaF/Fmin
time = raw_data(:,1)./frame_rate;
%deltaF = raw_data(:,2)./abs_min-1;
deltaF = raw_data(:,2); % edited 1/25/2019

% Taking numeric time-derivatives of raw intensity data
Fc = mode(diff(time));
draw_data = diff(raw_data).*Fc;% A.U./s

abs_dmin = min(draw_data(:,2));
abs_dmax = max(draw_data(:,2));
abs_dstd = std(draw_data(:,2));
abs_dmean = mean(draw_data(:,2));
% Determinig length of domain for first derivative
l = length(draw_data(:,2));
dtime = [1:l]./frame_rate;
delta_ddata = diff(deltaF).*Fc; %note units F.U/s

% Plotting Delta_F/F_min
c1 = 1;
deltaF_std = c1*std(deltaF);
figure(f1)
sub = subplot(row,col,pos);
plot(sub, time, deltaF);
hold on
title(nID,'FontSize',20);
xlabel('Time (s)','FontSize',16);
ylabel('F.U.','FontSize',16);
ymax = max(deltaF)+deltaF_std;
ymin = min(deltaF)-deltaF_std;
ylim([ymin ymax]);
hold on

% Using find peaks to label peaks in delta_F/F_min
% Here, prominence is the standard deviation if it is less than 0.01
% if deltaF_std>0.01
%     prominence=0.01;
% else
%     prominence=deltaF_std;
% end
if isempty(prominence)
    prominence = 0.5*deltaF_std;
elseif isempty(height)
    height = ymin;
end

%[pks,locs,widths,~] = findpeaks(deltaF,time,'MinPeakHeight',height,'MinPeakProminence',prominence,'WidthReference','halfprom');

try
    %[pks,locs,widths,~] = findpeaks(deltaF,time,'MinPeakProminence',prominence,'WidthReference','halfheight');
    [pks,locs,widths,~] = findpeaks(deltaF,time,'MinPeakHeight',height,'MinPeakProminence',prominence,'WidthReference','halfprom');
catch
    fprintf('\n\tError resuting from choice of either height or prominence');
    return
end

% Conditional statement screens for peaks
% if none exsist then program returns zero values for peak parameters
if ~isempty(pks)
    % Labelling local maxima.
    %locs_shift = (locs - raw_data(1,1))./Fc+ 1;
    %pktab = [round(locs_shift.*frame_rate,0), pks];
    j = 1;
    pktab = zeros(length(locs),2);
    loc_i = zeros(length(locs),1);
    for i = 1:length(time)
        if j <= length(locs) && locs(j) == time(i)
            pktab(j,:) = [locs(j), pks(j)];
            loc_i(j) = i;
            j=j+1;
        end
    end

    %plot(time(pktab(:,1)), deltaF(pktab(:,1)), 'rv','MarkerFaceColor','r');
    plot(pktab(:,1), pktab(:,2), 'rv','MarkerFaceColor','r');
    
    %Plotting Raw Intensity data
    welldepth = 2^bitdepth;
    figure(f3)
    sub = subplot(row,col,pos);
    plot(sub, time,raw_data(:,2));
    title(nID,'FontSize',20);
    xlabel('Time (s)','FontSize',16);
    ylabel('F.U.','FontSize',16);
    ymax = abs_max+abs_std/2;
    ymin = abs_min-abs_std/2;
    ylim([ymin ymax]); 
    hold on
    %plot(time(pktab(:,1)), raw_data(pktab(:,1),2), 'rv','MarkerFaceColor','r');
    plot(pktab(:,1), pktab(:,2), 'rv','MarkerFaceColor','r');
    hold off
    
    % Inverting distance between peaks to calculate frequency.
    freq = 1./diff(pktab(:,1)).*frame_rate;
    freq = [0; freq];
    % Period defined as values for widths found in findpeaks().
    period = widths; % value in seconds
    
    % Calculating amp, peak/mean rise rates, and peak/mean fall rates using 
    % indices categorized by peak i with side j of peak. 
    % FWHM_i{i}{j} contains locations of peak values along FWHM. 
    % FWHM{i}{j} contains peak values along FWHM.
    % dFWHM{i}{j} contains numeric derivatives of FWHM in FWHM.
    % hw_amp{i}(:,j) contains half-width amplitude for each side of FWHM.
    % half-width amplitude defined as distiance from pkval to reference line
    % as defined by findpeaks().

    %loc_i = round(locs_shift.*frame_rate,0); %conversion from time to index
    hw_i = round(widths/2./Fc,0); % width of line at to half-height
    dmintab = [];
    dmaxtab =[];

    FWHM_i = [{}];% indices for left and right half peak FWHM
    FWHM = [{}];  % values for left and right half of peak FWHM
    dFWHM = [{}]; % values for derivative of values along FWHM
    hw_amp = [{}]; % amplitude from half height point

    peakfall = [];
    peakrise = [];
    meanfall = [];
    meanrise = [];
    amplitude = [];
    
    xlim = length(deltaF);
    % Calculation of all values for each peak via iteration.
    for i = 1:length(locs)
        % Calculation of peak range.
        left_FWHM = (loc_i(i)-hw_i(i):loc_i(i))';
        right_FWHM = (loc_i(i):loc_i(i)+hw_i(i))';
        
        % Removing values exceeding indices of data
        j=1;
        while left_FWHM(j)<=0
            j=j+1;
        end
        left_FWHM = left_FWHM(j:end);        
        
        j=length(right_FWHM);
        while right_FWHM(j)>xlim
            j=j-1;
        end
        right_FWHM = right_FWHM(1:j);
        
        %Reassigning to cell array
        FWHM_i{end+1} = [{left_FWHM}, {right_FWHM}];
        
        % Sorting peak values according to range.
        % note dFWHM is converted into F.U/s here
        FWHM{end+1} = [{deltaF([FWHM_i{i}{1}])},...
                        {deltaF([FWHM_i{i}{2}])}];
        dFWHM{end+1} = [{diff(FWHM{i}{1}.*Fc)},...
                        {diff(FWHM{i}{2}.*Fc)}];
        % Want only positive values in mean for right side 
        % and negative values in mean for left side.
        pos_right = find(dFWHM{i}{1}>0);
        neg_left = find(dFWHM{i}{2}<0);

        % Calculation of half-height amplitude
        hw_amp{end+1} = [abs(FWHM{i}{1}(1)-FWHM{i}{1}(end)),...
                abs(FWHM{i}{2}(1)-FWHM{i}{2}(end))];

        % Calculation of peak parameters
        peakrise = [peakrise; max(dFWHM{i}{1})];
        peakfall = [peakfall; min(dFWHM{i}{2})];
        if ~isempty(pos_right)
            meanrise = [meanrise; [mean(dFWHM{i}{1}(pos_right)), std(dFWHM{i}{1}(pos_right))]];
        else
            meanrise = [meanrise; [0 0]];
        end
        
        if ~isempty(neg_left)
            meanfall = [meanfall; [mean(dFWHM{i}{2}(neg_left)), std(dFWHM{i}{2}(neg_left))]];
        else
            meanfall = [meanfall; [0 0]];
        end
        
        % Note that here the half-heights of both sides are 
        % averaged to yield final amplitude.
        amplitude =[amplitude; [mean(2.*hw_amp{i}), std(2.*hw_amp{i})]];
        
        % Finding location of local maxima and minima in derivative
        % of deltaF/Fmin. Values are rounded to 3 significant figure before 
        % compared
        try
            max_i = find(round(delta_ddata(FWHM_i{i}{1}),3)==round(peakrise(i),3)) + FWHM_i{i}{1}(1) - 1;
            min_i = find(round(delta_ddata(FWHM_i{i}{2}),3)==round(peakfall(i),3))+ FWHM_i{i}{2}(1) - 1;
        
         % if no location is found then value is rounded up one more place.
         if max_i == FWHM_i{i}{1}(1) - 1
             max_i = find(round(delta_ddata(FWHM_i{i}{1}),2)==round(peakrise(i),2))+ FWHM_i{i}{1}(1) - 1;
          elseif min_i == FWHM_i{i}{2}(1) - 1
              min_i = find(round(delta_ddata(FWHM_i{i}{2}),2)==round(peakfall(i),2))+ FWHM_i{i}{2}(1) - 1;
         end
        catch
            fprintf('\n\t Index exceeded array bounds while search for local max and local min for peak\n');
            continue
        end
        
        dmaxtab = [dmaxtab; max_i];
        dmintab = [dmintab; min_i];
    end
    
    % Plotting first time-derivative of data
    figure(f2)
    hold on
    sub = subplot(row,col,pos);
    plot(dtime,delta_ddata);
    hold on
    plot(dmintab./frame_rate, delta_ddata(dmintab), 'g^','MarkerFaceColor','g');
    hold on
    plot(dmaxtab./frame_rate, delta_ddata(dmaxtab), 'rv','MarkerFaceColor','r');
    title(nID,'FontSize',20);
    xlabel('Time (s)','FontSize',16);
    ylabel('F.U./s (s^-1)','FontSize',16);
    hold off
    
    % Generating Plots of Segmented Peaks
    % location of each peak found using values from findpeaks()
    figure(f1)
    sub = subplot(row,col,pos);
    hold on
    %x = [];
    for i=1:length(FWHM)
        x = [FWHM_i{i}{1}; FWHM_i{i}{2}(2:end)];
        plot(sub, time(x),deltaF(x),'LineWidth',1);
        hold on
    end
else
    hold off
    fprintf('\n\tNo peaks were found with findpeaks() for %s.',nID);
    return
end
 
% Defining Peak Parameters
% Note that units are already accounted for throughout calculation

% Creating index for thresholded values at or exceeding 50% of maximum
% measured value in data. This is to only take in and calculate statistics
% for data that exceeds a certain threshold.

%pks_i = find(pks>0.5*max(pks));
%amp_i = find(amplitude>0.5*max(amplitude));
%pkrise_i = find(peakrise>0.5*max(peakrise));
%pkfall_i = find(abs(peakfall)>0.5*max(abs(peakfall)));

% Period and frequency have outliers removed before averaging
%peak_parameters.period = remove_outliers(period);
%peak_parameters.freq = remove_outliers(freq);
peak_parameters.pknum = length(pks);
peak_parameters.pks = [locs, pks]; %[mean(pks(pks_i)),std(pks(pks_i))];
peak_parameters.period = period; %remove_outliers(period);
peak_parameters.freq = freq;  %remove_outliers(freq);
peak_parameters.amp = amplitude; %[mean(amplitude(amp_i)), std(amplitude(amp_i))];
peak_parameters.rrate = peakrise; %[mean(peakrise(pkrise_i)), std(peakrise(pkrise_i))]; 
peak_parameters.frate = peakfall; %[mean(peakfall(pkfall_i)), std(peakfall(pkfall_i))];
peak_parameters.mrrate = meanrise; %[mean(meanrise(:,1)), std(meanrise(:,1))]; 
peak_parameters.mfrate = meanfall; %[mean(meanfall(:,1)), std(meanfall(:,1))];
% Statistics on raw intensity data and time-derivative of raw intensity data
peak_parameters.min = [abs_min,abs_dmin]; 
peak_parameters.max = [abs_max,abs_dmax]; 
peak_parameters.mean = [abs_mean,abs_dmean];
peak_parameters.std = [abs_std,abs_dstd];
peak_parameters.ends = [abs_start,abs_end];

end

