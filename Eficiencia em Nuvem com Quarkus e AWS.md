# Eficiencia em Nuvem com Quarkus e AWS

Repo: https://github.com/CaravanaCloud/telemetry-demo


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

## HTop
```
sudo yum -y install htop
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
https://github.com/CaravanaCloud/telemetry-demo
# Telemetry Demo
```
 mvn -f telemo-quarkus/pom.xml clean compile quarkus:dev

```

(Device Page)[http://localhost:8080/index.html]
(Admin Page)[http://localhost:8080/admin.html]

# Gatling
```
mvn -f telemo-gatling/pom.xml clean compile gatling:test
```

```
python -m http.server 8000
```


## AWS

# Pricing

EC2 On-Demand: https://aws.amazon.com/ec2/pricing/on-demand/

Fargate Pricing: https://aws.amazon.com/fargate/pricing/

Lambda Pricing: https://aws.amazon.com/lambda/pricing/

https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/#:~:text=AWS%20Lambda%20functions%20execute%20in,specified%20in%20the%20function's%20configuration.


# Conclusion

3- Test your compute costs to define "normal".
2- Undertand your percentiles and detect "anomalies".
1- Try the [Telemetry Demo](https://github.com/CaravanaCloud/telemetry-demo)!

Thank you!

