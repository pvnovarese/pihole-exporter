ARG IMAGE=alpine
ARG OS=linux
ARG ARCH=amd64

FROM golang:alpine as builder

WORKDIR /go/src/github.com/eko/pihole-exporter
COPY . .

RUN apk update && \
    apk --no-cache add git alpine-sdk upx

RUN GO111MODULE=on go mod vendor
RUN CGO_ENABLED=0 GOOS=$OS GOARCH=$ARCH go build -ldflags '-s -w' -o binary ./
RUN upx -f --brute binary

FROM $IMAGE

LABEL name="pihole-exporter"
HEALTHCHECK CMD wget --spider http://127.0.0.1:9617/metrics || exit 1 
WORKDIR /root/
COPY --from=builder /go/src/github.com/eko/pihole-exporter/binary pihole-exporter

CMD ["./pihole-exporter"]
