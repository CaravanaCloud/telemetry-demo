# telemetry-demo

A sample application using modern Java and Cloud technologies.

Featuring:
- Quarkus
- GraalVM
- Gatling
- AWS

# Exploring with Jupyter

Start a jupyter notebook instance:
```
pip install jupyter
jupyter notebook
```


# Useful Commands

## Environment Variables (.envrc)
```
export MYSQL_ROOT_PASSWORD="Masterkey321"
export MYSQL_PORT=3334
export QUARKUS_DATASOURCE_JDBC_URL="jdbc:mysql://localhost:3333/telemo-db"
export QUARKUS_DATASOURCE_DB_KIND="mysql"
export QUARKUS_DATASOURCE_USERNAME="root"
export QUARKUS_DATASOURCE_PASSWORD="Masterkey321"
export QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION="update"
```
[All Quarkus Config Options](https://quarkus.io/guides/all-config)

## Install direnv
```
curl -sfL https://direnv.net/install.sh | bash
```
## Load environment variables using [direnv](https://direnv.net/)
```
direnv allow
```
## Install sdkman
```
curl -s "https://get.sdkman.io" | bash
```
## Install graalvm
```
sdk install java 21.0.0.2.r11-grl
```
## Install maven
```
sdk install maven
```
## Generate Quarkus Application
```
mvn io.quarkus:quarkus-maven-plugin:1.13.2.Final:create \
-DprojectGroupId=telemo \
-DprojectArtifactId=telemo-quarkus \
-DclassName="telemo.HeartbeatResource" \
-Dpath="/hb"
```
### Start Quarkus in Dev Mode
```
./mvnw quarkus:dev
```
### Start MySQL in a Container
```
docker run --rm -p $MYSQL_PORT:3306 \
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
mysql --host=127.0.0.1 --port=$MYSQL_PORT -uroot -p$MYSQL_ROOT_PASSWORD
```
### Run tests and generate reports
```
./mvnw verify
```
### Package uber-jar Executable
```
./mvnw clean package -Dquarkus.package.type=uber-jar
```
### Start uber-jar
```
java -jar ./target/telemo-quarkus-1.0.0-SNAPSHOT-runner.jar
```
### Fire gatling
```
mvn gatling:test
```
### Package Local Native Executable
```
/mvnw package -Pnative
```
### Package Container with Native Executable
```
./mvnw package -Pnative -Dquarkus.native.container-build=true
```
