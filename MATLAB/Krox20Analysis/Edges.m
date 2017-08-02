classdef Edges
    
    properties
        z = 0;          % z plane in which edges are defined
        timepoint = 1;  % timepoint for which edges are defined
        
        L = [];         % left edge xy array
        R = [];         % right edge xy array
        M = [];         % midline xy array
        Rh4 = [];       % Mask defining rhombomere 4
        Rh6 = [];       % Masks defining rhombomere 6
        
        hlL = [];       % handle for line overlaying left edge
        hlR = [];       % handle for line overlaying right edge
        hlM = [];       % handle for line overlaying midline
        hlRh4 = [];     % handle for patch overlaying rhombomere 4
        hlRh6 = [];     % handle for patch overlaying rhombomere 6
        
    end
    
end