function outImage = binning(image, yBin, xBin)

    outImage = image;
    % Check that size is divisible by binning - trim accordingly
    trimSize = mod(size(outImage),[xBin yBin]);
    xTrimVec = zeros(1,size(outImage,1));
    xTrimVec(end - trimSize(1) + 1 : end) = 1;
    outImage(logical(xTrimVec), :) = [];
    yTrimVec = zeros(1,size(outImage,2));
    yTrimVec(end - trimSize(2) + 1 : end) = 1;
    outImage(:, logical(yTrimVec)) = [];
    [m,n]=size(outImage); %outImage is the original matrix

    outImage=sum( reshape(outImage,xBin,[]) ,1 );
    outImage=reshape(outImage,m/xBin,[]).'; %Note transpose

    outImage=sum( reshape(outImage,yBin,[]) ,1);

    outImage=reshape(outImage,n/yBin,[]).'; %Note transpose

end