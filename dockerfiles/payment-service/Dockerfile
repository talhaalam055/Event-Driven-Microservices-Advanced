FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY payment-service/payment-container/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
