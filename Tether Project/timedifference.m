function arr = timedifference(start, fileArr)
    % Too lazy to document
    % Returns arr of time differences
    if ~ischar(start)
        error("timedifference function requires STRINGS")
    end

    startDt = getdtfromfilename(start);
    arr = zeros(1, length(fileArr));
    
    disp(length(fileArr))
    
    for i = 1 : length(fileArr)
        arr(i) = getmsdifference(startDt, getdtfromfilename(fileArr(i)));
    end
end

function ms = getmsdifference(dt1, dt2) 
    % Gets ms difference between 2 datetimes
    ms = milliseconds(dt2-dt1);
end

function dt = getdtfromfilename(filename) 
    % Gets datetime representaion of filename
    pattern = '(\d+)_(\d+)_(\d+)_(\d+)h(\d+)m_(\d+)s_ms(\d+)__F\d+\.tif'; % Regex to gather all the values
    match = regexp(filename, pattern, 'tokens', 'once');
    
    if ~size(match) % Checking to see if filename is correct
        dt = datetime(1970,1,1,0,0,0,0); % Setting to epoch 0 cause why not
        return;
    end
    
    match{3} = append('20', match{3}); % Years come in last 2 digits, so need to add 20 to the start
    temp = arrayfun(@(x) str2double(x), match); % Converting string to integers, datetime requires integers

    dt = datetime([temp(3) temp(1) temp(2) temp(4) temp(5) temp(6)+temp(7)/1000]);
end

