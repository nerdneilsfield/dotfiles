# catkin_make
# alias catm="catkin_make  --use-ninja --install -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
# alias catmp="cd ../../ & catkin_make  --use-ninja --install -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
# alias catim="catkin_make_isolated --use-ninja --install -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
# alias catimp="cd ../../ & catkin_make_isolated  --use-ninja --install -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

alias catm="catkin build  --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias catmr="catkin build  --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias catmd="catkin build  --cmake-args -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias catmn="catkin build --cmake-args  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja"
# alias catim="catkin_make_isolated --use-ninja  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
# alias catimp="cd ../../ & catkin_make_isolated  --use-ninja  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias colb="colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja"
alias colbr="colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja"
alias colbd="colcon build --cmake-args -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja"
alias colbp="colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja --select-package"

#alias init_ros="source /opt/ros/melodic/setup.zsh"

# @brief Install ROS2 Humble desktop full distribution
# @return 0 on success
# @example install_ros2
# @category ros
install_ros2(){
	sudo apt install -y software-properties-common
	sudo add-apt-repository universe
	sudo apt-get update && sudo apt-get install -y curl gnupg2 lsb-release
	curl -sSL https://gh.dqi.me/https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.asc
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.asc] http://packages.ros.org/ros2/ubuntu $(get_ubuntu_codename) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y ros-humble-desktop-full python3-colcon-common-extensions
}


# @brief Initialize ROS1 environment based on Ubuntu version
# @return 0 on success
# @example init_ros
# @category ros
init_ros() { 
	CODENAME=$(lsb_release -c | awk '{print $2}')
	case $CODENAME in
		noble | jammy)
			red_echo "Your Ubuntu version is not supported by ROS1"
			;;
		bionic)
			source /opt/ros/melodic/setup.zsh
			;;
		focal)
			source /opt/ros/noetic/setup.zsh
			;;
		*)
			echo "Unknown codename $CODENAME"
			;;
	esac
}

# @brief Initialize ROS2 environment based on Ubuntu version
# @return 0 on success
# @example init_ros2
# @category ros
init_ros2() { 
	CODENAME=$(lsb_release -c | awk '{print $2}')
	case $CODENAME in
		bionic)
			source /opt/ros/eloquent/setup.zsh
			;;
		focal)
			source /opt/ros/foxy/setup.zsh
			;;
		jammy)
			source /opt/ros/humble/setup.zsh
			;;
		noble)
			source /opt/ros/jazzy/setup.zsh
			;;
		*)
			echo "Unknown codename $CODENAME"
			;;
	esac
}

# @brief Initialize current ROS1 workspace
# @return 0 on success
# @example init_current_ros
# @category ros
init_current_ros() {
	source devel/setup.zsh
}

# @brief Initialize current ROS2 workspace
# @return 0 on success
# @example init_current_ros2
# @category ros
init_current_ros2() {
	source install/setup.zsh
}
