myFolder = 'C:\Users\maxw0\Matlab Code\tether images\cut cell 19 good';
filePattern = fullfile(myFolder, '*.tif');
tifFiles = dir(filePattern);
k = 1
baseFileName = tifFiles(k).name;
fullFileName = fullfile(myFolder, baseFileName);
fprintf(1, 'Now reading %s\n', fullFileName);
imageArray = imread(fullFileName);
imshow(imageArray);  % Display image.
drawnow; % Force display to update immediately.
roi = drawpolygon('FaceAlpha');
disp(imageArray(1, 1))
disp(mean2(imageArray));
roi2 = drawpolygon('position', roi);