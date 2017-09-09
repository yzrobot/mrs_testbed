# One simulated PR2 robots

# Copyright (C) 2014 Zhi Yan

from morse.builder import *

##################### MAPPING ROBOT ####################
pr2 = BasePR2()
pr2.add_default_interface('ros')
pr2.translate(x=-36.0, y=36.0, z=0.0)

odometry = Odometry()
odometry.add_interface('ros')
pr2.append(odometry)

scan = Sick()
scan.translate(x=0.275, z=0.252)
scan.properties(Visible_arc=True)
scan.properties(laser_range=30.0)
scan.properties(resolution=1.0)
scan.properties(scan_window=180.0)
scan.add_interface('ros')
pr2.append(scan)

keyboard = Keyboard()
keyboard.properties(Speed=1.0)
pr2.append(keyboard)

##################### SCENARIO ####################
env = Environment('blender_file', fastmode=False)
env.place_camera([0, 0, 60])
env.aim_camera([0, 0, 0])
