#compdef docker-compose

_docker_compose() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '1: :->command' \
        '2: :->container' \
        '*::arg:->args'

    case $state in
        command)
            local commands=(
                "build:Build or rebuild services"
                "config:Parse, resolve and render compose file in canonical format"
                "create:Creates containers for a service"
                "down:Stop and remove containers, networks"
                "events:Receive real time events from containers"
                "exec:Execute a command in a running container"
                "images:List images used by the created containers"
                "kill:Force stop service containers"
                "logs:View output from containers"
                "ls:List running compose projects"
                "pause:Pause services"
                "port:Print the public port for a port binding"
                "ps:List containers"
                "pull:Pull service images"
                "push:Push service images"
                "restart:Restart service containers"
                "rm:Removes stopped service containers"
                "run:Run a one-off command on a service"
                "start:Start services"
                "stop:Stop services"
                "top:Display the running processes"
                "unpause:Unpause services"
                "up:Create and start containers"
                "version:Show the Docker Compose version information"
            )
            _describe -t commands 'docker compose command' commands
            ;;
        container)
            local containers=($(docker ps --format '{{.Names}}'))
            _describe -t containers 'docker container' containers
            ;;
    esac
}

compdef _docker_compose docker-compose
