function kym_positioning = placeKymographs(md, uO)
% kym_positioning takes the metadata relating to a particular cut and
% returns all the parameters that will allow proper placement of the
% kymograph lines on an image, and the coordinates that will allow images
% to be trimmed to make subsequent analysis faster. 

cm = md.cutMetadata;
xcut = [cm.startPositionX cm.stopPositionX] + md.xoffset;
ycut = [cm.startPositionY cm.stopPositionY] + md.yoffset;
kp.xcut = xcut;
kp.ycut = ycut;

if uO.fixedNumberOrFixedSpacing
    cut_length_um = sqrt((xcut(1) - xcut(2))^2 + (ycut(1) - ycut(2))^2) * md.umperpixel;
    num_kym = floor(cut_length_um/uO.kymSpacingUm) + 3;
    cut_centrex = xcut(1) + round((xcut(2) - xcut(1))/2);
    cut_centrey = ycut(1) + round((ycut(2) - ycut(1))/2);
    xspacing = cos(md.cutTheta) * uO.kymSpacingUm/md.umperpixel;
    yspacing = sin(md.cutTheta) * uO.kymSpacingUm/md.umperpixel;

    kp.kym_startx = fliplr(-(num_kym-1)/2:(num_kym-1)/2)*xspacing + cut_centrex;
    kp.kym_starty = fliplr(-(num_kym-1)/2:(num_kym-1)/2)*yspacing + cut_centrey;
        
else
    % This now works by positioning one kymograph before start of cut, one
    % after, one at either end, and spacing remaining kymographs equally in
    % between such that the spacing between all kymographs is equal. 
    kp.kym_startx = xcut(1) + (-1:uO.number_kym-2)*(xcut(2)-xcut(1))/(uO.number_kym-3);
    kp.kym_starty = ycut(1) + (-1:uO.number_kym-2)*(ycut(2)-ycut(1))/(uO.number_kym-3);
end

kp.kym_startx(kp.kym_startx < 1) = 1;
kp.kym_starty(kp.kym_starty < 1) = 1;

distanceOffset = sqrt((kp.kym_startx(1) - kp.xcut(1))^2 + (kp.kym_starty(1) - kp.ycut(1))^2)*md.umperpixel;
kp.pos_along_cut = (-((0:(length(kp.kym_startx)-1))*uO.kymSpacingUm - distanceOffset));

% try to account for weird negative numbers...
if sum(kp.pos_along_cut) < 0
    kp.pos_along_cut = -kp.pos_along_cut;
end

% probably a better way of doing this, but fixes issue...
kp.pos_along_cut = cut_length_um - kp.pos_along_cut;
kp.fraction_along_cut = kp.pos_along_cut/cut_length_um;
kp.distance_from_edge = min(abs(kp.pos_along_cut), abs(kp.pos_along_cut - cut_length_um));

if uO.kymDownOrUp
    kp.deltay = -uO.kym_length * cos(md.cutTheta);
    kp.deltax = uO.kym_length * sin(md.cutTheta);
else
    kp.deltay = uO.kym_length * cos(md.cutTheta);
    kp.deltax = -uO.kym_length * sin(md.cutTheta);
end

kp.kym_endx = kp.kym_startx + kp.deltax;
kp.kym_endy = kp.kym_starty + kp.deltay;

kp.kym_endx(kp.kym_endx < 1) = 1;
kp.kym_endy(kp.kym_endy < 1) = 1;

kp.boundingBox_LTRB = [floor(min([kp.kym_startx kp.kym_endx]) - uO.kym_width) ...
                        floor(min([kp.kym_starty kp.kym_endy]) - uO.kym_width) ...
                        ceil(max([kp.kym_startx kp.kym_endx]) + uO.kym_width) ...
                        ceil(max([kp.kym_starty kp.kym_endy]) + uO.kym_width)];

kp.boundingBox_LTRB(kp.boundingBox_LTRB < 1) = 1;

kp.cropped_xcut = xcut - kp.boundingBox_LTRB(1);
kp.cropped_ycut = ycut - kp.boundingBox_LTRB(2);
kp.cropped_kym_startx = kp.kym_startx - kp.boundingBox_LTRB(1);
kp.cropped_kym_endx = kp.kym_endx - kp.boundingBox_LTRB(1);
kp.cropped_kym_starty = kp.kym_starty - kp.boundingBox_LTRB(2);
kp.cropped_kym_endy = kp.kym_endy - kp.boundingBox_LTRB(2);


kym_positioning = kp;