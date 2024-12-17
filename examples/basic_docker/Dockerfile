FROM node:20.11.1-alpine
WORKDIR /app
COPY package.json .
COPY package-lock.json .
COPY src ./src
COPY .env .env
RUN npm install
CMD ["node", "--env-file=.env", "src/server.js"]
