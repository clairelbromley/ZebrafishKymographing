function metadata = getMetadataFromOME(omeMeta, cziUIParams)

    metadata = [];
    
    %% Hardcode conversion from pixel to um and cut offsets
    metadata.umperpixel = double(omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM));
    metadata.xoffset = 0;
    metadata.yoffset = 0;
    
    %% Get metadata relating to cut
    metadata.cutFrame = 1;
    metadata.cutMetadata = getOMECutMetadata(cziUIParams); % make a function to generate cut metadata in right format
    metadata.cutTheta = atan( ( metadata.cutMetadata.stopPositionY-metadata.cutMetadata.startPositionY )/( metadata.cutMetadata.stopPositionX-metadata.cutMetadata.startPositionX ) );
    
    %% Get metadata relating to acquisition parameters
%     acquMetadataPath = [root_path filesep num2str(metadata.cutFrame) 'acqupara.txt'];
%     metadata.acqMetadata = importAcqMetadata(acquMetadataPath, [3,9,14], [4,10,19]);
    
    %%
    metadata.embryoNumber = num2str(cziUIParams.embryoNumber);
    metadata.acquisitionDate = cziUIParams.date;
    metadata.cutNumber = 1;
    
    %% Storage for kymograph positioning bits
    metadata.kym_region = [];
    metadata.isCropped = false;
    
end