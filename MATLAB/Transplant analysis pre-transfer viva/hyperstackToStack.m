%% Get information on dimensions of hyperstack.
basepath = 'C:\Users\Doug\Google Drive\Transplant analysis take3\New Folder';
filename = 'Ncad_Series041_justNcad.tif';
outfolder = 'C:\Users\Doug\Google Drive\Transplant analysis take3\New Folder\stacks';

filepath = [basepath filesep filename];

info = imfinfo(filepath);
desc = regexp(info(1).ImageDescription, '\n', 'split');
zfield  = regexp(desc(find(~cellfun('isempty', strfind(desc, 'slices')))), '=', 'split');
zplanes = str2double(zfield{1}{2});
tfield  = regexp(desc(find(~cellfun('isempty', strfind(desc, 'frames')))), '=', 'split');
tplanes = str2double(tfield{1}{2});

totPlanes = length(info);

%% Read images in from hyperstack
data = zeros(info(1).Width, info(1).Height, totPlanes);
for plane = 1:totPlanes
    data(:,:,plane) = imread(filepath, plane);
end

%% Write data out in stacks
for tInd = 1:tplanes
    
    outfilename = ['F ' num2str(tInd) ' ' filename];
    subdata = data(:,:, ((tInd-1)*zplanes+1):zplanes*tInd);
    
    %% Show z planes as we generate images...
%     figure;
%     for zInd = 1:zplanes
%         subplot(3,4,zInd);
%         imagesc(squeeze(subdata(:,:,zInd)));
%         colormap gray;
%         axis equal tight;
%         set(gca, 'XTick', []);
%         set(gca, 'YTick', []);
%         set(gcf, 'Name', ['F' num2str(tInd) ', ' filename]);
%     end
    
    
    %% Write multipage tiffs
    for zInd = 1:zplanes 
        if zInd == 1
            imwrite(uint16(squeeze(subdata(:,:,1))), [outfolder filesep outfilename]);
        else
            imwrite(uint16(squeeze(subdata(:,:,zInd))), [outfolder filesep outfilename], 'writemode', 'append');
        end
    end
end
