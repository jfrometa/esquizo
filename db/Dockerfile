FROM dart:stable AS build

# Download npm to work with prisma within the build phase involving Dart
# We need it within "build" buildphase since the prisma cli needs Dart to be installed too to run "dart run orm"
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&\
    apt-get install -y nodejs

# Setting up the working directory of the container
WORKDIR /app

# Copying pubspec from the project (left side) into the working directory of the container
COPY ./pubspec.* ./
RUN dart pub get

# Copy the project source code into the working directory
COPY . .

# Request DATABASE_URL as build-time environment variable because for prisma cli to read it
ARG DATABASE_URL

# Generate prisma-related files
RUN npm install prisma
RUN npx prisma generate

# Following code is specific to a server framework that you are using
# In the example below, it's dart frog
# Generate other Dart classes

# Dart frog build START
RUN dart pub run build_runner build

# Bundle the project
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Generate executable
RUN dart pub get --offline
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Dart frog build END

# Configure runtime for prisma
RUN FILES="libz.so libgcc_s.so libssl.so libcrypto.so"; \
    for file in $FILES; do \
    so="$(find / -name "${file}*" -print -quit)"; \
    dir="$(dirname "$so")"; \
    mkdir -p "/runtime${dir}"; \
    cp "$so" "/runtime$so"; \
    echo "Copied $so to /runtime${so}"; \
    done

FROM scratch

# Copy runtime from previous build phase
COPY --from=build /runtime/ /

# Copy executable from the previous phase
COPY --from=build /app/build/bin/server /app/bin/

# [IMPORTANT] Copy executable the binary engine
COPY --from=build /app/prisma/prisma-query-engine /app/bin/

# [IMPORTANT] Specify which directory to run the server from
# It's important because prisma will need to discover the query engine referring to Directory.current
# Running it inside /app/bin/ will make Directory.current return "/app/bin/" so it can discover the query engine placed in the same directory
WORKDIR /app/bin/

# "ARG DATABASE_URL" is a dynamic build-phase env variable
# "ENV DATABASE_URL" is a environment variable for the container
# By default it's empty but we will provide it within docker-compose
ENV DATABASE_URL = ""

# Server application port
# Default is 8080
ENV PORT = 8080

# Execute the server executable
CMD ["/app/bin/server"]