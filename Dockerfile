FROM bitnami/node:14.17.0-prod-debian-10-r22

# Create app directory
WORKDIR /usr/src/app

# Permissions
RUN chgrp -R 0 /usr/src/app && \
     chmod -R g=u /usr/src/app

ENV NODE_PORT=8080
EXPOSE 8080
CMD ["node", "app.js"]



# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm ci --production
# If you are building your code for production
#RUN npm ci --only=production


# Bundle app source
COPY ./ .