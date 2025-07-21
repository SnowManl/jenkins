FROM node:7.8.0
WORKDIR /opt
ADD . /opt
RUN npm install
ENTRYPOINT npm run startENV PORT=3001
