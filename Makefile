Version := $(shell git describe --tags --dirty)
GitCommit := $(shell git rev-parse HEAD)
LDFLAGS := "-s -w -X main.Version=$(Version) -X main.GitCommit=$(GitCommit)"
export GO111MODULE=on
.PHONY: all
all: test dist

.PHONY: test
test:
	CGO_ENABLED=0 go test $(shell go list ./... | grep -v /vendor/|xargs echo) -cover

.PHONY: dist
dist:
	mkdir -p bin/
	rm -rf bin/inlet*
	CGO_ENABLED=0 GOOS=linux go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inletsctl
	CGO_ENABLED=0 GOOS=darwin go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inletsctl-darwin
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inletsctl.exe
	CGO_ENABLED=0 GOOS=freebsd go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inletsctl-freebsd
	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inletsctl-armhf
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags $(LDFLAGS) -a -installsuffix cgo -o bin/inletsctl-arm64

	echo "Compressing the compiled artifacts"
	find bin -name "inletsctl*" -exec tar -cvzf {}.tgz {} \;
