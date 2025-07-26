#export GOROOT=/usr/local/go
# if exist /usr/local/go then set
if [[ -d "/usr/local/go" ]]; then
  export GOROOT=/usr/local/go
elif [[ -d "/opt/homebrew/opt/golang/libexec/" ]]; then
  export GOROOT=/opt/homebrew/opt/golang/libexec
elif [[ -d "/usr/lib/go/" ]]; then
  export GOROOT=/usr/lib/go
fi

export GOPATH=$HOME/Source/Go
export GO111MODULE=on
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# if check_in_china; then
#   echo "set go proxy to goproxy.cn"
#   export GOPROXY=https://goproxy.cn
# else
#   echo "set go proxy to default"
#   export GOPROXY=https://goproxy.io
# fi

# macOS config
# export GOROOT=/usr/local/go
# export GOPATH=$HOME/go
# export GOBIN=$HOME/go/bin
# export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

alias goci='golangci-lint run --config $HOME/.data/.golangci.yml'
alias gostrict='golangci-lint run --config $HOME/.data/.golangci-strict.yml'
alias fmt='goimports -w . && go mod tidy'
alias gocc='fmt && goci'
alias goss='fmt && gostrict'
alias gdv='godotenv'
alias got='APP_ENV=dev go test --cover --race ./...'
alias gor='APP_ENV=stage go run main.go'

# @brief Create Go workspace directory
# @return 0 on success
# @example create_go_path
# @category golang
create_go_path(){
	mkdir ~/Source/Go
}

# @brief Install yamlfmt YAML formatter tool
# @return 0 on success
# @example install_yamlfmt
# @category golang
install_yamlfmt() {
	go install github.com/google/yamlfmt/cmd/yamlfmt@latest
}

# @brief Install YAML language server for IDE support
# @return 0 on success
# @example install_yaml_lsp
# @category golang
install_yaml_lsp() {
	npm install -g yaml-language-server
}

# @brief Install yamllint Python tool for YAML validation
# @return 0 on success
# @example install_yaml_lint
# @category golang
install_yaml_lint(){
	python3 -m pip install --user -U yamllint
}

# @brief Install comprehensive Go development tools and utilities
# @return 0 on success
# @example install_go_tools
# @category golang
install_go_tools () {
  mkdir -p $HOME/Source/app
	cd $HOME/Source/app
	# setproxy
	export GOPROXY=https://goproxy.cn
	# gopls
	local _gogettools=(
		"golang.org/x/tools/gopls@latest"
		"github.com/uudashr/gopkgs/cmd/gopkgs@latest"
		"github.com/ramya-rao-a/go-outline@latest"
		"github.com/haya14busa/goplay/cmd/goplay@latest"
		"github.com/fatih/gomodifytags@latest"
		"github.com/josharian/impl@latest"
		"github.com/cweill/gotests/...@latest"
		"github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
		"golang.org/x/tools/cmd/goimports@latest"
		"github.com/nerdneilsfield/gox@v1.0.2"
		"mvdan.cc/gofumpt@latest"
		"github.com/segmentio/golines@latest"
		"github.com/goreleaser/goreleaser/v2@latest"
	)

	echo $PWD
	echo update go get tools
	for _gogettool in $_gogettools; do
		echo update go install tools: $_gogettool
		GO111MODULE=on go install $_gogettool
	done

	# local -A _gotools=(
	# 	"go-delve/delve" "go-delve/delve/cmd/dlv" "incu6us/goimports-reviser"
	# )
	# 
	# echo update go install tools
 #  echo GITHUB_LOCATION="https://github.com"
	# for k v (${(kv)_gotools}) {
	# 	echo update go install tools: $k
	# 	local local_location=$GITHUB_LOCATION/$k
	# 	local repo_url=https://github.com/$k
	# 	if [ ! -d "$local_location" ]; then
	# 		git clone $repo_url $local_location
	# 	fi
	# 	cd $local_location
	# 	go install github.com/$v
	# }
	install_yamlfmt

}

# @brief Install goreleaser for automated Go project releases
# @return 0 on success
# @example install_gotools_goreleaser
# @category golang
install_gotools_goreleaser() {
	go install github.com/goreleaser/goreleaser/v2@latest

}

# @brief Add Go backports PPA for latest Go versions on Ubuntu
# @return 0 on success
# @example add_golang_ppa
# @category golang
add_golang_ppa() {
	sudo add-apt-repository ppa:longsleep/golang-backports
}

# @brief Install Go from backports PPA
# @return 0 on success
# @example install_golang_ppa
# @category golang
install_golang_ppa(){
	sudo apt install golang
}
