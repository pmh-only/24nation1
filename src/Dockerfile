FROM alpine

WORKDIR /app

RUN apk add --no-cache gcompat

USER 1000:1000

COPY --chown=1000:1000 ./product ./product

ENTRYPOINT ["/app/product"]
