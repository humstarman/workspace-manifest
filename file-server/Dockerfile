FROM golang:latest as build
ADD ./scripts/file-server.go /
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /file-server /file-server.go
FROM alpine:latest
COPY --from=build /file-server /
