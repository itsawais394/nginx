FROM  alpine:3.19
RUN sudo apt update&& sudo apt upgrade -y
WORKDIR /usr/src

COPY . /usr/src
RUN npm init -y && npm install package.json
EXPOSE 1111

CMD [ "node" , "server.js"]
