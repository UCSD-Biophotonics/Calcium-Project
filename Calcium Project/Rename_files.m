  
cd 'Z:\Veronica\SALSA 09272019\FOV 5 Cut at 9, 53, 158, 229\data\Peng IMD from RatioF (renamed)\' 
photopath = 'Z:\Veronica\SALSA 09272019\FOV 5 Cut at 9, 53, 158, 229\GFP\'; %path of images which have time stamps on filenames
fileNames = getFiles(photopath); %Extract filenames
times = extractBetween(fileNames,"GFP_","_ms"); %Extract time stamp from filenames
for i = 1:9
    time = times(i,1);
    
    movefile("RatioA000" + num2str(i) + ".TIF", "Ratio" + nu
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    m2str(i) + " - " + time + ".TIF");
end

for i = 10:99 
    time = times(i,1);
    
    movefile("RatioA00" + num2str(i) + ".TIF", "Ratio" + num2str(i) + " - " + time + ".TIF");
end

for i = 100: 277
    time = times(i,1);
    
    movefile("RatioA0" + num2str(i) + ".TIF", "Ratio" + num2str(i) + " - " + time + ".TIF");
end