FROM node:11-alpine as builder
WORKDIR /home/node/app
COPY package.json package-lock.json src index.js tslint.json ./
RUN npm install --production

FROM node:11-alpine as runner
WORKDIR /home/node/app
COPY --from=builder /home/node/app .
CMD ["npm start"]
EXPOSE 8888 