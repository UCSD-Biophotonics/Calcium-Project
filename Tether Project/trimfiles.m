directory = pwd + "/images";
original_dir = pwd;

% Takes user input for directory - can be deleted later %
%inpt = input("Where are the images located? (Entering nothing will result in current directory: ", "s");
%
%if ~strcmp(inpt, "")
%    directory = inpt;
%end

cd(directory); % Changes directory for simplicity %

files = dir("*.tif"); % Gets all the files from the directory %
len = length(files); % Gets number of files in the directory %
skip = max(floor(len/100), 1); % How many files to skip in order to get ~100 or so files %

if ~isfolder("output") % Creates output folder if not exists %
    mkdir("output");
end

for i=1:len % Iterates through the file list %
    if mod(i-1, skip) == 0 % Checks to see if we should add the file %
        file = files(i);

        name = file.name;

        copyfile(name, "output/" + name, "f"); % Copies file into directory %
    end
end

cd(original_dir);
