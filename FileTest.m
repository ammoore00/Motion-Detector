function FileTest()
    [fileName,pathName] = uigetfile({'*.mp4'},'Select a file');
    vid = VideoReader(strcat(pathName,fileName));
    
    while(hasFrame(vid))
        imshow(imresize(readFrame(vid), .5));
    end
end