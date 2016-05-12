function cutMetadata = getOMECutMetadata(params)

    cutMetadata.startPositionX = params.cutStartX;
    cutMetadata.stopPositionX = params.cutEndX;
    cutMetadata.startPositionY = params.cutStartY;
    cutMetadata.stopPositionY = params.cutEndY;
    
    cutMetadata.time = 0; % dummy?
    
end