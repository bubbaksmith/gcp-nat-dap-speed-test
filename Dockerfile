# Build stage
FROM golang:1.21.4 AS builder

WORKDIR /app

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Final stage
FROM gcr.io/distroless/base

WORKDIR /app

COPY --from=builder /app/main .

CMD ["./main"]