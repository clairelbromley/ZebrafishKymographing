function output = busy_dlg(varargin)
% 
% %% get handle to the main window...
% temp = get(0, 'Children');
% names = get(temp(:), 'Name');
% h = (temp(strcmp(names, 'viewerMain')));
% handles = guidata(h);

if nargin == 0
    %% start busy      
    try
        % R2010a and newer
        iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
        iconsSizeEnums = javaMethod('values',iconsClassName);
        SIZE_32x32 = iconsSizeEnums(2);  % (1) = 16x16,  (2) = 32x32
        jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32, 'Working...');  % icon, label
    catch
        % R2009b and earlier
        redColor   = java.awt.Color(1,0,0);
        blackColor = java.awt.Color(0,0,0);
        jObj = com.mathworks.widgets.BusyAffordance(redColor, blackColor);
    end
    jObj.setPaintsWhenStopped(true);  % default = false
    jObj.useWhiteDots(false);         % default = false (true is good for dark backgrounds)

    prev_units = get(gcf, 'Units');
    set(gcf, 'Units', 'pixels');
    sz = (get(gcf, 'Position'));
    width = sz(3)/10;
    height = sz(4)/10;
    xpos = sz(3)/2 - width/2;
    ypos = sz(4)/2 - height/2;

    [hBusyObj, hBusyContainer] = javacomponent(jObj.getComponent, [xpos,ypos,width,height], gcf);
    jObj.start;
    set(gcf, 'Units', prev_units);

    output.hBusyContainer = hBusyContainer;
    output.jObj = jObj;
    
elseif nargin == 1
    jObj = varargin{1}.jObj;
    hBusyContainer = varargin{1}.hBusyContainer;
    
    %% end busy
    jObj.stop;
    jObj.setBusyText('All done! :)');

    drawnow;
    jObj.getComponent.setVisible(false)
    delete(hBusyContainer);

end


