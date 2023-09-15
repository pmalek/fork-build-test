.PHONY: build
build:
	docker build -t fork-build-test \
		--progress plain \
		--target distroless \
		--build-arg GOPATH=$(shell go env GOPATH) \
		--build-arg GOCACHE=$(shell go env GOCACHE) \
		--build-arg GOMODCACHE=$(shell go env GOMODCACHE) \
		--build-arg TARGETATCH=arm64 \
		.
