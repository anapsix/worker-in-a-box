## set everything up
FROM nginx/unit:1.16.0-minimal
ENV WORKER_ROOT=/srv/worker
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y apt-transport-https gnupg1 && \
    curl -sS https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    echo "deb https://packages.nginx.org/unit/debian/ buster unit" \
      > /etc/apt/sources.list.d/unit.list && \
    echo "deb-src https://packages.nginx.org/unit/debian/ buster unit" \
      >> /etc/apt/sources.list.d/unit.list && \
    curl -sS https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs unit-dev build-essential && \
    npm install -g --no-progress --unsafe-perm @cloudflare/wrangler unit-http && \
    apt-get remove --purge --auto-remove -y gnupg1
COPY config/launch_worker.js ${WORKER_ROOT}/
COPY config/unit_config.json /docker-entrypoint.d/
COPY ./ext/ ${WORKER_ROOT}/ext/
COPY package.json package-lock.json ${WORKER_ROOT}/
RUN cd ${WORKER_ROOT} && \
    npm link unit-http && npm install --no-progress --quiet && \
    apt-get remove -y unit-dev build-essential && \
    apt-get remove --purge --auto-remove -y && \
    rm -rf /var/lib/apt/lists/*


## flatten the image layers
FROM scratch
ENV WORKER_ROOT=/srv/worker
COPY --from=0 / /
ONBUILD ARG WRANGLER_ENV=staging
ONBUILD ARG WORKER_SCRIPT=main.js
ONBUILD ENV WRANGLER_ENV=${WRANGLER_ENV:-staging}
ONBUILD ENV WORKER_SCRIPT=${WORKER_SCRIPT:-main.js}
ONBUILD COPY . /app/
ONBUILD RUN cd /app && npm install && \
            wrangler build --env ${WRANGLER_ENV} && \
            cp ./dist/${WORKER_SCRIPT} ${WORKER_ROOT}/worker.js
ONBUILD WORKDIR ${WORKER_ROOT}
ONBUILD STOPSIGNAL SIGTERM
ONBUILD EXPOSE 8080
ONBUILD ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
ONBUILD CMD ["unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]
