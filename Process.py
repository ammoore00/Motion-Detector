import cv2
import numpy as np
import imutils
from skimage.metrics import structural_similarity
from skimage.util.dtype import img_as_ubyte

from Node import Node
from skimage.morphology.max_tree import area_closing

numFramesForBG: int = 10
frameSpacingForBG: int = 1
frameSpacingForProcess: int = 1

frameCount: int = 0
frameBGCount: int = 0

listBGHead: Node = None
avgBG: np.ndarray = None

#Maintains the linked list of frames to compute the background
############
#DEPRECATED#
############
def addToBGList(frame: np.ndarray):
    global listBGHead
    
    if listBGHead == None:
        listBGHead = Node(frame)
    else:
        listBGHead.addToEnd(newNode = Node(frame))
    
    if listBGHead.getLength() > numFramesForBG:
        listBGHead = listBGHead.nxt

#Uses the linked list to compute the temporal average for the background
############
#DEPRECATED#
############
def computeBGAvg():
    global listBGHead
    global avgBG
    global numFramesForBG
    
    if listBGHead == None:
        return
    
    nextFrameNode: Node = listBGHead
    #avgBG = cv2.cvtColor(nextFrameNode.data, cv2.COLOR_BGR2GRAY)
    if avgBG is not None:
        avgBG.astype(np.uint16)
    
    for i in range(0, listBGHead.getLength()):
        if avgBG is not None:
            avgBG += nextFrameNode.data
        else:
            avgBG = nextFrameNode.data
        
    if avgBG is not None:
        #normalize(avgBG)
        avgBG.astype(np.uint8)
        
#Uses cv2 built in function for rolling temporal average
def backgroundAccumulate(frame: np.ndarray):
    cv2.accumulateWeighted(frame, avgBG, 0.1)
    
#Checks the difference between the background and the current frame
def checkBGDiff(frame):
    #Converts images to black and white and aligns file formats
    frameBW = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    avgBGNorm = avgBG.copy()
    cv2.normalize(avgBG, avgBGNorm, 0, .99999, cv2.NORM_MINMAX)
    avgBGNorm = img_as_ubyte(avgBGNorm)
    avgBGBW = cv2.cvtColor(avgBGNorm, cv2.COLOR_BGR2GRAY)
    
    #frameBWBlur = cv2.GaussianBlur(frameBW, (15, 15), 2)
    
    #Difference between background and current frame
    (score, diff) = structural_similarity(frameBW, avgBGBW, full=True)
    diff = (diff * 255).astype("uint8")
    #print("SSIM: {}".format(score))
    
    cv2.imshow("Diff", diff)
    
    #Processes grayscale difference image into binary image of what is moving
    thresh = cv2.threshold(diff, 127, 255, cv2.THRESH_BINARY_INV)[1]
    kernel = np.ones((20,20), np.uint8)
    threshDilate = cv2.dilate(thresh, kernel, iterations=1)
    threshErode = cv2.erode(threshDilate, kernel, iterations=2)
    threshOpen = cv2.dilate(threshErode, kernel, iterations=2)
    
    contours = cv2.findContours(threshOpen.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contours = imutils.grab_contours(contours)
    
    #Finds the largest contour and computes the bounding box
    maxArea: int = 0
    (x, y, w, h) = (0, 0, 0, 0)
    
    for c in contours:
        area = cv2.contourArea(c)
        
        if area > maxArea:
            maxArea = area
            (x, y, w, h) = cv2.boundingRect(c)
    
    cv2.imshow("Thresholded", threshOpen)
    
    #center = calcCenter(threshOpen)
    
    output = frame.copy()
    #Done so that the image would not freeze if nothing was moving
    cv2.imshow('diff', output)
    
    #Displays the bounding box of the contour
    if len(contours) != 0:
        cv2.rectangle(output, (x, y), (x + w, y + h), (0, 0, 255), 2)
        
        cv2.imshow('diff', output)

#Main image processing 
def processImg(frame: np.ndarray):
    global frameSpacingForBG
    global frameSpacingForProcess
    global frameCount
    global frameBGCount
    global avgBG
    
    if frameCount < frameSpacingForProcess:
        frameCount += 1
        return
    else:
        frameCount = 0
    
    if frameBGCount < frameSpacingForBG:
        frameBGCount += 1
    else:
        frameBGCount = 0
        if avgBG is None:
            avgBG = np.zeros(frame.shape)
        backgroundAccumulate(frame)
        #addToBGList(frame)
        #computeBGAvg()
        checkBGDiff(frame)