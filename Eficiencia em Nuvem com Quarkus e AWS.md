# Eficiencia em Nuvem com Quarkus e AWS

Repo: https://github.com/CaravanaCloud/telemetry-demo

Economize na conta de cloud e entendenda o desempenho de sua aplicaçao

Os comandos abaixos foram testados no RHEL, mas funcionam igualmente em outras distribuiçoes.

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
python -m http.server 8000 --directory /tmp/
```

# Native Build
```
mvn -f telemo-quarkus/pom.xml clean package -Pnative
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

export RDS_ENDPOINT=$(aws rds describe-db-instances  \
  --db-instance-identifier $RDS_ID  \
  --query "DBInstances[0].Endpoint.Address"  \
  --output text)
  
export RDS_PORT=$(aws rds describe-db-instances  \
  --db-instance-identifier $RDS_ID  \
  --query "DBInstances[0].Endpoint.Port"\
  --output text)

echo $RDS_ENDPOINT:$RDS_PORT
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
    --option-settings file://options.txt
```

# AWS Lambda
```
aws iam create-role --role-name $LABMDA_ROLE --assume-role-policy-document file://lambda-role-trust.json
aws iam put-role-policy --role-name $EB_ROLE --policy-name AllowAPIs --policy-document file://lambda-role-trust.json


```




# Conclusion

3- Test your compute costs to define "normal".
2- Undertand your percentiles and detect "anomalies".
1- Try the [Telemetry Demo](https://github.com/CaravanaCloud/telemetry-demo)!

Thank you!

