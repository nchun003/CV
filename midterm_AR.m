close all
clear all

% the image we will embed
Im_embed = im2double(imread('landscape_small.jpg'));

% load the results -- THESE SHOULD ONLY BE USED AS REFERENCE, NOT AS PART
% OF YOUR SOLUTION
load AR_intermediate_results 


% initialize the video file (note: you may need to use a different encoding
% option if you are using a different OS. This code works with Windows 7, and 
% should hopefully work with other OS's as well).
vid = VideoWriter('video_result.avi','Motion JPEG AVI');
open(vid)

for frame = 1:350
    frame
    
    % open the image
    try
        Im_orig = im2double(imread(['images/video ',num2str(frame,'%03d'),'.jpg']));
    catch
        continue
    end
    
    %%% YOUR CODE HERE 
    hsv = rgb2hsv(Im_orig);
    newimg = zeros(480,640);
    for i=1:size(Im_orig,1)
        for j=1:size(Im_orig,2)
            if round((hsv(i,j,1))*360) > 290 && Im_orig(i,j,1) >.70 && Im_orig(i,j,1) <.89
                newimg(i,j) = 1;
            else
                newimg(i,j) = 0;
            end
        end
    end
    figure(1)
    imshow(newimg);
    %Part b Canny edge detection
    figure(2)
    [edgeimage, chainlist] = my_canny(newimg,.5,0.5,(0.5/3));
    imshow(edgeimage);
    % find coordinates of canny edges
    edgepoints = [];
    edgepointsx = [];
    edgepointsy = [];
    [edgepointsx, edgepointsy] = find(edgeimage == 1);
    edgepoints(:,1) = edgepointsx;
    edgepoints(:,2) = edgepointsy;
    m1 = 0;
    m2 = 0;
    m3 = 0;
    m4 = 0;
    b1 = 0;
    b2 = 0;
    b3 = 0;
    b4 = 0;
    x1 = 0; x2 = 0; x3 = 0; x4 = 0; x5 = 0; x6 = 0;
    y1 = 0; y2 = 0; y3 = 0; y4 = 0; y5 = 0; y6 = 0;
    [m1,b1,P1] = Randsac3(edgepoints);
    [m2,b2,P2] = Randsac3(P1);
    [m3,b3,P3] = Randsac3(P2);
    [m4,b4,P4] = Randsac3(P3);
    intersectinglines = 0;
    cornercoord = [];
    if m1 == 0
        m1 = 0.01;
    end
    if m2 == 0
        m2 = 0.01;
    end
    if m3 == 0
        m3 = 0.01;
    end
    if m4 == 0
        m4 = 0.01;
    end
        x1 = (b2-b1)/(m1-m2);
        y1 = m1*x1 + b1;
        if x1 >=0 && y1 >=0
            cornercoord = [cornercoord; x1 y1];
            intersectinglines = intersectinglines+1;
        end
        x2 = (b3-b1)/(m1-m3);
        y2 = m1*x2 + b1;
        if x2 >=0 && y2 >=0
            cornercoord = [cornercoord; x2 y2];
            intersectinglines = intersectinglines+1;
        end
        x3 = (b4-b1)/(m1-m4);
        y3 = m1*x3 + b1;
        if x3 >=0 && y3 >=0
            cornercoord = [cornercoord; x3 y3];
            intersectinglines = intersectinglines+1;
        end
        x4 = (b3-b2)/(m2-m3);
        y4 = m2*x4 + b2;
       if x4 >=0 && y4 >=0
            cornercoord = [cornercoord; x4 y4];
            intersectinglines = intersectinglines+1;
       end
        x5 = (b4-b2)/(m2-m4);
        y5 = m2*x5 + b2;
        if x5 >=0 && y5 >=0
            cornercoord = [cornercoord; x5 y5];
            intersectinglines = intersectinglines+1;
        end
        x6 = (b4-b3)/(m3-m4);
        y6 = m3*x6 + b3;
        if x6 >=0 && y6 >=0
            cornercoord = [cornercoord; x6 y6];
            intersectinglines = intersectinglines+1;
        end
    figure(3)
    x=1:640;
    Y = m1*x + b1;
    Y2 = m2*x + b2;
    Y3 = m3*x + b3;
    Y4 = m4*x + b4;
    plot(x,Y,x,Y2,x,Y3,x,Y4);
%     plot(cornercoord(:,1),cornercoord(:,2),'o');
    cornercoord = sortrows(cornercoord);
        top_left = cornercoord(1,:);
        bottom_left = cornercoord(2,:);
        top_right = cornercoord(3,:);
        bottom_right = cornercoord(4,:);
%     imshow(newimg)
    %% Your task is to write code that will compute this transformation
%     transform = results(frame).transform;
    cornerFeatures = [top_left; top_right; bottom_left; bottom_right];
    cornerEmbed = [[0,0];[0,500];[375,0];[375,500]];
    transform = estimate_homography(cornerEmbed,cornerFeatures);
    % get the new image that has the embedded photo in it
    Imnew = create_new_image_AR(Im_orig, Im_embed, transform);
    
    figure(3)
%     imshow(Im_orig);
    imshow(Imnew)
    pause(0.01)
    
    % add the new frame to the video
    writeVideo(vid,Imnew)
end
 
% close the video file
close(vid)
             
 