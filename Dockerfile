#FROM scratch
FROM ubuntu:latest
#COPY https://github.com/bphett/telly-opus/releases/download/v1.1.0.12/telly-opus-linux-amd64 ./app

# Install curl or wget (choose whichever is preferred)
RUN apt-get update && apt-get install -y curl

# Download the binary from GitHub release
RUN curl -L https://github.com/bphett/telly-opus/releases/download/v1.1.0.12/telly-opus-linux-amd64 -o ./app

# Make it executable
RUN chmod +x ./app

EXPOSE 6077
ENTRYPOINT ["./app"]


