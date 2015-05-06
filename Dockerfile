FROM node:0.10-onbuild

# These are node/js tools we need for the app
RUN npm install -g express \
&& npm install -g body-parser

# TODO lookup volume

RUN mkdir -p /react-comments-tutorial
WORKDIR /react-comments-tutorial

# Enable when not using directory mounting for development purposes
# ADD . /react-comments-tutorial

# CMD ["/usr/bin/node", "server.js"]

EXPOSE 3000
