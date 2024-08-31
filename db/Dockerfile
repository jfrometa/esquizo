# Use the official Dart SDK image as the build environment
FROM dart:stable AS build

WORKDIR /app

# Install Node.js (required for Prisma CLI)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Prisma CLI globally
RUN npm install -g prisma

# Resolve app dependencies.
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and the wait-for-it script
COPY . .
COPY scripts/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# Generate Prisma Client
RUN npx prisma generate

# Generate a production build.
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Ensure packages are still up-to-date if anything has changed.
RUN dart pub get --offline
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Start with a minimal Debian-based image for the final stage
FROM debian:buster-slim

# Install Node.js and any necessary dependencies for PostgreSQL communication
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the AOT compiled server and runtime files from the build stage
COPY --from=build /runtime/ /
COPY --from=build /app/build/bin/server /app/bin/

# Copy the wait-for-it script from the build stage
COPY --from=build /usr/local/bin/wait-for-it.sh /usr/local/bin/wait-for-it.sh

# Expose the port your Dart application will run on
EXPOSE 8080

# Start the server after the database is ready and run prisma db push
CMD ["wait-for-it.sh", "my_database:5432", "--", "sh", "-c", "npx prisma db push && /app/bin/server"]