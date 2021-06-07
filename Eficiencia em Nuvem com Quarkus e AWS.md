# Eficiencia em Nuvem com Quarkus e AWS

Repo: https://github.com/CaravanaCloud/telemetry-demo

Economize na conta de cloud e entendenda o desempenho de sua aplicaçao

Os comandos abaixos foram testados no Amazon Linux, mas funcionam igualmente em outras distribuiçoes.

# Ferramentas Recomendadas


## [Cloud9](https://aws.amazon.com/cloud9/)

SSH
```
 ssh-keygen 
 
```

Github
```
git clone git@github.com:CaravanaCloud/telemetry-demo.git 
git config --global user.name "Julio Faerman"
git config --global user.email julio@noemail.com

```

EBS Resize
```
sudo growpart /dev/nvme0n1 1
sudo xfs_growfs -d /

```

Security Group
```
export C9_SECG=$(curl -s http://169.254.169.254/latest/meta-data/security-groups/)
export C9_MAC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
export C9_VPC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${C9_MAC}/vpc-id)

export C9_SECG_ID=$(aws ec2 describe-security-groups \
    --filter Name=vpc-id,Values=$C9_VPC Name=group-name,Values=$C9_SECG \
    --query 'SecurityGroups[*].[GroupId]' \
    --output text)

echo $C9_SECG_ID

aws ec2 authorize-security-group-ingress \
	--group-id $C9_SECG_ID \
	--protocol tcp \
	--port 8080 \
	--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
	--group-id $C9_SECG_ID \
	--protocol tcp \
	--port 8000 \
	--cidr 0.0.0.0/0
```


## SDK Man
```
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

## GraalVM
```
sdk install java 21.1.0.r11-grl 
gu install native-image
```

## Maven
```
sdk install maven
```

## DirEnv

```
curl -sfL https://direnv.net/install.sh | bash
echo "" >> $HOME/.bashrc
echo \"$(direnv hook bash)\" >> $HOME/.bashrc
echo "" >> $HOME/.bashrc
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


# Telemetry Demo
```
 mvn -f telemo-quarkus/pom.xml clean compile quarkus:dev
```

```
export C9_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo $C9_IP
echo http://$C9_IP:8080/index.html
echo http://$C9_IP:8080/admin.html
```

(Device Page)[http://localhost:8080/index.html]
(Admin Page)[http://localhost:8080/admin.html]

# Gatling
```
mvn -f telemo-gatling/pom.xml clean compile gatling:test
```

```
python -m http.server 8000 --directory /tmp/
```

# Native Build
```
mvn -f telemo-quarkus/pom.xml clean package -Pnative
```

```
 ./telemo-quarkus/target/telemo-quarkus-1.0.0-SNAPSHOT-runner 
```


## AWS

# Pricing

EC2 On-Demand: https://aws.amazon.com/ec2/pricing/on-demand/

Fargate Pricing: https://aws.amazon.com/fargate/pricing/

Lambda Pricing: https://aws.amazon.com/lambda/pricing/

https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/#:~:text=AWS%20Lambda%20functions%20execute%20in,specified%20in%20the%20function's%20configuration.

# AWS CLI

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

# VPC
```
aws ec2 create-vpc --cidr-block 10.0.0.0/16
# export VPC_ID=vpc-085a1211f81d07506
aws ec2   modify-vpc-attribute \
  --enable-dns-hostnames \
  --vpc-id $VPC_ID
aws ec2   modify-vpc-attribute \
  --enable-dns-support \
  --vpc-id $VPC_ID

```

```
aws ec2 create-internet-gateway
# export IGW_ID=igw-0eab7f7ac63ad98c6
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
```

```
aws ec2 create-route-table --vpc-id $VPC_ID
# export RTB_ID=rtb-08720cd07d756369f
aws ec2 create-route --route-table-id $RTB_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

```


```
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.100.0/24 --availability-zone us-west-2a
# export NET_A=subnet-0e6a19f9adc46f026
aws ec2 associate-route-table  --subnet-id $NET_A --route-table-id $RTB_ID
aws ec2 modify-subnet-attribute --subnet-id $NET_A --map-public-ip-on-launch


aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.101.0/24 --availability-zone us-west-2b
# export NET_B=subnet-053baadb01741414f
aws ec2 associate-route-table  --subnet-id $NET_B --route-table-id $RTB_ID
aws ec2 modify-subnet-attribute --subnet-id $NET_B --map-public-ip-on-launch

```

# AWS RDS 

```

export RDS_SECG=$(aws ec2 create-security-group \
	--group-name telemo-rds-secgrp \
	--description "telemo-rds-secg" \
	--vpc-id $VPC_ID \
	--query "GroupId" \
	--output text)

echo $RDS_SECG

export RDS_SECG_ID=$(aws ec2 describe-security-groups \
    --filter Name=vpc-id,Values=$VPC_ID Name=group-name,Values=telemo-rds-secgrp \
    --query 'SecurityGroups[*].[GroupId]' \
    --output text)
    
echo $RDS_SECG_ID
	
aws ec2 authorize-security-group-ingress \
	--group-id $RDS_SECG \
	--protocol tcp \
	--port 3306 \
	--cidr 0.0.0.0/0
```

```
aws rds create-db-subnet-group \
    --db-subnet-group-name $RDS_NETGRP \
    --db-subnet-group-description "Telemo RDS Subnet Group" \
    --subnet-ids $NET_A $NET_B
    

export RDS_ID=$(aws rds create-db-instance \
  --db-name $MYSQL_DB  \
  --db-instance-identifier $RDS_NAME \
  --allocated-storage 20 \
  --db-instance-class db.t3.large \
  --engine mysql \
  --engine-version 5.7 \
  --master-username $MYSQL_ROOT_USER \
  --master-user-password $MYSQL_ROOT_PASSWORD \
  --db-subnet-group-name  $RDS_NETGRP \
  --backup-retention-period 0 \
  --publicly-accessible \
  --vpc-security-group-ids $RDS_SECG \
  --query "DBInstance.DBInstanceIdentifier" \
  --output text)

echo $RDS_ID
export RDS_ID=telemo-mysql


export RDS_ENDPOINT=$(aws rds describe-db-instances  \
  --db-instance-identifier $RDS_ID  \
  --query "DBInstances[0].Endpoint.Address"  \
  --output text)
  
export RDS_PORT=$(aws rds describe-db-instances  \
  --db-instance-identifier $RDS_ID  \
  --query "DBInstances[0].Endpoint.Port"\
  --output text)

export RDS_JDBC=jdbc:mysql://$RDS_ENDPOINT:$RDS_PORT/$MYSQL_DB
echo $RDS_JDBC

```


# AWS Elastic Beanstalk
```
aws s3 mb s3://$EB_BUCKET
aws elasticbeanstalk create-application --application-name $EB_APP
aws iam create-role --role-name $EB_ROLE --assume-role-policy-document file://eb-ip-trust.json
aws iam put-role-policy --role-name $EB_ROLE --policy-name AllowS3 --policy-document file://eb-ip-trust.json
aws iam create-instance-profile --instance-profile-name eb-instance-profile
aws iam add-role-to-instance-profile --instance-profile-name eb-instance-profile --role-name $EB_ROLE


mvn -f telemo-quarkus/pom.xml clean package -Peb
aws s3 cp ./telemo-quarkus/target/telemo-eb.zip s3://$EB_BUCKET/$EB_VERSION_KEY

aws elasticbeanstalk create-application-version \
    --application-name $EB_APP \
    --version-label $EB_VERSION \
    --source-bundle S3Bucket=$EB_BUCKET,S3Key=$EB_VERSION_KEY

aws elasticbeanstalk check-dns-availability --cname-prefix $EB_CNAME
```

```
aws elasticbeanstalk create-configuration-template \
    --application-name $EB_APP \
    --template-name $EB_TEMPLATE \
    --solution-stack-name "64bit Amazon Linux 2 v3.2.0 running Corretto 11"
    
```

```
envsubst < options.txt.env > options.txt

```

```
aws elasticbeanstalk create-environment \
    --cname-prefix $EB_CNAME \
    --application-name $EB_APP \
    --template-name $EB_TEMPLATE \
    --version-label $EB_VERSION \
    --environment-name $EB_ENV \
    --output json \
    --option-settings file://options.txt
```

# AWS Lambda
```
aws iam create-role --role-name $LAMBDA_ROLE --assume-role-policy-document file://lambda-role-trust.json
aws iam put-role-policy --role-name $EB_ROLE --policy-name AllowAPIs --policy-document file://lambda-role-trust.json

```

```
mvn -f telemo-quarkus/pom.xml clean package -Plambda -Dquarkus.package.type=native
```

```
sam deploy --guided -t target/sam.jvm.yaml 
```

```
export LAMBDA_JVM=$(aws cloudformation describe-stack-resources \
    --stack-name $SAM_JVM_STACK \
    --logical-resource-id TelemoQuarkus \
    --query "StackResources[0].PhysicalResourceId" \
    --output text) 

echo $LAMBDA_JVM

aws lambda update-function-configuration \
    --function-name $LAMBDA_JVM \
    --memory-size 8192 \
    --timeout 900 \
    --environment "Variables={\
        QUARKUS_DATASOURCE_JDBC_URL=$RDS_JDBC,\
        QUARKUS_DATASOURCE_USERNAME=$QUARKUS_DATASOURCE_USERNAME,\
        QUARKUS_DATASOURCE_PASSWORD=$QUARKUS_DATASOURCE_PASSWORD,\
        DATASOURCE_DB_KIND=$DATASOURCE_DB_KIND,\
        ORM_GENERATION=$ORM_GENERATION,\
        DATASOURCE_JDBC_INITIAL_SIZE=10,\
        DATASOURCE_JDBC_MIN_SIZE=1,\
        DATASOURCE_JDBC_MAX_SIZE=100}" \
    --output json 
    
```

# AWS Lambda Native

```
sam deploy --guided -t target/sam.native.yaml 
```


```
export LAMBDA_NATIVE=$(aws cloudformation describe-stack-resources \
    --stack-name $SAM_NATIVE_STACK \
    --logical-resource-id TelemoQuarkusNative \
    --query "StackResources[0].PhysicalResourceId" \
    --output text) 

echo $LAMBDA_NATIVE

aws lambda update-function-configuration \
    --function-name $LAMBDA_NATIVE \
    --memory-size 8192 \
    --timeout 900 \
    --environment "Variables={\
        QUARKUS_DATASOURCE_JDBC_URL=$RDS_JDBC,\
        QUARKUS_DATASOURCE_USERNAME=$QUARKUS_DATASOURCE_USERNAME,\
        QUARKUS_DATASOURCE_PASSWORD=$QUARKUS_DATASOURCE_PASSWORD,\
        DATASOURCE_DB_KIND=$DATASOURCE_DB_KIND,\
        ORM_GENERATION=$ORM_GENERATION,\
        DATASOURCE_JDBC_INITIAL_SIZE=10,\
        DATASOURCE_JDBC_MIN_SIZE=1,\
        DATASOURCE_JDBC_MAX_SIZE=100}" \
    --output json 

```

# Holy Grail?

¯\_(ツ)_/¯

# Conclusion

5- Test your compute costs to define "normal".
4- Undertand your percentiles and detect "anomalies".
3- Beware of Database Pooling and HTTP Caching / Throttling.
2- Make it as fast as needed, but not faster.
1- Try the [Telemetry Demo](https://github.com/CaravanaCloud/telemetry-demo)!

## Gatling Results

[Local JVM](https://s3-us-west-2.amazonaws.com/faermanj.me/telemosimulation_local_jvm_c52xlarge_20210607010245004/index.html)
[Local Native](https://s3-us-west-2.amazonaws.com/faermanj.me/telemosimulation_local_native_c52xlarge_20210607084658441/index.html)
[Elastic Beanstalk](https://s3-us-west-2.amazonaws.com/faermanj.me/telemosimulation_eb_20210605185313815/index.html)


Thank you!

