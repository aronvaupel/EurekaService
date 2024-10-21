FROM gradle:8.10.2-jdk21 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon

FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

RUN apk update && \
    apk add --no-cache curl docker

COPY --from=build /home/gradle/src/build/libs/*.jar app.jar

EXPOSE 8761

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8761/ || exit 1
