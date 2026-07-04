FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY order-service/order-container/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
