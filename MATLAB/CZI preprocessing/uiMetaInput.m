function metaOut = uiMetaInput(filepath, reader)
    
    info = imfinfo(filepath);
    omeMeta = createMinimalOMEXMLMetadata(zeros(info(1).Height, info(1).Width, length(info), 'uint16'));
    globalMeta = reader.getGlobalMetadata;
    metaOut.globalMeta = globalMeta;
    metaOut.omeMeta = omeMeta;
    [~,filename,~] = fileparts(filepath);
    
    % define default values
    PixelsPhysicalSizeX = 0.218;
    PixelsSizeT = length(info);
    PixelsSizeZ = 1;
    PixelsSizeC = 1;
    PlaneDeltaT = 0.2;
    PixelsDimensionOrder = 'XYTZC';
    if ~isnan(str2double(filename(1:6)))
        CreationDate = filename(1:6);
    else
        CreationDate = datestr(now, 'ddmmyy');
    end
    
    % render ui
    hs = addcomponents();
    set(hs.fig, 'Visible', 'on');
    uiwait(hs.fig);
    
    function hs = addcomponents()
        
        hs.editsList = [];
        hs.textsList = [];
        
        hs.fig = figure('Visible','off',...
                     'Resize','off',...
                     'Tag','metadataFig', ...
                     'Units', 'normalized', ...
                     'Position', [0.05 0.05 0.5 0.8], ...
                     'MenuBar', 'none', ...
                     'Name', ['Enter metadata for data in ' filename], ...
                     'NumberTitle', 'off');
%                  , ...
%                      'CloseRequestFcn', @myCloseReqFcn);
        hs.okbtn = uicontrol(hs.fig,...
                        'Units', 'normalized', ...
                        'Position',[0.8 0.05 0.1 0.05],...
                        'String','OK',...
                        'Tag','OKButton',...
                        'Callback',@finish);
                    
        hs.PixelsPhysicalSizeX = uicontrol(hs.fig, ...
                            'Style', 'edit', ...
                            'String', num2str(PixelsPhysicalSizeX));
        hs.editsList = [hs.editsList; hs.PixelsPhysicalSizeX];
        hs.pixsizelabel = uicontrol(hs.fig, ...
                            'Style', 'text', ...
                            'String', 'Pixel size, um: ');
        hs.textsList = [hs.textsList; hs.pixsizelabel];
        
        hs.PixelsSizeT = uicontrol(hs.fig, ...
                            'Style', 'edit', ...
                            'String', num2str(PixelsSizeT));
        hs.editsList = [hs.editsList; hs.PixelsSizeT];
        hs.noTlabel = uicontrol(hs.fig, ...
                            'Style', 'text', ...
                            'String', 'Number of frames in timelapse: ');
        hs.textsList = [hs.textsList; hs.noTlabel];
        
        hs.PixelsSizeZ = uicontrol(hs.fig, ...
                            'Style', 'edit', ...
                            'String', num2str(PixelsSizeZ));
        hs.editsList = [hs.editsList; hs.PixelsSizeZ];
        hs.noZlabel = uicontrol(hs.fig, ...
                            'Style', 'text', ...
                            'String', 'Number of z planes: ');
        hs.textsList = [hs.textsList; hs.noZlabel];
        
        hs.PixelsSizeC = uicontrol(hs.fig, ...
                            'Style', 'edit', ...
                            'String', num2str(PixelsSizeC));
        hs.editsList = [hs.editsList; hs.PixelsSizeC];
        hs.noClabel = uicontrol(hs.fig, ...
                            'Style', 'text', ...
                            'String', 'Number of channels: ');
        hs.textsList = [hs.textsList; hs.noClabel];
        
        hs.PlaneDeltaT = uicontrol(hs.fig, ...
                            'Style', 'edit', ...
                            'String', num2str(PlaneDeltaT));
        hs.editsList = [hs.editsList; hs.PlaneDeltaT];
        hs.deltaTlabel = uicontrol(hs.fig, ...
                            'Style', 'text', ...
                            'String', 'Duration of each time step in timelapse, s: ');
        hs.textsList = [hs.textsList; hs.deltaTlabel];
        
        hs.PixelsDimensionOrder = uicontrol(hs.fig, ...
                            'Style', 'edit', ...
                            'String', (PixelsDimensionOrder));
        hs.editsList = [hs.editsList; hs.PixelsDimensionOrder];
        hs.xyzctlabel = uicontrol(hs.fig, ...
                            'Style', 'text', ...
                            'String', 'Order of dimsensions: ');
        hs.textsList = [hs.textsList; hs.xyzctlabel];
        
        hs.CreationDate = uicontrol(hs.fig, ...
                            'Style', 'edit', ...
                            'String', (CreationDate));
        hs.editsList = [hs.editsList; hs.CreationDate];
        hs.datelabel = uicontrol(hs.fig, ...
                            'Style', 'text', ...
                            'String', 'Data acquired (ddmmyy): ');
        hs.textsList = [hs.textsList; hs.datelabel];
                        
                        
              
        % distribute fields on window
        maxFieldY = 0.9;
        minFieldY = 0.1;
        yPoss = linspace(minFieldY, maxFieldY, length(hs.editsList));
        for yidx = 1:length(yPoss)
            set(hs.editsList(yidx), 'Units', 'normalized', ...
                    'Position', [0.4 yPoss(length(yPoss) - yidx + 1) 0.3 0.02]);
            set(hs.textsList(yidx), 'Units', 'normalized', ...
                    'Position', [0.1 yPoss(length(yPoss) - yidx + 1) 0.3 0.02], ...
                    'HorizontalAlignment', 'right');
        end
    end

    function finish(hObject,event)
%         try
            sz = ome.units.quantity.Length(java.lang.Double(str2double(get(hs.PixelsPhysicalSizeX, 'String'))), ...
                ome.units.UNITS.MICROM);
            omeMeta.setPixelsPhysicalSizeX(sz, 0);
            omeMeta.setPixelsSizeT(toInt(str2double(get(hs.PixelsSizeT, 'String'))),0);
            omeMeta.setPixelsSizeZ(toInt(str2double(get(hs.PixelsSizeZ, 'String'))),0);
            omeMeta.setPixelsSizeC(toInt(str2double(get(hs.PixelsSizeC, 'String'))),0);
            t0 = ome.units.quantity.Time(java.lang.Double(0), ome.units.UNITS.S);
            t1 = ome.units.quantity.Time(java.lang.Double(str2double(get(hs.PlaneDeltaT, 'String'))), ome.units.UNITS.S);
            omeMeta.setPlaneDeltaT(t0, 0, 0);
            omeMeta.setPlaneDeltaT(t1, 0, 1);
            dimensionOrderEnumHandler = javaObject('ome.xml.model.enums.handlers.DimensionOrderEnumHandler');
            dimensionOrder = dimensionOrderEnumHandler.getEnumeration(upper(get(hs.PixelsDimensionOrder, 'String')));
            omeMeta.setPixelsDimensionOrder(dimensionOrder, 0);

            dStr = get(hs.CreationDate, 'String');
            globalMeta.put('Information|Document|CreationDate #1', ['20' dStr(5:6) '-' dStr(3:4) '-' dStr(1:2) datestr(now, 'Thh:MM:ss')]);


            metaOut.omeMeta = omeMeta;
            metaOut.globalMeta = globalMeta;
%         catch ME
%             disp(ME);
%             msgbox('Error trying to assign manaul metadata!');
%         end
        
        delete(hs.fig);
    end

    function iout = toInt(x)
        iout = javaObject('ome.xml.model.primitives.PositiveInteger', ...
                        javaObject('java.lang.Integer', x));
    end

%     function myCloseReqFcn(hObject,event)
%         
%         print('closing');
%         
% %         t
%         delete(hs.fig);
%     end
    

end