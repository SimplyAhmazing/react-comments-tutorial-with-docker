FROM node:0.10-onbuild
# replace this with your application's default port

# These are node/js tools we need for the app
RUN npm install -g express
RUN npm install -g body-parser
# RUN npm install -g typescript-compiler
# RUN npm install -g webpack
# RUN npm install --save-dev babel-loader
# RUN npm install es6-promise flux object-assign react
# RUN npm install --save-dev babelify

RUN mkdir -p /react-comments-tutorial
WORKDIR /react-comments-tutorial

# ADD . /react-comments-tutorial

# CMD ["/usr/bin/node", "server.js"]

EXPOSE 3000
