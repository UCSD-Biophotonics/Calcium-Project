myFolder = 'C:\Users\maxw0\Matlab Code\tether images\cut cell 19 good';
if ~isfolder(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
filePattern = fullfile(myFolder, '*.tif');
tifFiles = dir(filePattern);
for k = 1:length(tifFiles)
  baseFileName = tifFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  imageArray = imread(fullFileName);
  imshow(imageArray);  % Display image.
  drawnow; % Force display to update immediately.
end

function sliderSin
FigH = figure('position',[360 500 400 400]);
axes('XLim', [0 4*pi], 'units','pixels', ...
     'position',[100 50 200 200], 'NextPlot', 'add');
x     = linspace(0, 4*pi, 400);
y     = sin(x);
LineH = plot(x,y);
TextH = uicontrol('style','text',...
    'position',[170 340 40 15]);
SliderH = uicontrol('style','slider','position',[100 280 200 20],...
    'min', 0, 'max', 4*pi);
addlistener(SliderH, 'Value', 'PostSet', @callbackfn);
movegui(FigH, 'center')
    function callbackfn(source, eventdata)
    num          = get(eventdata.AffectedObject, 'Value');
    LineH.YData  = sin(num * x);
    TextH.String = num2str(num);
    end
  end