# Two simulated Pioneer-3DX robots

# Copyright (C) 2014 Zhi Yan

from morse.builder import *

##################### ROBOT 0 ####################

p3dx0 = Pioneer3DX()
p3dx0.add_default_interface('ros')
p3dx0.translate(x=-36.0, y=36.0, z=0.0)

odom = Odometry()
odom.add_interface('ros', frame_id='/p3dx0_tf/odom', child_frame_id='/p3dx0_tf/base_footprint')
p3dx0.append(odom)

sick = Sick()
sick.translate(z=0.252)
sick.properties(Visible_arc=True)
sick.add_interface('ros', frame_id='/p3dx0_tf/base_laser_link')
p3dx0.append(sick)

motion = MotionVWDiff()
motion.add_interface('ros')
p3dx0.append(motion)

##################### ROBOT  1 ####################

p3dx1 = Pioneer3DX()
p3dx1.add_default_interface('ros')
p3dx1.translate(x=-36.0, y=32.0, z=0.0)

odom = Odometry()
odom.add_interface('ros', frame_id='/p3dx1_tf/odom', child_frame_id='/p3dx1_tf/base_footprint')
p3dx1.append(odom)

sick = Sick()
sick.translate(z=0.252)
sick.properties(Visible_arc=True)
sick.add_interface('ros', frame_id='/p3dx1_tf/base_laser_link')
p3dx1.append(sick)

motion = MotionVWDiff()
motion.add_interface('ros')
p3dx1.append(motion)

##################### ENVIRONMENT ####################

env = Environment('blender_file', fastmode=False)
env.place_camera([0, 0, 60])
env.aim_camera([0, 0, 0])
