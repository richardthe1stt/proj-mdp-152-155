# ---------- Build stage ----------
FROM maven:3.9.9-eclipse-temurin-11 AS build

WORKDIR /app

# Copy only the pom.xml first to leverage Docker layer caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline

# Now copy the rest of the source
COPY src ./src

# Package the application
RUN mvn clean package -DskipTests

# ---------- Run stage with Tomcat ----------
FROM tomcat:11.0.6-jdk21-temurin-noble

# Remove default apps to clean up Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR file from the Maven build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

