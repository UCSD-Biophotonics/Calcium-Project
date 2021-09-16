function arr = timedifference(start, fileArr)
    % TIMEDIFFERENCE  Calculated the time difference in miliseconds between different images
    % TIMEDIFFERENCE("image1", ["image2", "image3"]) - Returns array of time differences
    %
    % start (str) - path to image at time 0
    % fileArr (arr) - array of file paths
    % returns arr (arr) - array of time differences in milliseconds
    %

    if ~ischar(start) % Some simple checks, not needed
        error("timedifference function requires STRINGS")
    end

    startDt = getdtfromfilename(start); % Getting datetime object for the starting file
    arr = zeros(1, length(fileArr)); % Pre-allocating an array for speed
    
    for i = 1 : length(fileArr) % Iterating through the files and getting time differences
        arr(i) = getmsdifference(startDt, getdtfromfilename(fileArr(i)));
    end
end

function ms = getmsdifference(dt1, dt2)
    % GETMSDIFFERENCE  Calculates the milisecond difference between 2 datetime objects
    % GETMSDIFFERENCE(datetime1, datetime2) - Returns time difference between dt2 and dt1
    %
    % dt1 (datetime) - datetime object
    % dt2 (datetime) - datetime object
    % Returns ms (int) - time difference between dt2 and dt1
    %

    ms = milliseconds(dt2-dt1);
end

function dt = getdtfromfilename(filename)
    % GETDTFROMFILENAME  Gets the datetime representation of a filename
    % GETDTFROMFILENAME('02_03_20_18h18m_29s_ms703__F1.tif') - Returns datetime object of filename
    %
    % filename (str) - name of the file
    % Returns dt (datetime) - datetime representation of filename
    %

    pattern = '(\d+)_(\d+)_(\d+)_(\d+)h(\d+)m_(\d+)s_ms(\d+)__F\d+\.tif'; % Regex to gather all the values
    match = regexp(filename, pattern, 'tokens', 'once');
    
    if ~size(match) % Checking to see if filename is correct
        dt = datetime(1970,1,1,0,0,0,0); % Setting to epoch 0 cause why not
        return;
    end
    
    match{3} = append('20', match{3}); % Years come in last 2 digits, so need to add 20 to the start
    temp = arrayfun(@(x) str2double(x), match); % Converting string to integers, datetime requires integers

    dt = datetime([temp(3) temp(1) temp(2) temp(4) temp(5) temp(6)+temp(7)/1000]); % cool things!
end

