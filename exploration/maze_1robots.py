from morse.builder import *

# http://www.openrobots.org/morse/doc/1.2/dev/time_event.html
# Set the default value of the logic tic rate to 60 Hz
#bge.logic.setLogicTicRate(60.0)
#bge.logic.setPhysicsTicRate(60.0)

#bpymorse.set_speed(fps=10)

##################### ROBOT  0 ####################
p3dx0 = Pioneer3DX()
p3dx0.add_default_interface('ros')
p3dx0.translate(x=-38.0, y=38.0, z=0.0)

# http://wiki.ros.org/ROSARIA
odom0 = Odometry()
odom0.add_interface('ros', frame_id='/p3dx0_tf/odom', child_frame_id='/p3dx0_tf/base_footprint')
odom0.alter('Noise', pos_std=0.022, rot_std=0.02)
odom0.frequency(10) # 10Hz is the default rate for Pioneer 3-DX
p3dx0.append(odom0)

sick0 = Sick()
sick0.translate(z=0.252)
sick0.properties(Visible_arc = True)
sick0.properties(scan_window = 190)
sick0.properties(laser_range = 26.0)
sick0.add_interface('ros', frame_id='/p3dx0_tf/base_laser_link')
sick0.frequency(25) # problem of setting 25Hz, automatically change 30Hz by MORSE
p3dx0.append(sick0)

motion0 = MotionVWDiff()
motion0.add_interface('ros')
p3dx0.append(motion0)

#clock = Clock()
#clock.add_interface('ros', topic='/clock')
#p3dx0.append(clock)

################ ENVIRONMENT ###############
env = Environment('../MORSE/scenarios/maze', fastmode=False)
env.place_camera([0, 0, 60])
env.aim_camera([0, 0, 0])
#env.set_time_strategy(TimeStrategies.FixedSimulationStep)
env.show_debug_properties()
env.show_framerate()
env.show_physics()

