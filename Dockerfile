FROM ubuntu:latest

RUN apt update -y && apt install nodejs npm wget -y
RUN npm i @diplodoc/cli -g
RUN npm i http-server -g

EXPOSE 8080

VOLUME [ "/project" ]

CMD cd /project && make run