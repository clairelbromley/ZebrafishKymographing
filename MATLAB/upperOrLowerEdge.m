function edgeSide = upperOrLowerEdge(paddedMembrane, kymograph)

% compare mean pixel values above and below the edge all the way along, and
% choose which edge by which has more brighter sides - this is better than
% comparing averages of all pixels above/below since it will deal better
% with anomalously high pixels. 

upperEdge = 0;
lowerEdge = 0;
isEdge = sum(paddedMembrane,1);

for j = 1:length(paddedMembrane)
    
    if isEdge(j) > 0
        
        col = paddedMembrane(:,j);
        edgeVertPos = find(col);
        
        upperAverage = mean(kymograph((max(1, edgeVertPos - 5)):edgeVertPos,j));
        lowerAverage = mean(kymograph(edgeVertPos:min(size(kymograph,1),edgeVertPos + 5),j));
        
        if upperAverage > lowerAverage
            lowerEdge = lowerEdge + 1;
        else
            upperEdge = upperEdge + 1;
        end
        
    end
    
end

if upperEdge > lowerEdge
    edgeSide = 'upper';
else
    edgeSide = 'lower';
end
