function trimfiles(imageDir, outputDir, numFiles)
    % TRIMFILES  Copies a specified amount of tiff images from a specified directory to another
    % TRIMFILES('C:\Users\USER\documents\images', 'C:\Users\USER\documents\images\output', 100) - Copies
    % 100 files from C:\Users\USER\documents\images to C:\Users\USER\documents\images\output
    % TRIMFILES('images', 'images\output', 100) - Copies 100 images from dir\images to dir\images\output
    % TRIMFILES() - Copies 100 images from current dir to /output
    %
    % imageDir (str) - path to the directory of the images (optional, defaults to current dir)
    % outputDir (str) - path to the directory of the outputted images (optional, defaults to current dir/filetrim)
    % numFiles (int) - number of files you want (optional, defualts to 100)
    %

    if ~exist('imageDir', 'var')
        imageDir = pwd;
    end
    if ~exist('outputDir', 'var')
        outputDir = imageDir + "/filetrim";
    end
    if ~exist('numFiles', 'var')
        numFiles = 100;
    end

    files = dir(imageDir + "/" + "*.tif"); % Gets all the files from the directory 
    len = length(files); % Gets number of files in the directory 
    skip = max(floor(len./numFiles), 1); % How many files to skip in order to evenly take sample of numFiles 

    if ~isfolder(outputDir) % Creates output folder if not exists 
        mkdir(outputDir);
    end
    i = 1;
    while i<len % Iterates through the file list 
        %if mod(i-1, skip) == 0 % Checks to see if we should add the file 
        file = files(i);
        name = file.name;

        copyfile(imageDir + "/" + name, outputDir + "/" + name, 'f'); % Copies file into directory 
        i = i + numFiles;
            %numFiles = numFiles - 1; 
            %if numFiles <= 0 % Checks to see if we have copied enough files
            %    break
            %end
        %end
    end
end
