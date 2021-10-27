# Motion-Detector
This software was designed for my intro to engineering class in 2017.

The project assignment was to design a system to increase pedestrian safety, and we decided to design a traffic signal which would indicate the presence of pedestrians to protect pedestrians from cars turning in an intersection.

The software works by keeping a rolling temporal average of the background, and comparing the current frame to that average. This allows for changes over a long time scale, such as lighting or weather, to be ignored while detecting faster changes such as moving objects. The following images demonstrate the detection system of the program for a person walking and an RC car driving in front of the camera:

![](https://github.com/ammoore00/Motion-Detector/blob/matlab/Images/Pedestrian.PNG?raw=true)

![](https://github.com/ammoore00/Motion-Detector/blob/matlab/Images/RC_car.png?raw=true)

If something was detected, a signal would be sent over ethernet to a connected raspberry pi, whcih would then show an image, representing the traffic signal activating.

This project was later rewritten in python, which can be viewed under the python branch.
