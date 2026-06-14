FROM alpine:latest

# Install package yang dibutuhkan
RUN apk add --no-cache unzip ca-certificates curl

# Tentukan versi PocketBase (Silakan cek versi terbaru di GitHub PocketBase)
ARG PB_VERSION=0.28.3

# Download dan ekstrak PocketBase
RUN curl -L "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip" -o /tmp/pb.zip && \
    unzip /tmp/pb.zip -d /pb/ && \
    rm /tmp/pb.zip

# Buka port 8080
EXPOSE 8080

# Jalankan PocketBase (Arahkan ke folder data yang nantinya akan dipasangkan Volume)
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080", "--dir=/pb/pb_data"]