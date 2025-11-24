FROM eclipse-temurin:17-jre-alpine

# Path of jar from Maven target directory
ARG JAR_FILE=target/*.jar

# Copy the JAR file into the image
COPY ${JAR_FILE} app.jar

# Expose the Spring Boot port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java","-jar","/app.jar"]
