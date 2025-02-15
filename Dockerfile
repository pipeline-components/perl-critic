FROM alpine:3.21.3 as build

WORKDIR /app/

# hadolint ignore=DL3018
RUN apk add --no-cache \
    perl \
    perl-utils \
    build-base \
    perl-dev && \
    cpan Carton && \
    mkdir -p /app/

COPY app /app/

RUN carton install

# App container
FROM pipelinecomponents/base-entrypoint:0.5.0 as entrypoint

FROM alpine:3.21.3
COPY --from=entrypoint /entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV DEFAULTCMD perlcritic


ENV PERL5LIB=/app/local/lib/perl5/
ENV PATH="${PATH}:/app/local/bin/"
WORKDIR /app/

# hadolint ignore=DL3018
RUN apk add --no-cache perl
copy --from=build /app /app

WORKDIR /code/
# Build arguments
ARG BUILD_DATE
ARG BUILD_REF

# Labels
LABEL \
    maintainer="Robbert Müller <dev@pipeline-components.dev>" \
    org.label-schema.description="Perl-Critic in a container for gitlab-ci" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Perl-Critic" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.gitlab.io/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/perl-critic/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/perl-critic/" \
    org.label-schema.vendor="Pipeline Components"
