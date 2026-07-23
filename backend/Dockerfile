# ============================================
# Multi-stage Dockerfile — Taco'Os Backend
# JDK 21 + H2 (testing) + Spring Boot 3.5.15
# Target: linux/arm64 (OCI ARM instance)
# ============================================

# ── Stage 1: Build ─────────────────────────────────────────────
FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

# Copy Maven wrapper + pom.xml first (cache dependencies)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies (cached if pom.xml unchanged)
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build fat JAR (skip tests for faster build)
RUN ./mvnw package -DskipTests -B

# ── Stage 2: Runtime ──────────────────────────────────────────
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy fat JAR from build stage
COPY --from=build /app/target/sistema-global-0.0.1-SNAPSHOT.jar app.jar

# Expose port
EXPOSE 8080

# Default profile: dev (H2 in-memory DB)
ENV SPRING_PROFILES_ACTIVE=dev

# Run
ENTRYPOINT ["java", "-jar", "app.jar"]
