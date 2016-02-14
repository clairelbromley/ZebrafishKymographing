%% since we are forced to deal in pixels and since the kymograph axes are 
%  unlikely to be parallel to the pixel edges, we may introduce some error 
%  in the estimation of the physical length of the kymograph, and hence of
%  the speed with which bright pixels move across the kymograph because the
%  x and y, the projections of the kymograph along the image axes, must be whole
%  numbers (of pixels). 
%  Here, l is the length of the kymograph in pixels
%   deltal is the difference between the nominal length l and the actual
%   length matlab must use because of pixelation. (NOTE THAT INTERPOLATION
%   DOESN'T FIX THIS SINCE WE MUST SET THE START AND END POINTS OF THE 
%   KYMOGRAPH IN PIXEL COORDINATES)
%   deltaL is the difference between the actual and nominal lengths of 
%   kymographs in micrometers
%   deltaV is the difference between the nominal and actual calculated 
%   speed in um/s

um_per_pixel = 0.218;
seconds_per_frame = 0.2;

l = 50;
theta = 0:0.05:90;
x = l * cosd(theta);
y = l * sind(theta);

x = round(x);
y = round(y);

deltal = l - sqrt(x.^2 + y.^2);

figure;
subplot(2,1,1);
plot(theta, deltal);
xlabel('Angle between pixel side and kymograph line, \theta, ^{\circ}');
ylabel('Systematic error in kymograph length, pixels');
subplot(2,1,2);
plot(theta, deltal*um_per_pixel/(seconds_per_frame*l));
xlabel('Angle between pixel side and kymograph line, \theta, ^{\circ}');
ylabel('Systematic error in kymograph speed determination, \mu s^{-1}')

max(deltal)