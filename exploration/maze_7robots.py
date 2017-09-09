from morse.builder import *

##################### ROBOT  0 ####################
p3dx0 = Pioneer3DX()
p3dx0.add_default_interface('ros')
p3dx0.translate(x=-38.0, y=38.0, z=0.0)

odom0 = Odometry()
odom0.add_interface('ros', frame_id='/p3dx0_tf/odom', child_frame_id='/p3dx0_tf/base_footprint')
odom0.alter('Noise', pos_std=0.022, rot_std=0.02)
odom0.frequency(10)
p3dx0.append(odom0)

sick0 = Sick()
sick0.translate(z=0.252)
sick0.properties(Visible_arc=True)
sick0.properties(scan_window = 190)
sick0.properties(laser_range = 26.0)
sick0.add_interface('ros', frame_id='/p3dx0_tf/base_laser_link')
sick0.frequency(25)
p3dx0.append(sick0)

motion0 = MotionVWDiff()
motion0.add_interface('ros')
p3dx0.append(motion0)

##################### ROBOT  1 ####################
p3dx1 = Pioneer3DX()
p3dx1.add_default_interface('ros')
p3dx1.translate(x=-38.0, y=36.0, z=0.0)

odom1 = Odometry()
odom1.add_interface('ros', frame_id='/p3dx1_tf/odom', child_frame_id='/p3dx1_tf/base_footprint')
odom1.alter('Noise', pos_std=0.022, rot_std=0.02)
odom1.frequency(10)
p3dx1.append(odom1)

sick1 = Sick()
sick1.translate(z=0.252)
sick1.properties(Visible_arc=True)
sick1.properties(scan_window = 190)
sick1.properties(laser_range = 26.0)
sick1.add_interface('ros', frame_id='/p3dx1_tf/base_laser_link')
sick1.frequency(25)
p3dx1.append(sick1)

motion1 = MotionVWDiff()
motion1.add_interface('ros')
p3dx1.append(motion1)

##################### ROBOT  2 ####################
p3dx2 = Pioneer3DX()
p3dx2.add_default_interface('ros')
p3dx2.translate(x=-38.0, y=34.0, z=0.0)

odom2 = Odometry()
odom2.add_interface('ros', frame_id='/p3dx2_tf/odom', child_frame_id='/p3dx2_tf/base_footprint')
odom2.alter('Noise', pos_std=0.022, rot_std=0.02)
odom2.frequency(10)
p3dx2.append(odom2)

sick2 = Sick()
sick2.translate(z=0.252)
sick2.properties(Visible_arc=True)
sick2.properties(scan_window = 190)
sick2.properties(laser_range = 26.0)
sick2.add_interface('ros', frame_id='/p3dx2_tf/base_laser_link')
sick2.frequency(25)
p3dx2.append(sick2)

motion2 = MotionVWDiff()
motion2.add_interface('ros')
p3dx2.append(motion2)

##################### ROBOT  3 ####################
p3dx3 = Pioneer3DX()
p3dx3.add_default_interface('ros')
p3dx3.translate(x=-38.0, y=32.0, z=0.0)

odom3 = Odometry()
odom3.add_interface('ros', frame_id='/p3dx3_tf/odom', child_frame_id='/p3dx3_tf/base_footprint')
odom3.alter('Noise', pos_std=0.022, rot_std=0.02)
odom3.frequency(10)
p3dx3.append(odom3)

sick3 = Sick()
sick3.translate(z=0.252)
sick3.properties(Visible_arc=True)
sick3.properties(scan_window = 190)
sick3.properties(laser_range = 26.0)
sick3.add_interface('ros', frame_id='/p3dx3_tf/base_laser_link')
sick3.frequency(25)
p3dx3.append(sick3)

motion3 = MotionVWDiff()
motion3.add_interface('ros')
p3dx3.append(motion3)

##################### ROBOT  4 ####################
p3dx4 = Pioneer3DX()
p3dx4.add_default_interface('ros')
p3dx4.translate(x=-38.0, y=30.0, z=0.0)

odom4 = Odometry()
odom4.add_interface('ros', frame_id='/p3dx4_tf/odom', child_frame_id='/p3dx4_tf/base_footprint')
odom4.alter('Noise', pos_std=0.022, rot_std=0.02)
odom4.frequency(10)
p3dx4.append(odom4)

sick4 = Sick()
sick4.translate(z=0.252)
sick4.properties(Visible_arc=True)
sick4.properties(scan_window = 190)
sick4.properties(laser_range = 26.0)
sick4.add_interface('ros', frame_id='/p3dx4_tf/base_laser_link')
sick4.frequency(25)
p3dx4.append(sick4)

motion4 = MotionVWDiff()
motion4.add_interface('ros')
p3dx4.append(motion4)

##################### ROBOT  5 ####################
p3dx5 = Pioneer3DX()
p3dx5.add_default_interface('ros')
p3dx5.translate(x=-38.0, y=28.0, z=0.0)

odom5 = Odometry()
odom5.add_interface('ros', frame_id='/p3dx5_tf/odom', child_frame_id='/p3dx5_tf/base_footprint')
odom5.alter('Noise', pos_std=0.022, rot_std=0.02)
odom5.frequency(10)
p3dx5.append(odom5)

sick5 = Sick()
sick5.translate(z=0.252)
sick5.properties(Visible_arc=True)
sick5.properties(scan_window = 190)
sick5.properties(laser_range = 26.0)
sick5.add_interface('ros', frame_id='/p3dx5_tf/base_laser_link')
sick5.frequency(25)
p3dx5.append(sick5)

motion5 = MotionVWDiff()
motion5.add_interface('ros')
p3dx5.append(motion5)

##################### ROBOT  6 ####################
p3dx6 = Pioneer3DX()
p3dx6.add_default_interface('ros')
p3dx6.translate(x=-38.0, y=26.0, z=0.0)

odom6 = Odometry()
odom6.add_interface('ros', frame_id='/p3dx6_tf/odom', child_frame_id='/p3dx6_tf/base_footprint')
odom6.alter('Noise', pos_std=0.022, rot_std=0.02)
odom6.frequency(10)
p3dx6.append(odom6)

sick6 = Sick()
sick6.translate(z=0.252)
sick6.properties(Visible_arc=True)
sick6.properties(scan_window = 190)
sick6.properties(laser_range = 26.0)
sick6.add_interface('ros', frame_id='/p3dx6_tf/base_laser_link')
sick6.frequency(25)
p3dx6.append(sick6)

motion6 = MotionVWDiff()
motion6.add_interface('ros')
p3dx6.append(motion6)

################ ENVIRONMENT ###############
env = Environment('../MORSE/scenarios/maze', fastmode=False)
env.place_camera([0, 0, 60])
env.aim_camera([0, 0, 0])
