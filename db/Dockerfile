# Step 1: Build Phase
FROM dart:stable AS build

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Set up working directory
WORKDIR /app

# Copy the Dart package dependencies and install them
COPY pubspec.* ./
RUN dart pub get

# Copy the entire project and clean npm cache
COPY . ./
RUN npm cache clean --force

# Install Prisma with legacy peer dependencies to avoid conflicts
RUN npm init -y

RUN npm install prisma
RUN npx prisma init --datasource-provider=postgresql
RUN npx prisma generate

# Build the Dart Frog server
RUN dart pub run build_runner build
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Compile the Dart executable
RUN dart pub get --offline
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Copy runtime dependencies for Prisma
RUN FILES="libz.so libgcc_s.so libssl.so libcrypto.so"; \
    for file in $FILES; do \
    so="$(find / -name "${file}*" -print -quit)"; \
    dir="$(dirname "$so")"; \
    mkdir -p "/runtime${dir}"; \
    cp "$so" "/runtime$so"; \
    echo "Copied $so to /runtime${so}"; \
    done

# Step 2: Runtime Phase
FROM scratch

# Copy runtime dependencies from the build phase
COPY --from=build /runtime/ /

# Copy the compiled Dart server from the build phase
COPY --from=build /app/build/bin/server /app/bin/

# Copy the Prisma query engine binary
COPY --from=build /app/prisma-query-engine /app/bin/

# Set the working directory and environment variables
WORKDIR /app/bin/
ENV DATABASE_URL=""
ENV PORT=8080

# Expose the application port
EXPOSE 8080

# Run the Dart server
CMD ["/app/bin/server"]