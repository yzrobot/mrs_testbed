# Multi-robot Exploration Testbed #

This testbed includes:
- ROS packages for multi-robot exploration
- MORSE simulation scenarios
- Scripts for autonomous deployment of the infrastructure and experiments

To have a general idea, please refer to the videos below, respectively showing simulated and real robot exploration:

[![YouTube Video 1](https://img.youtube.com/vi/SrA_1ITJo7A/0.jpg)](https://www.youtube.com/watch?v=SrA_1ITJo7A)
[![YouTube Video 2](https://img.youtube.com/vi/xCW0WT_G5OA/0.jpg)](https://www.youtube.com/watch?v=xCW0WT_G5OA)

## Citation ##

If you are considering using these resources, please reference the following:
```
@article{yz17robotics,
  author = {Zhi Yan and Luc Fabresse and Jannik Laval and and Noury Bouraqadi},
  title = {Building a ROS-based Testbed for Realistic Multi-robot Simulation: Taking the Exploration as an Example},
  year = {2017},
  journal = {Robotics}
}
```

## Overview ##

![alt tag](https://github.com/yzrobot/mrs_testbed/blob/master/architecture.png)

The testbed is composed of four parts: a simulator, a monitor, a set of robot controllers, and the ROS middleware used to connect all of them. In particular, we use the MORSE 3D realistic simulator and wrap it up into a ROS node. The monitor is also performed as a ROS node, which allows us to supervise the experimental processes. Specifically, it can stop the experiment when the stop condition is triggered, collect measurement data and compute the metrics afterwards.
