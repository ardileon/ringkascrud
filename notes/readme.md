# Cara setting apps spring-boot dan db_psql

# Perhatikan spasi karena ini yaml dia sensistive sama spasi atau tab dan perhatikan penepatan urutan service sesuai dengan spasi/tab

## docker-compose.yml
1. Kita buat dulu touch docker-compose.yml pada direktori root.

```docker
#  Service untuk menjalakan dbPostgresSQL
version: '3.4'

services:
  java_db:
    container_name: java_db
    image: postgres:16.2
    ports:
      - 5432:5432
    environment:
      POSTGRES_PASSWORD: 12345
      POSTGRES_USER: postgres
      POSTGRES_DB: ringkasdb00
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata: {}
```
Penjelasan:
  - version: '3.4' menjelaskan version docker compose yang kita gunakan.
  - services: di dalam docker compose yang kita gunakan terdapat berapa banyak service dalam satu services pada docker-compose.yml.
  - java_db: merupakan nama service didalam services docker-compose.yml
  - container_name: java_db. Didalam services java_db kita membuat container dengan nama java_db mengikuti nama service(dalam penaman container bebas mau ikutin nama service atau nggak).
  - image: postgres:16.2. Didalam services java_db kita memilih postgresSQL:version.
  - ports:
    - 5432:5432. Diawal ports adalah host dan setelahnya port untuk menghubungkan ke default ports psql pada container.
  - environment: disni kita melakukan konfigurasi untuk mengginstall postgresql dengan sesuai kita/user itu sendiri.
  - volumes:
      - pgdata:/var/lib/postgresql/data
  ini mendefinisikan volume bernama 'pgdata' yang merupakan alamat untuk menyimpan data yang disimpan oleh psql. Data yang disimpan tidak akan hilang bahkan sampai container dimatikan.
  - volumes:
    - pgdata: {}
  ini mendefinisikan volume dengan nama 'pgdata'. Tanda kurung kurawal kosong menandakan bahwa Docker akan membuat volume ini secara otomatis dan menghubungkannya ke lokasi yang ditentukan yaitu 'pgdata:/var/lib/postgresql/data'.

## Jalankan perintah #1
```bash
docker compose up -d namaServiceDocker
```
pada kasus ini java_db
```bash
docker compose up -d java_db
```
### setelah berhasil #2
- Matikan dengan cara dockerhub -> stop di container yang sedang running (nama artifactId pada spring boot apps).

## Configuration pada application.properties
```bash
# Database Config
spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DATABASE_USERNAME}
spring.datasource.password=${DATABASE_PASSWORD}

# spring jpa
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```
Penjelasan:
  - Pada 'Database Config' digunakan untuk menghubungkan database dengan apps spring-boot
  disini kita akan menghubungkan app spring-boot dengan mengambil dari variabel docker-compose.yml.
  - Pada 'Spring jpa' Kita akan menggunakan hibernate untuk mengelola skema database postgresql dan hibernate akan menghasilkan query sql yang sesuai dengan spesifikasi postgreSQL.

## Dockerfile
1. buat file Dockerfile pada direktori root
```docker
FROM openjdk:21-jdk

COPY target/ringkascrud-0.0.1-SNAPSHOT.jar app-1.0.0.jar

ENTRYPOINT ["java", "-jar", "app-1.0.0.jar"]
```
Penjelasan:
  - FROM openjdk:21-jdk. disini kita memberitahukan kita akan menggunakan java version 21.
  - COPY target/ringkascrud-0.0.1-SNAPSHOT.jar app-1.0.0.jar. Disini kita mengcopy file.jar dan me rename dengan app-1-0.0.jar
  - ENTRYPOINT disiini kita akan mengeksekusi program java "java" dengan menjalankan aplikasi Java yang dikemas dalam file JAR "-jar" dan nama appjarnya adalah  "app-1.0.jar".

## Add services untuk docker-compose.yml
```docker
services:
# Service untuk menjalankan java-apps-spring-boot
  java_app:
    container_name: java_app
    image: leokundxd/java_app:1.0.0
    build: .
    ports:
      - 8080:8080
    environment:
      - DATABASE_URL=jdbc:postgresql://java_db:5432/ringkasdb00
      - DATABASE_USERNAME=postgres
      - DATABASE_PASSWORD=12345
    depends_on:
      - java_db
```
Penjelasan:
  - java_app: merupakan nama service didalam services docker-compose.yml
  - container_name: java_app. Didalam services java_app kita membuat container dengan nama java_app mengikuti nama service(dalam penaman container bebas mau ikutin nama service atau nggak).
  - image: leokundxd/java_app:1.0.0. disini kita akan assign nama image dengan nama dockerhub kita sendiri. dan /java_app:1.0.0 sesuai dengan nama rename.jar
  - build: . Digunakan untuk kasih tahu path file Dockerfile karena pada kasus ini sama dengan docker-compose.yml yaitu di root maka kita kasih value : .
  ports:
    - 8080:8080 expose we are exposing the port8080 of java app container. The format is"host_port:container_port".
  - environment: disini list dari kebutuhan values yang akan digunakan untuk menghubungkan koneksi database yang ada dicontainer dengan apps spring-boot.
  value yang ada, akan kita pass value ke application.properties.
  - depends_on: Jadi kita akan membiarkan service java_db jalan dulu setelahya kita akan menjalankan service jav_app.

## Jalankan Perintah #3
Kita akan create .jar file pada apps java, dengan itu kita bisa memberikan ke docker image.

```bash
mvn clean package -DskipTests
```
## Selanjutnya build the docker image
```bash
docker compose build
```
## Untuk menjalankan
  Klik kanan pada docker-compose.yml terus compose up.
## Untuk mematikan
  Matikan dengan cara dockerhub -> stop di container yang sedang running (nama artifactId pada spring boot apps).

# Hasil keseluruhan

## Total keseluruhan docker-compose.yml

```docker
services:
# Service untuk menjalankan java-apps-spring-boot
  java_app:
    container_name: java_app
    image: leokundxd/java_app:1.0.0
    build: .
    ports:
      - 8080:8080
    environment:
      - DATABASE_URL=jdbc:postgresql://java_db:5432/ringkasdb00
      - DATABASE_USERNAME=postgres
      - DATABASE_PASSWORD=12345
    depends_on:
      - java_db

#  Service untuk menjalakan dbPostgresSQL
  java_db:
    container_name: java_db
    image: postgres:16.2
    ports:
      - 5432:5432
    environment:
      POSTGRES_PASSWORD: 12345
      POSTGRES_USER: postgres
      POSTGRES_DB: ringkasdb00
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata: {}
```

## Total keseluruhan Dockerfile
```docker
FROM openjdk:21-jdk

COPY target/ringkascrud-0.0.1-SNAPSHOT.jar app-1.0.0.jar

ENTRYPOINT ["java", "-jar", "app-1.0.0.jar"]
```

## Total application.properties
```bash
# Database Config
spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DATABASE_USERNAME}
spring.datasource.password=${DATABASE_PASSWORD}

# spring jpa
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```