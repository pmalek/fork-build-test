# ------------------------------------------------------------------------------
# Builder
# ------------------------------------------------------------------------------

FROM golang:1.21.1 as builder

WORKDIR /workspace
ARG GOPATH
ARG GOCACHE
ARG GOMODCACHE
ENV GOPATH=$GOPATH
ENV GOCACHE=$GOCACHE
ENV GOMODCACHE=$GOMODCACHE
# Use cache mounts to cache Go dependencies and bind mounts to avoid unnecessary
# layers when using COPY instructions for go.mod and go.sum.
# https://docs.docker.com/build/guide/mounts/
RUN --mount=type=cache,target=$GOMODCACHE \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    go mod download -x

ARG TARGETARCH

RUN --mount=type=cache,target=$GOCACHE \
    --mount=type=cache,target=$GOMODCACHE \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    go env

RUN --mount=type=cache,target=$GOCACHE \
    --mount=type=cache,target=$GOMODCACHE \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    ls -la $GOMODCACHE

# Use cache mounts to cache Go dependencies and bind mounts to avoid unnecessary
# layers when using COPY instructions for go.mod and go.sum.
# https://docs.docker.com/build/guide/mounts/
RUN --mount=type=cache,target=$GOCACHE \
    --mount=type=cache,target=$GOMODCACHE \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    --mount=type=bind,source=main.go,target=main.go \
    CGO_ENABLED=0 GOOS=linux GOARCH="${TARGETARCH}" \
    go build -o manager -ldflags "-s -w" .

RUN --mount=type=cache,target=$GOCACHE \
    --mount=type=cache,target=$GOMODCACHE \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    ls -la $GOMODCACHE

# ------------------------------------------------------------------------------
# Distroless (default)
# ------------------------------------------------------------------------------

# Use distroless as minimal base image to package the operator binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot as distroless

WORKDIR /
COPY --from=builder /workspace/manager .
USER 65532:65532

ENTRYPOINT ["/manager"]