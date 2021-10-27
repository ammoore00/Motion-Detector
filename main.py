import cv2
import Process

ip: str = "192.168.1.143"
#ip: str = ""

print("Starting video capture...")

cap = cv2.VideoCapture(0)

while(True):
    ret, frame = cap.read()
    cv2.imshow('frame',frame)

    Process.processImg(frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()