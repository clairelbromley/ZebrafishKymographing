function metadata = getKymographMetadata(metadataFile)
%getMetadata gets the metadata associated with an image stack based on the
%contents of the file metadataFile. 

%% -------------------------------------------------------------------
% Parse metadata file
% -------------------------------------------------------------------%%

metadata.cutStart = 0;
metadata.cutDuration = 0;
metadata.cutStartX = 0;
metadata.cutStartY = 0;
metadata.cutEndX = 0;
metadata.cutEndY = 0;

metadata.frameDuration = 0;
metadata.pixelSize = 0;