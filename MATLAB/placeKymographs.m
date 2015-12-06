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

% N.B. this is not quite right!!! currently leads to only one kymograph
% before cut, and the number after depending on the multiplier...?
kp.kym_startx = xcut(1) + (-1:uO.number_kym-2)*uO.cut_size_multiplier*(xcut(2)-xcut(1))/uO.number_kym;
kp.kym_starty = ycut(1) + (-1:uO.number_kym-2)*uO.cut_size_multiplier*(ycut(2)-ycut(1))/uO.number_kym;

kp.deltay = uO.kym_length * cos(md.cutTheta);
kp.deltax = -uO.kym_length * sin(md.cutTheta);
kp.kym_endx = kp.kym_startx + kp.deltax;
kp.kym_endy = kp.kym_starty + kp.deltay;

kp.boundingBox_LTRB = [min([kp.kym_startx kp.kym_endx]) - uO.kym_width ...
                        min([kp.kym_starty kp.kym_endy]) - uO.kym_width ...
                        max([kp.kym_startx kp.kym_endx]) + uO.kym_width ...
                        max([kp.kym_starty kp.kym_endy]) + uO.kym_width];


kym_positioning = kp;