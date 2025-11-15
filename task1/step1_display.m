% Matlab codes for reading an input text file image
% with 64X64 image data in character codes
% with 32 gray level values coded using 0-9 and A to V
% and produces a 64 X 64 matrix output of uint8 representing the image'

% open the file
fid = fopen("chromo.txt");

% read a char at a time, ignore linefeed and carriage return
% and put them in a 64 X 64 matrix

lf = char(10); % line feed character
cr = char(13); % carriage return character

A = fscanf(fid, [cr lf '%c'],[64,64]);

% close the file handler
fclose(fid);

A = A'; % transpose since fscanf returns column vectors

% convert letters A-V to their corresponding values in 32 gray levels
% literal A becomes number 10 and so on...
A(isletter(A)) = A(isletter(A)) - 55;

%convert number literals 0-9 to their corresponding values in 32 gray
%levels. Numeric literal '0' becomes number 0 and so on...
A(A>= '0' & A <= '9') = A(A>= '0' & A <= '9') - 48;

A = uint8(A);