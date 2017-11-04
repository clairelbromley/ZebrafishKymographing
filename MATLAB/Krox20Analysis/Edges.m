classdef Edges
    
    properties
        z = 0;                                  % z plane in which edges are defined
        timepoint = 1;                          % timepoint for which edges are defined
        timestamp = 0;                          % time relative to start of timecourse in minutes
        
        L = [];                                 % left edge xy array
        R = [];                                 % right edge xy array
        M = [];                                 % midline xy array
        Rh4 = [];                               % rhombomere 4 edge xy array
        Rh6 = [];                               % rhombomere 6 edge xy array
        
        hlL = [];                               % handle for line overlaying left edge
        hlR = [];                               % handle for line overlaying right edge
        hlM = [];                               % handle for line overlaying midline
        hlRh4 = [];                             % handle for patch overlaying rhombomere 4
        hlRh6 = [];                             % handle for patch overlaying rhombomere 6
        
        tissueRotation = 0;                     % angle to rotate image by to bring midline vertical
        rhombomereLimits = [0 0 0 0];           % y positions at extrema of rotated rhombomeres
        edgeValidity = false(3, 3);             % (i,j) is true if ith edge (L,R,M) spans jth rhombomere
        
        midlineIndexOfStraightness = NaN;         % sinuosity index of midline
        midlineLength = NaN;
        midlineDefinition = [];
        basal_basal_distances = [];
        ap_lengths = [];
        
    end
    
end