
function varargout = Ca_Analysis_GUI(varargin)
%CA_ANALYSIS_GUI MATLAB code file for Ca_Analysis_GUI.fig
%      CA_ANALYSIS_GUI, by itself, creates a new CA_ANALYSIS_GUI or raises the existing
%      singleton*.
%
%      H = CA_ANALYSIS_GUI returns the handle to a new CA_ANALYSIS_GUI or the handle to
%      the existing singleton*.
%
%      CA_ANALYSIS_GUI('Property','Value',...) creates a new CA_ANALYSIS_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Ca_Analysis_GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CA_ANALYSIS_GUI('CALLBACK') and CA_ANALYSIS_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CA_ANALYSIS_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Ca_Analysis_GUI

% Last Modified by GUIDE v2.5 20-Feb-2019 12:16:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Ca_Analysis_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Ca_Analysis_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Ca_Analysis_GUI is made visible.
function Ca_Analysis_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for Ca_Analysis_GUI
handles.output = hObject;
% Adding folders and subfolders into working directory
addpath(genpath(pwd));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Ca_Analysis_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Ca_Analysis_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%close all figures excpet GUI figure
set(handles.output, 'HandleVisibility', 'off');
close all;
set(handles.output, 'HandleVisibility', 'on');

%gathering relevant inputs for caclium analysis function
directory = get(handles.path,'String');
method = get(handles.methodlist,'Value');

write = get(handles.write,'Value');
append = get(handles.append,'Value');
framerate = get(handles.fps,'String'); %Hz 
stim_val = get(handles.stim,'Value');
pos_units_val = get(handles.stim_pos_units,'Value');

if stim_val == 1
    if pos_units_val == 1
        stim_pos = get(handles.stim_pos,'Value');
    else
        stim_pos = get(handles.stim_pos,'Value')/framerate;
    end
else
    stim_pos = 0;
end

%Acquiring user inputted data on files being accessed
acq_date = get(handles.date,'String');
DIV_num = get(handles.DIV,'String');
t_num = get(handles.trial_num,'String');
GT = get(handles.GT,'String');
GT_val = get(handles.GT,'Value');
dish_num = get(handles.dish_num,'String');
mag_num = get(handles.mag,'String');
mag_val = get(handles.mag,'Value');
chamber = get(handles.chamber,'String');
chamber_val = get(handles.chamber,'Value');
bitdepth = get(handles.bitdepth,'String');
bitdepth_val = get(handles.bitdepth,'Value');
height = get(handles.threshold,'String');
prom = get(handles.edit16,'String');
user_data = [{acq_date},{DIV_num},{GT{GT_val}},{dish_num},{t_num},...
    {mag_num{mag_val}},{chamber{chamber_val}},{framerate},...
    {bitdepth{bitdepth_val}}, {height}, {prom}];

if method == 3
    % Retrieving transgenic genotype id from menu
    tgID = get(handles.tg_id,'String');
    tgID_val = get(handles.tg_id,'Value');
    TGidentifier = tgID{tgID_val};
    
    % Retrieving list of unique ids for selected column
    % 
    list_val = get(handles.column_list,'Value');
    list = get(handles.column_list,'String');
    itemofInterest =[];
    for i = 1:length(list_val)
        itemofInterest = [itemofInterest; string(list{list_val(i)})];
    end
    
    % Screen and bar graph boolean values
    screen = get(handles.chk_screen,'Value');
    bar = get(handles.chk_bar,'Value');
    
    % Mode not well-defined as user-input still fixed...
    % here dates are reformatted when mode '2' is specified.
    
    % mode '1' does not work for errorbar graph time course.
    mode = '2'; %will need to define as user-input
    if mode == '2'
     for i = 1:length(itemofInterest)
          itemofInterest(i) = dateFormat(itemofInterest(i));
     end
    end
    
    MultiBar_Visualization(directory,mode,itemofInterest, TGidentifier,screen,bar);
else % covers methods 1 and 2
    files = get(handles.filelist,'String');
    all = get(handles.check_all,'Value');
    if all == 1
        neurons = [1:length(files)];
    else
        neurons = str2num(get(handles.neurons,'String'));
        if length(neurons) > length(files)
            error('Selected neurons exceed number of files in folder');
        elseif isempty(neurons) 
            error('Files not selected for analysis');
        end    
    end
    Analyze_Calcium_Activity(directory,files,method,neurons,append,stim_pos,user_data,write);
end


% --- Executes on selection change in filelist.
function filelist_Callback(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filelist

% Finding value of highlighted selection in filelist and updating filepath
% following selected file.
strval = get(hObject,'Value');
files = get(hObject,'String');
sel_file = files{strval};
folder = pwd;
filepath = fullfile(folder,sel_file);
set(handles.path,'String',filepath);
% Reading in column names in order to populate column menu
col_num = 32;
fid = fopen(filepath);
col_names = textscan(fid,'%s',32,'delimiter',',');
fclose(fid);
set(handles.column_menu,'String',col_names{1});



% --- Executes during object creation, after setting all properties.
function filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in path.
function path_Callback(hObject, eventdata, handles)
% hObject    handle to path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = uigetdir;
set(hObject,'String',folder);
listing = dir(fullfile(folder,'*.csv'));
files = [{}];
for i=1:length(listing)
    files{end+1} = listing(i).name;
end
% files = natsortfiles(files);
set(handles.filelist,'String',files);

% --- Executes during object creation, after setting all properties.
function path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in methodlist.
function methodlist_Callback(hObject, eventdata, handles)
% hObject    handle to methodlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns methodlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from methodlist
strval = get(handles.methodlist,'Value');
strlist = get(handles.methodlist,'String');
method = strlist{strval};
switch method
    case 'Generate Plots'% Generate Plots
    % Disabled and invisible icons 
    set(handles.append,'Visible','off');
    set(handles.write,'Visible','off');
    set(handles.threshold,'Visible','off');
    set(handles.threshold_txt,'Visible','off');
    set(handles.stim,'Visible','off');
    set(handles.mag, 'Enable', 'off');
    set(handles.chamber,'Enable','off');
    set(handles.column_txt,'Visible','off');
    set(handles.column_menu,'Visible','off');
    set(handles.column_list,'Visible','off');
    set(handles.chk_screen,'Visible','off');
    set(handles.chk_bar,'Visible','off');
    set(handles.filelist,'Enable','inactive');
    set(handles.tg_txt,'Visible','off');
    set(handles.tg_id,'Visible','off'); 
    
    % Enabled and visible icons 
    set(handles.date,'Enable','on');
    set(handles.DIV, 'Enable', 'on');
    set(handles.GT,'Enable','on');
    set(handles.fps,'Enable','on');
    set(handles.bitdepth,'Enable','on');
    set(handles.path,'Enable','on');
    
    case 'Extract Peak Parameters' %Extract Peak Parameters
    % Disabled and invisible icons 
    set(handles.stim_pos,'Visible','off');
    set(handles.column_txt,'Visible','off');
    set(handles.column_menu,'Visible','off');
    set(handles.column_list,'Visible','off');
    set(handles.chk_screen,'Visible','off');
    set(handles.chk_bar,'Visible','off');
    set(handles.filelist,'Enable','inactive');
    set(handles.tg_txt,'Visible','off');
    set(handles.tg_id,'Visible','off'); 
    
    % Enabled and visible icons 
    set(handles.append,'Visible','on');
    set(handles.write,'Visible','on');
    set(handles.threshold,'Visible','on');
    set(handles.threshold_txt,'Visible','on');
    set(handles.stim,'Visible','on');
    set(handles.date,'Enable','on');
    set(handles.DIV, 'Enable', 'on');
    set(handles.GT, 'Enable', 'on');
    set(handles.trial_num,'Enable','on');
    set(handles.dish_num,'Enable','on');
    set(handles.mag, 'Enable', 'on');
    set(handles.chamber,'Enable','on');
    set(handles.fps,'Enable','on');
    set(handles.bitdepth,'Enable','on');
    set(handles.neurons,'Enable','on');
    set(handles.check_all,'Enable','on');
    set(handles.mag, 'Enable', 'on');
    set(handles.chamber,'Enable','on');
    set(handles.path,'Enable','on');
    set(handles.edit16,'Visible','on');
    set(handles.text21,'Visible','on');
    
    case 'Analyze Output'  %Analyze Output
    % Disabled and invisible icons 
    set(handles.append,'Visible','off');
    set(handles.write,'Visible','off');
    set(handles.threshold,'Visible','off');
    set(handles.threshold_txt,'Visible','off');
    set(handles.stim,'Visible','off');
    set(handles.stim_pos,'Visible','off');
    set(handles.date,'Enable','off');
    set(handles.DIV, 'Enable', 'off');
    set(handles.GT, 'Enable', 'off');
    set(handles.trial_num,'Enable','off');
    set(handles.dish_num,'Enable','off');
    set(handles.mag, 'Enable', 'off');
    set(handles.chamber,'Enable','off');
    set(handles.fps,'Enable','off');
    set(handles.bitdepth,'Enable','off');
    set(handles.neurons,'Enable','off');
    set(handles.check_all,'Enable','off');
    set(handles.path,'Enable','inactive');

    % Enabled and visible icons 
    set(handles.filelist,'Enable','on');
    set(handles.column_txt,'Visible','on');
    set(handles.column_menu,'Visible','on');
    set(handles.column_list,'Visible','on');
    set(handles.chk_screen,'Visible','on');
    set(handles.chk_bar,'Visible','on');   
    set(handles.tg_txt,'Visible','on');
    set(handles.tg_id,'Visible','on'); 
    
    % Populating column list with possible options
    folder = uigetdir;
    set(handles.path,'String',folder);
    listing = dir(fullfile(folder,'*Output.csv'));
    files = [{}];
    for i=1:length(listing)
        files{end+1} = listing(i).name;
    end
    set(handles.filelist,'String',files);
end


% --- Executes during object creation, after setting all properties.
function methodlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to methodlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Value',1);


function neurons_Callback(hObject, eventdata, handles)
% hObject    handle to neurons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of neurons as text
%        str2double(get(hObject,'String')) returns contents of neurons as a double


% --- Executes during object creation, after setting all properties.
function neurons_CreateFcn(hObject, eventdata, handles)
% hObject    handle to neurons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in append.
function stim_Callback(hObject, eventdata, handles)
% hObject    handle to append (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of append
state = get(handles.stim,'Value');
if state == 1
    set(handles.stim_pos,'Visible','on');
    set(handles.stim_pos_units,'Visible','on');
else
    set(handles.stim_pos,'Visible','off');
    set(handles.stim_pos_units,'Visible','off');
end

% --- Executes on button press in stim.
function append_Callback(hObject, eventdata, handles)
% hObject    handle to stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stim


% --- Executes on selection change in stim_pos_units.
function stim_pos_units_Callback(hObject, eventdata, handles)
% hObject    handle to stim_pos_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stim_pos_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stim_pos_units


% --- Executes during object creation, after setting all properties.
function stim_pos_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stim_pos_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Visible','off');

function stim_pos_Callback(hObject, eventdata, handles)
% hObject    handle to stim_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stim_pos as text
%        str2double(get(hObject,'String')) returns contents of stim_pos as a double

% --- Executes during object creation, after setting all properties.
function stim_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stim_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Visible','off');



function date_Callback(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of date as text
%        str2double(get(hObject,'String')) returns contents of date as a double


% --- Executes during object creation, after setting all properties.
function date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%set(hObject,'Enable','off');



function DIV_Callback(hObject, eventdata, handles)
% hObject    handle to DIV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DIV as text
%        str2double(get(hObject,'String')) returns contents of DIV as a double


% --- Executes during object creation, after setting all properties.
function DIV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DIV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Enable','off');


% --- Executes on selection change in GT.
function GT_Callback(hObject, eventdata, handles)
% hObject    handle to GT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GT contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GT


% --- Executes during object creation, after setting all properties.
function GT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%set(hObject,'Enable','off');



function trial_num_Callback(hObject, eventdata, handles)
% hObject    handle to trial_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trial_num as text
%        str2double(get(hObject,'String')) returns contents of trial_num as a double


% --- Executes during object creation, after setting all properties.
function trial_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%set(hObject,'Enable','off');

function dish_num_Callback(hObject, eventdata, handles)
% hObject    handle to dish_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dish_num as text
%        str2double(get(hObject,'String')) returns contents of dish_num as a double


% --- Executes during object creation, after setting all properties.
function dish_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dish_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%set(hObject,'Enable','off');



function mag_Callback(hObject, eventdata, handles)
% hObject    handle to mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mag as text
%        str2double(get(hObject,'String')) returns contents of mag as a double


% --- Executes during object creation, after setting all properties.
function mag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Enable','off');



function chamber_Callback(hObject, eventdata, handles)
% hObject    handle to chamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chamber as text
%        str2double(get(hObject,'String')) returns contents of chamber as a double


% --- Executes during object creation, after setting all properties.
function chamber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Enable','off');




function fps_Callback(hObject, eventdata, handles)
% hObject    handle to fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fps as text
%        str2double(get(hObject,'String')) returns contents of fps as a double


% --- Executes during object creation, after setting all properties.
function fps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_all.
function check_all_Callback(hObject, eventdata, handles)
% hObject    handle to check_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
state = get(handles.check_all,'Value');
files = get(handles.filelist,'String');
if state == 1
    set(handles.neurons,'Enable','off');
    last_element = length(files);
    elements = strcat("1:",string(last_element));
    set(handles.neurons,'String',elements);
else
    set(handles.neurons,'Enable','on');
end
    % Hint: get(hObject,'Value') returns toggle state of check_all



function bitdepth_Callback(hObject, eventdata, handles)
% hObject    handle to bitdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bitdepth as text
%        str2double(get(hObject,'String')) returns contents of bitdepth as a double


% --- Executes during object creation, after setting all properties.
function bitdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bitdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Value',5);


% --- Executes on selection change in column_menu.
function column_menu_Callback(hObject, eventdata, handles)
% hObject    handle to column_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns column_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from column_menu
strval = get(hObject,'Value');
filepath = get(handles.path,'String');
fid = fopen(filepath);
columns = 32; %number of entries per row in csv file
formatSpec = [];
for i=1:columns
    formatSpec = [formatSpec,'%s'];
end
out = textscan(fid,formatSpec,'delimiter',',');
fclose(fid);

sort_out = natsort(out{strval}(2:end));
sel_col = [];
for i=1:length(sort_out)
    sel_col = [ sel_col;string(sort_out{i})]; 
end
list = findUnique(sel_col);
set(handles.column_list,'String',list);
list_max = length(list);
set(handles.column_list,'Max',list_max);




% --- Executes during object creation, after setting all properties.
function column_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in column_list.
function column_list_Callback(hObject, eventdata, handles)
% hObject    handle to column_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns column_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        column_list


% --- Executes during object creation, after setting all properties.
function column_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_screen.
function chk_screen_Callback(hObject, eventdata, handles)
% hObject    handle to chk_screen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_screen


% --- Executes on button press in chk_bar.
function chk_bar_Callback(hObject, eventdata, handles)
% hObject    handle to chk_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_bar


% --- Executes on button press in write.
function write_Callback(hObject, eventdata, handles)
% hObject    handle to write (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of write



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over filelist.
function filelist_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in tg_id.
function tg_id_Callback(hObject, eventdata, handles)
% hObject    handle to tg_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tg_id contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tg_id


% --- Executes during object creation, after setting all properties.
function tg_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tg_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
