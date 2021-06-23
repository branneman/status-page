FROM racket/racket:8.1-full AS build

WORKDIR /src/app
COPY . /src/app

RUN raco pkg config --set catalogs \
    https://download.racket-lang.org/releases/8.1/catalog/ \
    https://racksnaps.defn.io/snapshots/2021/06/01/catalog/
RUN raco pkg install --auto --batch \
    $(racket -e "(require setup/getinfo) (for-each (lambda (s) (display s) (display \" \")) ((get-info/full \".\") 'deps))")
RUN raco test -x src
RUN raco exe -o app main.rkt
RUN raco distribute /app app


FROM debian:stable-slim

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Etc/UTC"

RUN apt update && \
    apt-get install -qq -y ca-certificates openssl tzdata && \
    apt clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app /app

CMD [ "/app/bin/app" ]
