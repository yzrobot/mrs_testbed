Inspired by the RoboCup Rescue competition, We provide here four experimental terrains created with the same size but different topological structures:

![alt tag](https://github.com/yzrobot/mrs_testbed/blob/master/MORSE/scenarios.png)

* The `loop` terrain has a low obstacle density and a simple obstacle shape, in which there is no road fork (similar to beltway).
* The `cross` terrain contains five road forks but the obstacle density is still low (similar to crossroad).
* The `zigzag` terrain has no road fork but more obstacles, and it has a long solution path for the robot (similar to square-grid street).
* The `maze` terrain is the most complex which contains many obstacles and dead ends (similar to whole city).

## How to play? ##

* Two simulated Pioneer P3-DX robots within the `maze` environment: `./test.sh scenarios/maze.blend`

## How to build a map? ##

* A simulated PR2 robots within the `zigzag` environment: `./mapping.sh scenarios/zigzag.blend`
* Set Blender to active window, use the arrow keys on the keyboard to control the robot.
* Inspect RVIZ window, save the map when you satisfy: `$ rosrun map_server map_saver -f map`
