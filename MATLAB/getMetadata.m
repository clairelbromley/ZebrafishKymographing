function metadata = getMetadata(root_path, cut_number)

    metadata = [];
    
    %% Hardcode conversion from pixel to um and cut offsets
    metadata.umperpixel = 0.218;
    metadata.xoffset = -20;
    metadata.yoffset = -20;
    
    %% Get metadata relating to cut
    cutMetadataPath = dir([root_path filesep '*_' num2str(cut_number) '.txt']);
    fstr = ['%d_' num2str(cut_number) '.txt'];
    metadata.cutFrame = sscanf(cutMetadataPath.name, fstr);
    metadata.cutMetadata = importCutMetadata([root_path filesep cutMetadataPath.name]);
    metadata.cutTheta = atan( ( metadata.cutMetadata.stopPositionY-metadata.cutMetadata.startPositionY )/( metadata.cutMetadata.stopPositionX-metadata.cutMetadata.startPositionX ) );
    
    %% Get metadata relating to acquisition parameters
    acquMetadataPath = [root_path filesep num2str(metadata.cutFrame) 'acqupara.txt'];
    metadata.acqMetadata = importAcqMetadata(acquMetadataPath, [3,9,14], [4,10,19]);
    
    %% Parse folder name to get embryo date and number
    dummy = regexp(root_path, '\w*_\w*', 'match');
    idString = dummy{1};
    id = sscanf(idString, '%d_E%d');
    metadata.embryoNumber = id(2);
    metadata.acquisitionDate = id(1);
    metadata.cutNumber = cut_number;
    
end