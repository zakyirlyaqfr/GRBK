FROM alpine:latest

# Install package
RUN apk add --no-cache unzip ca-certificates curl

# Paksa sistem mendownload langsung versi 0.28.3
RUN curl -L "https://github.com/pocketbase/pocketbase/releases/download/v0.28.3/pocketbase_0.28.3_linux_amd64.zip" -o /tmp/pb.zip && \
    unzip /tmp/pb.zip -d /pb/ && \
    rm /tmp/pb.zip

EXPOSE 8080

CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080", "--dir=/pb/pb_data"]
