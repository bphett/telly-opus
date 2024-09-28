FROM scratch
COPY https://github.com/bphett/telly-opus/releases/download/v1.1.0.12/telly-opus-linux-amd64 ./app
EXPOSE 6077
ENTRYPOINT ["./app"]


