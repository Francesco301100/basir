# ============================
#   BUILD STAGE
# ============================
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Copy Maven wrapper and config first (caching)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Pre-download dependencies (massive speed boost)
RUN ./mvnw dependency:go-offline

# Copy the source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests


# ============================
#   RUNTIME STAGE
# ============================
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copy only the final JAR
COPY --from=build /app/target/*.jar app.jar

# Your Spring Boot app listens on 8085
EXPOSE 8085

ENTRYPOINT ["java", "-jar", "app.jar"]
