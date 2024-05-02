FROM openjdk:21-jdk

COPY target/ringkascrud-0.0.1-SNAPSHOT.jar app-1.0.0.jar

ENTRYPOINT ["java", "-jar", "app-1.0.0.jar"]