#!/bin/bash

print_help() {
   echo "Wrapper under ROS API for Innopolis VTOL Dynamics simulator.
It automatically run all auxilliary scripts required to each specific mode and source necessary setup.bash files.
It supports all possible simulator modes.

https://github.com/InnopolisAero/innopolis_vtol_dynamics

Usage: run_sim.sh <command>

Commands:
hitl_inno_vtol                          Run dynamics simulator in HITL mode for inno_vtol airframe
hitl_flight_goggles                     Run dynamics simulator in HITL mode for flight_goggles airframe
sitl_inno_vtol                          Run dynamics simulator in SITL mode for inno_vtol airframe
sitl_flight_goggles                     Run dynamics simulator in SITL mode for flight_goggles airframe
sitl_inno_vtol_with_flight_stack        Run dynamics simulator in SITL mode for inno_vtol airframe (with additional including px4.launch)
sitl_flight_goggles_with_flight_stack   Run dynamics simulator in SITL mode for flight_goggles airframe (with additional including px4.launch)
help                                    Print this message and exit"
}

setup_ros() {
    # /opt/ros/$ROS_DISTRO/setup.bash should be either run first, or not run at all
    # If catkin_ws is not found, do nothing.
    DOCKER_CATKIN_WS_SETUP_BASH_PATH=/catkin_ws/devel/setup.bash
    MOST_PROBABLE_CATKIN_WS_SETUP_BASH_PATH=~/catkin_ws/devel/setup.bash
    if [ -f "$DOCKER_CATKIN_WS_SETUP_BASH_PATH" ]; then
        source /opt/ros/$ROS_DISTRO/setup.bash
        source $DOCKER_CATKIN_WS_SETUP_BASH_PATH
    elif [ -f "$MOST_PROBABLE_CATKIN_WS_SETUP_BASH_PATH" ]; then
        source /opt/ros/$ROS_DISTRO/setup.bash
        source $MOST_PROBABLE_CATKIN_WS_SETUP_BASH_PATH
    fi
}

setup_sitl_px4_flight_stack() {
    source ~/PX4-Autopilot/Tools/setup_gazebo.bash ~/PX4-Autopilot ~/PX4-Autopilot/build/px4_sitl_default
    export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/PX4-Autopilot
    export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:~/PX4-Autopilot/Tools/sitl_gazebo
}

setup_hitl() {
    if [ ! -z $DRONECAN_DEV_PATH_SYMLINK ]; then
        echo "Trying to create slcan0 for dronecan..."
        ./uavcan_tools/create_slcan_from_serial.sh $DRONECAN_DEV_PATH_SYMLINK slcan0
    fi
    if [ ! -z $CYPHAL_DEV_PATH_SYMLINK ]; then
        echo "Trying to create slcan1 for cyphal..."
        ./uavcan_tools/create_slcan_from_serial.sh $CYPHAL_DEV_PATH_SYMLINK slcan1
    fi
}

hitl_inno_vtol() {
    setup_ros
    setup_hitl
    roslaunch innopolis_vtol_dynamics hitl.launch   \
        vehicle:=innopolis_vtol                     \
        airframe:=inno_standard_vtol                \
        dynamics:=inno_vtol
}

hitl_flight_goggles() {
    setup_ros
    setup_hitl
    roslaunch innopolis_vtol_dynamics hitl.launch   \
        vehicle:=iris                               \
        airframe:=iris                              \
        dynamics:=flightgoggles_multicopter
}

sitl_inno_vtol() {
    setup_ros
    roslaunch innopolis_vtol_dynamics sitl.launch   \
        vehicle:=innopolis_vtol                     \
        airframe:=inno_standard_vtol                \
        dynamics:=inno_vtol                         \
        run_sitl_flight_stack:="false"
}

sitl_flight_goggles() {
    setup_ros
    roslaunch innopolis_vtol_dynamics sitl.launch   \
        vehicle:=iris                               \
        airframe:=iris                              \
        dynamics:=flightgoggles_multicopter         \
        run_sitl_flight_stack:="false"
}

sitl_inno_vtol_with_flight_stack() {
    setup_ros
    setup_sitl_px4_flight_stack
    roslaunch innopolis_vtol_dynamics sitl.launch   \
        vehicle:=innopolis_vtol                     \
        airframe:=inno_standard_vtol                \
        dynamics:=inno_vtol                         \
        run_sitl_flight_stack:="true"
}

sitl_flight_goggles_with_flight_stack() {
    setup_ros
    setup_sitl_px4_flight_stack
    roslaunch innopolis_vtol_dynamics sitl.launch   \
        vehicle:=iris                               \
        airframe:=iris                              \
        dynamics:=flightgoggles_multicopter         \
        run_sitl_flight_stack:="true"
}


cd "$(dirname "$0")"
set -e

if [ "$1" = "hitl_inno_vtol" ]; then
    hitl_inno_vtol
elif [ "$1" = "hitl_flight_goggles" ]; then
    hitl_flight_goggles
elif [ "$1" = "sitl_inno_vtol" ]; then
    sitl_inno_vtol
elif [ "$1" = "sitl_flight_goggles" ]; then
    sitl_flight_goggles
elif [ "$1" = "sitl_inno_vtol_with_flight_stack" ]; then
    sitl_inno_vtol_with_flight_stack
elif [ "$1" = "sitl_flight_goggles_with_flight_stack" ]; then
    sitl_flight_goggles_with_flight_stack
else
    print_help
fi