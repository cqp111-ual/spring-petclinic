FROM maven:3.9-eclipse-temurin-17-focal AS build
WORKDIR /app
# First copy only the pom file. This is the file with less change
COPY ./pom.xml .
# Download the package and make dependencies cached in docker image
RUN mvn -B -f ./pom.xml -s /usr/share/maven/ref/settings-docker.xml clean dependency:go-offline
# Copy the actual code
COPY ./ .
# Then build the code
RUN mvn -B -f ./pom.xml -s /usr/share/maven/ref/settings-docker.xml clean package

# Start with a base image containing Java runtime
FROM maven:3.9.6-eclipse-temurin-17
# Make port 8080 available to the world outside this container
EXPOSE 8080
# The application's jar file
# ARG JAR_FILE=target/*.jar
# Copy the application's jar to the container
COPY --from=build /app/target/*.jar app.jar
# Run the jar file
ENTRYPOINT ["java","-jar","/app.jar"]
