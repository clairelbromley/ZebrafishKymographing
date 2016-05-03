classdef UserOptions
    
    properties
         forcedSpeedRange = [-1.5 1.5];          % speed [min max]
         forcedPositionRange = [-5 20];      % position um [min max]

         fixedNumberOrFixedSpacing = true;   % false = fixed number of kym; true = fixed spacing between kym in um.                      Default = true;
         kymSpacingUm = 1;                   % Kymograph spacing in um.                                                                  Default = 1;
         number_kym = 10;                    % Number of kymographs calculated per cut.                                                  Default = 10
         kymDownOrUp = true;                % false = investigate movement below cut; true = investigate movement above cut.            Default = false;

         timeBeforeCut = 5;                  % Time in seconds before cut for kymograph to start.                                        Default = 5
         timeAfterCut = 10;                  % Time in seconds after cut for kymograph to end.                                           Default = 10

         kym_width = 5;                      % Width of region kymograph calculated over, pix. Must be odd.                              Default = 9
         kym_length = 50;                    % Length of region kymograph calculated over, pix.                                          Default = 50

         loadPreprocessedImages = false;
         scale_bar_length = 20;              % Length of scale bar in images, um.                                                        Default = 20
         outputFolder = 'C:\Users\Doug\Desktop\cross test';
         saveFirstFrameFigure = true;        % Save first figure?                                                                        Default = true
         firstFigureTitleAppend = '' ;       % Text to append to the title of the first figure.                                          Default = ''
         saveCutPositioningFigs = true;     % Toggle saving of helper images for checking cut positioning.                              Default = false
         removeCutFrames = true;             % Toggle removal of frames with scattered light.                                            Default = true
         figHandle = figure;                 % Allow figures to be rendered in a single window. 
         savePreprocessed = true;            % Save stack of images following preprocessing with cut position information.               Default = true
         avgOrMax = 1;                       % Choose between averaging (1) or taking max over (2) the kym_width per kym.                Default = 1
         medianFiltKernelSize = 50;           % Size of median filter kernel in pixels - reduce for increased speed...                   Default = 50
         preProcess = true;                  % Toggle pre-processing on or off                                                           Default = true
         showKymographOverlapOverlay = true;

         basalMembraneKym = false;
         usePreviouslySavedBasalPos = false;
         manualOrAutoApicalSurfaceFinder = 'manual';     % Find apical surface automatically by intensity or manually - 'auto' or 'manual'   Default = 'manual'
         usePreviouslySavedApicalSurfacePos = false;
         flip90DegForShortCuts = false;      % Rotate "cut axis" 90 degrees

         nonBeepSound = load('train');


    end
    
end