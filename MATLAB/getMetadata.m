function metadata = getMetadata(root_path, cut_number)

    metadata = [];
    
    %% Hardcode conversion from pixel to um and cut offsets
    metadata.umperpixel = 0.218;
    metadata.xoffset = 0;
    metadata.yoffset = 0;
    
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
    [~,dummy,~] = fileparts(root_path);             % only deal with _ in lowest level of path, leaving other parts of path free to contain whichever characters desired. 
    dummy = regexp(dummy, '\w*_\w*', 'match');
    idString = dummy{1};
    id = regexp(idString, '_E', 'split');
    metadata.embryoNumber = id{2};
    metadata.acquisitionDate = id{1};
    metadata.cutNumber = cut_number+1;
    
    %% Storage for kymograph positioning bits
    metadata.kym_region = [];
    metadata.isCropped = false;
    
end