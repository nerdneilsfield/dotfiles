export GOROOT=/usr/local/go
export GOPATH=$HOME/Source/Go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

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