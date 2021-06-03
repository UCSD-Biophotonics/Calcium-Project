%https://stackoverflow.com/questions/2652630/how-to-get-all-files-under-a-specific-directory-in-matlab
function fileList = getFiles(dirName)

 dirData = dir(dirName);      %# Get the data for the current directory
 dirIndex = [dirData.isdir];  %# Find the index for directories
 fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files