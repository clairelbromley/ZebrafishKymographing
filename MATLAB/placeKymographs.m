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

% This now works by positioning one kymograph before start of cut, one
% after, one at either end, and spacing remaining kymographs equally in
% between such that the spacing between all kymographs is equal. 
kp.kym_startx = xcut(1) + (-1:uO.number_kym-2)*(xcut(2)-xcut(1))/(uO.number_kym-3);
kp.kym_starty = ycut(1) + (-1:uO.number_kym-2)*(ycut(2)-ycut(1))/(uO.number_kym-3);

kp.deltay = uO.kym_length * cos(md.cutTheta);
kp.deltax = -uO.kym_length * sin(md.cutTheta);
kp.kym_endx = kp.kym_startx + kp.deltax;
kp.kym_endy = kp.kym_starty + kp.deltay;

kp.boundingBox_LTRB = [floor(min([kp.kym_startx kp.kym_endx]) - uO.kym_width) ...
                        floor(min([kp.kym_starty kp.kym_endy]) - uO.kym_width) ...
                        ceil(max([kp.kym_startx kp.kym_endx]) + uO.kym_width) ...
                        ceil(max([kp.kym_starty kp.kym_endy]) + uO.kym_width)];


kym_positioning = kp;