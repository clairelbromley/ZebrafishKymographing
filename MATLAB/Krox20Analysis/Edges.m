classdef Edges
    
    properties
        z = 0;          % z plane in which edges are defined
        timepoint = 1;  % timepoint for which edges are defined
        
        L = [];         % left edge xy array
        R = [];         % right edge xy array
        M = [];         % midline xy array
        
        hlL = [];       % handle for line overlaying left edge
        hlR = [];       % handle for line overlaying right edge
        hlM = [];       % handle for line overlaying midline
        
    end
    
end