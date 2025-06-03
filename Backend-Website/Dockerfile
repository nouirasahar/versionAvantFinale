# Use Node.js as the base image
FROM node:20

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Make sure the backend script is executable
RUN chmod +x ./Backend/Node/run-Node-Mongodb.sh

# Expose the port your app runs on
EXPOSE 5000

# Command to run your application
CMD ["node", "index.js"]