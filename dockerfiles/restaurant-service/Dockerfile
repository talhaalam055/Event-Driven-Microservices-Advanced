FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY restaurant-service/restaurant-container/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
