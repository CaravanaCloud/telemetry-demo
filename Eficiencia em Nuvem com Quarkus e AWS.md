# Eficiencia em Nuvem com Quarkus e AWS

Repo: https://github.com/CaravanaCloud/telemetry-demo
This: 

# Ferramentas Recomendadas
```
```

## SDK Man
```
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

## GraalVM
```
sdk install java 21.1.0.r16-grl
```

## Maven
```
sdk install maven
```

## DirEnv

```
curl -sfL https://direnv.net/install.sh | bash
echo \"$(direnv hook bash)\" >> $HOME/.bashrc
eval "$(direnv hook bash)"
ln -s envrc .envrc
direnv allow .

```

# MySQL
```
docker run --rm -p $MYSQL_HOST:$MYSQL_PORT:3306 \
    --name telemo-mysql \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DB \
    -d mysql:5.7
```

```
docker ps
```

```
mysql --host=$MYSQL_HOST --port=$MYSQL_PORT -uroot -p$MYSQL_ROOT_PASSWORD

```

# Telemetry Demo
```
 mvn -f telemo-quarkus/pom.xml clean compile quarkus:dev

```




export QUARKUS_DATASOURCE_DB_KIND=mysql
## AWS

# Pricing

EC2 On-Demand: https://aws.amazon.com/ec2/pricing/on-demand/

Fargate Pricing: https://aws.amazon.com/fargate/pricing/

Lambda Pricing: https://aws.amazon.com/lambda/pricing/