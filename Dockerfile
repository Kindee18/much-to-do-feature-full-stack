# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy dependency files first for better caching
COPY Server/MuchToDo/go.mod Server/MuchToDo/go.sum ./
RUN go mod download

# Copy source code
COPY Server/MuchToDo/ .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/api/main.go

# Final stage
FROM alpine:latest

# Install basic utilities (using healthcheck required tools)
RUN apk --no-cache add ca-certificates curl

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /home/appuser

# Copy binary from builder
COPY --from=builder /app/main .

# Set ownership
RUN chown appuser:appuser main

USER appuser

# Expose the application port
EXPOSE 3000

# Run the binary
CMD ["./main"]

# Health check on port 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
