FROM golang:1.24-alpine3.22 as build

ARG DOCKER_AUTH_VER 1.14.0
ARG DOCKER_AUTH_REF d3f46f7998ec6ce0abc4c235a35449c58d240f73

ARG VERSION
ENV VERSION "${VERSION}"

ARG BUILD_ID
ENV BUILD_ID "${BUILD_ID}"

ARG CGO_EXTRA_CFLAGS

RUN apk add -U --no-cache ca-certificates make git gcc musl-dev binutils-gold

WORKDIR /src

# hadolint ignore=DL3003
RUN git clone https://github.com/cesanta/docker_auth.git \
  && cd docker_auth \
  && git checkout ${DOCKER_AUTH_REF} \
  && mv auth_server /build

WORKDIR /build

RUN make build

FROM alpine:3.22 as runtime

COPY --from=build /build/auth_server /docker_auth/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/docker_auth/auth_server"]
CMD ["/config/auth_config.yml"]

EXPOSE 5001

