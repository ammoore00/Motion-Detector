import numpy as np

class Node:
    def __init__(self, frame: np.ndarray):
        self.nxt: Node = None
        self.data: np.ndarray = frame
    
    def getLength(self):
        if self.nxt != None:
            return self.nxt.getLength() + 1
        else:
            return 1
    
    def addToEnd(self, newNode):
        if self.nxt != None:
            self.nxt.addToEnd(newNode)
        else:
            self.nxt = newNode