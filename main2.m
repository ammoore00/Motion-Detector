%Detects pedestrians in the crosswalk and outputs a signal when one is
%detected
function main()
    global cam;
    global vid;
    
    %Variable to keep looping
    loop = 1;
    
    %Used for temporal average
    frameCount = 5;
    frames = java.util.LinkedList;
    frameGap = 3;
    curGap = frameGap - 1;
    
    %Maximum number of objects the camera can track
    maxHighlights = 5;
    
    %dispFig = figure('Units', 'Normalized', 'Outerposition', [0,0,1,1], 'ToolBar', 'none', 'MenuBar', 'none', 'Name', 'Display', 'NumberTitle', 'off');
    dispFig = figure('Units', 'Normalized', 'Outerposition', [1,0,1,1]);
    
    
%     if (strcmp(source, 'Live'))
%         %Obtains the camera over LAN
%         url = 'http://138.67.180.132:4747/mjpegfeed';
%         cam = ipcam(url);
%         
%         while(loop)
%             %Gets current frame and converts to grayscale
%             imgOrig = cast(snapshot(cam), 'uint16');
%             img = imresize(imgOrig, .33);
%             
%             procImg(img);
%         end
%     elseif (strcmp(source, 'File'))
%         [fileName,pathName] = uigetfile({'*.mp4'},'Select a file');
%         vid = VideoReader(strcat(pathName,fileName));
%         
%         while(hasFrame(vid))
%             %Gets current frame and converts to grayscale
%             imgOrig = cast(readFrame(vid), 'uint16');
%             img = imresize(imgOrig, .33);
%             
%             procImg(img);
%         end
%     else
%         'Invalid input argument'
%     end
    
    %Figure for display
    %menuFig = figure('Units', 'Normalized', 'Outerposition', [0,0,1,1], 'ToolBar', 'none', 'MenuBar', 'none', 'Name', 'Menu', 'NumberTitle', 'off', 'Visible', 'off');
    
    %uicontrol(menuFig, 'Style', 'pushbutton', 'String', 'Live Video', 'Units', 'Normalized', 'Position', [.2, .2, .2, .1], 'Callback', @getLive);
    %uicontrol(menuFig, 'Style', 'pushbutton', 'String', 'From File', 'Units', 'Normalized', 'Position', [.6, .2, .2, .1], 'Callback', @getFile);
    
    %menuFig.set('Visible', 'on');
    %figure(menuFig);
    
    
    %[fileName,pathName] = uigetfile({'*.mp4'},'Select a file');
    %vid = VideoReader(strcat(pathName,fileName));
    
    url = 'http://138.67.149.211:4747/mjpegfeed';
    cam = ipcam(url);
         
    while(hasFrame(vid))
        %Gets current frame and converts to grayscale
        %imgOrig = cast(readFrame(vid), 'uint16');
        imgOrig = cast(snapshot(cam), 'uint16');
        img = imresize(imgOrig, .33);
        img2 = cast(uint8(img), 'int16');
        
        %Populates linked list with frames, cycling frames out when the cap
        %is reached
        if (curGap == frameGap - 1)
            if (frames.size() < frameCount)
                frames.add(img2);
            else
                frames.remove();
                frames.add(img2);
            end
            
            curGap = 0;
        else
            curGap = curGap + 1;
        end
        
        %Finds the average of all frames in the linked list to find
        %background
        frameAvg = cast(frames.get(0), 'uint16');
        for i = 1:min((frameCount - 1), frames.size() - 1)
            oneFrame = cast(frames.get(i), 'uint16');
            frameAvg = frameAvg + oneFrame;
        end
        frameAvg = (frameAvg / frameCount);
        
        %Difference between current frame and calculated background
        imgFore = 6 * abs(frameAvg - cast(img2, 'uint16'));
        imgBW = im2bw(cast(imgFore, 'uint8'), .5);
        
        %Refines binary image
        imgBW2 = bwareaopen(imgBW, 100);
        SE = strel('disk', 20, 8);
        imgBW3 = imdilate(imgBW2, SE);
        SE2 = strel('disk', 10, 8);
        imgBW4 = imerode(imgBW3, SE2);
        
        %Displays images
        %subplot(2,2,1), imshow(cast(img, 'uint8')), title('Original');
        figure(dispFig);
        subplot(2,2,3), imshow(imgBW4), title('Blob Detection');
        subplot(2,1,1), imshow(cast(imgFore, 'uint8')), title('Background Subtracted');
        subplot(2,2,4), imshow(cast(img, 'uint8')), title('Original Image with Subjects Identified');
        hold on;
        %Draws a box around all suitable subjects
        L1 = bwlabel(imgBW4);
        imgBW5 = imgBW4;
        if (max(max(L1)) > 0)
            for i = 1:min(maxHighlights, max(max(L1)))
                imgBlob = ExtractNLargestBlobs(imgBW5, 1);
                L2 = bwlabel(imgBlob);
                blobprops = regionprops(L2,'BoundingBox');
                rectangle('Position', blobprops.BoundingBox, 'EdgeColor', 'g', 'LineWidth', 5);
                imgBW5 = imgBW5 - imgBlob;
            end
        end
    end
    
    function binaryImage = ExtractNLargestBlobs(binaryImage, numberToExtract)
        % Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
    	[labeledImage, numberOfBlobs] = bwlabel(binaryImage);
        blobMeasurements = regionprops(labeledImage, 'area');
    	% Get all the areas
        allAreas = [blobMeasurements.Area];
    	if numberToExtract > 0
        	% For positive numbers, sort in order of largest to smallest.
    		% Sort them.
            [sortedAreas, sortIndexes] = sort(allAreas, 'descend');
        elseif numberToExtract < 0
    		% For negative numbers, sort in order of smallest to largest.
            % Sort them.
        	[sortedAreas, sortIndexes] = sort(allAreas, 'ascend');
    		% Need to negate numberToExtract so we can use it in sortIndexes later.
            numberToExtract = -numberToExtract;
        else
            % numberToExtract = 0.  Shouldn't happen.  Return no blobs.
        	binaryImage = false(size(binaryImage));
    		return;
        end
    	% Extract the "numberToExtract" largest blob(a)s using ismember().
    	biggestBlob = ismember(labeledImage, sortIndexes(1:numberToExtract));
    	% Convert from integer labeled image into binary (logical) image.
    	binaryImage = biggestBlob > 0;
    end
end