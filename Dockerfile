FROM rust:latest as builder

RUN apt-get update && apt-get install -y libpq-dev

WORKDIR /usr/src/app

COPY . .

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libpq5 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/target/release/proyecto2 /usr/local/bin/proyecto2

CMD ["proyecto2"]

