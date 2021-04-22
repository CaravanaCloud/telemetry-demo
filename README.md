# telemetry-demo

A sample application using modern Java and Cloud technologies.

Featuring:
- Quarkus

# Useful Commands

## Environment Variables (.envrc)
export MYSQL_ROOT_PASSWORD="Masterkey321"
export QUARKUS_DATASOURCE_JDBC_URL="jdbc:mysql://localhost:3336/telemo-db"
export QUARKUS_DATASOURCE_DB_KIND="mysql"
export QUARKUS_DATASOURCE_USERNAME="root"
export QUARKUS_DATASOURCE_PASSWORD="Masterkey321"
export QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION="drop-and-create"

## Generate Quarkus Application

mvn io.quarkus:quarkus-maven-plugin:1.13.2.Final:create \
-DprojectGroupId=telemo \
-DprojectArtifactId=telemo-quarkus \
-DclassName="telemo.HeartbeatResource" \
-Dpath="/hb"

## MySQL

### Start MySQL in a Container
```
docker run -p 3336:3306 \
    --name telemo-mysql \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=telemo-db \
    -d mysql:latest
```
### List containers to verify
```
docker container ls
```
### Connect to MySQL
```
mysql --host=127.0.0.1 --port=3336 -uroot -p$MYSQL_ROOT_PASSWORD
```
### Run tests and generate reports
```
./mvnw verify
```
### Start Quarkus in Dev Mode
```
./mvnw quarkus:dev
```
### Package Uber Jar Executable
```
./mvnw package -Dquarkus.package.type=uber-jar
```
### Start Application
```
java -jar target/telemo-quarkus-1.0.0-SNAPSHOT-runner.jar
```
### Fire gatling
```
mvn gatling:test
```
### Package Local Native Executable
```
/mvnw package -Pnative
```
### Package Container Native Executable
```
./mvnw package -Pnative -Dquarkus.native.container-build=true
```


