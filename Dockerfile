FROM golang AS build
WORKDIR /app
COPY go.mod .
RUN go mod download
COPY . .
RUN go build  .
FROM ubuntu
WORKDIR /app
COPY --from=build /app/broadcast .
USER nobody
ENTRYPOINT ["/app/broadcast"]
