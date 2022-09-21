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


#alias init_ros="source /opt/ros/melodic/setup.zsh"

init_ros() { 
	CODENAME=$(lsb_release -c | awk '{print $2}')
	case $CODENAME in
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

init_ros2() { 
	CODENAME=$(lsb_release -c | awk '{print $2}')
	case $CODENAME in
		bionic)
			source /opt/ros/eloquent/setup.zsh
			;;
		focal)
			source /opt/ros/foxy/setup.zsh
			;;
		*)
			echo "Unknown codename $CODENAME"
			;;
	esac
}

init_current_ros() {
	source devel/setup.zsh
}

init_current_ros2() {
	source install/local_setup.zsh
}
