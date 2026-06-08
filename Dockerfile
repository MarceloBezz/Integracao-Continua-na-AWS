# Etapa de compilação
FROM golang:1.24 AS builder

WORKDIR /app

COPY . .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Etapa de execução
FROM ubuntu:latest

EXPOSE 8000

WORKDIR /app

ENV DB_HOST=host.docker.internal
ENV DB_PORT=5432
ENV PORT=8000

ENV DB_USER=root
ENV DB_PASSWORD=root
ENV DB_NAME=root

COPY --from=builder /app/main .
COPY --from=builder /app/templates ./templates

CMD ["./main"]