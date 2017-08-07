classdef Edges
    
    properties
        z = 0;                      % z plane in which edges are defined
        timepoint = 1;              % timepoint for which edges are defined
        
        L = [];                     % left edge xy array
        R = [];                     % right edge xy array
        M = [];                     % midline xy array
        Rh4 = [];                   % rhombomere 4 edge xy array
        Rh6 = [];                   % rhombomere 6 edge xy array
        
        hlL = [];                   % handle for line overlaying left edge
        hlR = [];                   % handle for line overlaying right edge
        hlM = [];                   % handle for line overlaying midline
        hlRh4 = [];                 % handle for patch overlaying rhombomere 4
        hlRh6 = [];                 % handle for patch overlaying rhombomere 6
        
        tissueRotation = 0;         % angle to rotate image by to bring midline vertical
        rhombomereLimits = [0 0];   % y positions at extrema of rotated rhombomeres
        
    end
    
end