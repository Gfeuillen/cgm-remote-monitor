FROM node:20-alpine3.17 as build
WORKDIR /srv
COPY nightscout-librelink-up/package*.json /srv/
RUN npm ci
COPY nightscout-librelink-up/tsconfig.json /srv/
COPY nightscout-librelink-up/src /srv/src/
RUN npm run build
RUN npm ci --production

FROM node:16.16.0-alpine

LABEL maintainer="Nightscout Contributors"

COPY --from=build /srv/node_modules /srv/node_modules
COPY --from=build /srv/dist /srv/

WORKDIR /opt/app
ADD . /opt/app

# TODO: We should be able to do `RUN npm install --only=production`.
# For this to work, we need to copy only package.json and things needed for `npm`'s to succeed.
# TODO: Do we need to re-add `npm audit fix`? Or should that be part of a development process/stage?
RUN npm install --cache /tmp/empty-cache && \
  npm run postinstall && \
  npm run env && \
  rm -rf /tmp/*
  # TODO: These should be added in the future to correctly cache express-minify content to disk
  # Currently, doing this breaks the browser cache.
  # mkdir /tmp/public && \
  # chown node:node /tmp/public

USER node
EXPOSE 1337

COPY startup-script.sh /opt/app/startup-script.sh

CMD /opt/app/startup-script.sh
