# Stage 1: Build the application
FROM gradle:8.10.2-jdk21 AS build

# Add GitHub credentials as build arguments
ARG GITHUB_USERNAME
ARG GITHUB_TOKEN

# Clone the repository using GitHub credentials
RUN git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/aronvaupel/EurekaService.git /home/gradle/src

WORKDIR /home/gradle/src

# Build the project
RUN gradle build --no-daemon

# Stage 2: Create a smaller image for running the application
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

RUN apk update && \
    apk add --no-cache curl

# Copy the built jar from the previous stage
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar

# Expose the Eureka port
EXPOSE 8761

# Healthcheck to ensure Eureka is running
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8761/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]