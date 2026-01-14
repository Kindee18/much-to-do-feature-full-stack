# Multi-stage build for MuchToDo backend
# Stage 1: Build
FROM golang:1.23 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files
COPY Server/MuchToDo/go.mod Server/MuchToDo/go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY Server/MuchToDo .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/api/main.go

# Stage 2: Runtime
FROM alpine:latest

# Install necessary packages
RUN apk --no-cache add ca-certificates wget

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Set the Current Working Directory inside the container
WORKDIR /home/appuser

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Change ownership of the binary
RUN chown appuser:appuser main

# Switch to non-root user
USER appuser

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./main"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
