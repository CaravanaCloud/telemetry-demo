# Eficiencia em Nuvem com Quarkus e AWS

Economize na conta de cloud e entendenda o desempenho de sua aplicaçao.

Repository: https://github.com/CaravanaCloud/telemetry-demo


# [AWS Cloud Shell](https://aws.amazon.com/cloudshell/)

https://console.aws.amazon.com/cloudshell/home

Inicie uma nova sessão do [tmux](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)
```
tmux new -s telemo
```

Se por qualquer motivo precisar recarregar a página, recarregue a sessão do tmux
```
tmux attach -t telemo
```
# Identificador Unico

```
export UNIQ="telemo$(date +'%m%d%s')"

echo $UNIQ
```
## [AWS VPC](https://aws.amazon.com/vpc/)
Create and configure the VPC
```
export VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --query "Vpc.VpcId" \
    --output text)

echo export VPC_ID=$VPC_ID

aws ec2 create-tags --resources $VPC_ID \
    --tags Key=Name,Value="vpc-$UNIQ"
    
export VPC_ID2=$(aws ec2 describe-vpcs \
    --filter --filters Name=tag:Name,Values="vpc-$UNIQ" \
    --query "Vpcs[0].VpcId" \
    --output text)

echo export VPC_ID=$VPC_ID2   

aws ec2   modify-vpc-attribute \
  --enable-dns-hostnames \
  --vpc-id $VPC_ID
  
aws ec2   modify-vpc-attribute \
  --enable-dns-support \
  --vpc-id $VPC_ID

```

Create and setup the Internet Gateway
```
export IGW_ID=$(aws ec2 create-internet-gateway \
    --query "InternetGateway.InternetGatewayId" \
    --output text)
    
echo $IGW_ID

aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
```

Setup the public Route Table
```
export RTB_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query "RouteTable.RouteTableId" \
    --output text)

echo export RTB_ID=$RTB_ID

aws ec2 create-route \
    --route-table-id $RTB_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

```

Setup the public Subnets

Availability Zone 1

```
export AZ1=$(aws ec2 describe-availability-zones \
    --query "AvailabilityZones[0].ZoneName" \
    --output text)
echo $AZ1

export NET_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.200.0/24 \
    --availability-zone "$AZ1" \
    --query "Subnet.SubnetId" \
    --output text)
    
echo export NET_A=$NET_A

aws ec2 associate-route-table \
    --subnet-id $NET_A \
     --route-table-id $RTB_ID
     
aws ec2 modify-subnet-attribute  \
    --subnet-id $NET_A  \
    --map-public-ip-on-launch
```

Availability Zone 2
```
export AZ2=$(aws ec2 describe-availability-zones \
    --query "AvailabilityZones[1].ZoneName" \
    --output text)

echo $AZ2

export NET_B=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.201.0/24 \
    --availability-zone "$AZ2" \
    --query "Subnet.SubnetId" \
    --output text)
    
echo export NET_B=$NET_B

aws ec2 associate-route-table \
    --subnet-id $NET_B \
     --route-table-id $RTB_ID
     
aws ec2 modify-subnet-attribute  \
    --subnet-id $NET_B  \
    --map-public-ip-on-launch

```


# AWS RDS
Databases can take a few minutes to become available.

```
export RDS_NETGRP=telemo-netgrp
export RDS_NAME=telemo-mysql
export RDS_ROOT_USER=root
export RDS_ROOT_PASSWORD=Masterkey321
export RDS_PORT=3306
export RDS_CIDR=0.0.0.0/0
export RDS_DB=telemodb
```

```
export RDS_SECG=$(aws ec2 create-security-group \
  --group-name telemo-rds-secgrp \
  --description "telemo-rds-secg" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

echo export RDS_SECG=$RDS_SECG

export RDS_SECG_ID=$(aws ec2 describe-security-groups \
  --filter Name=vpc-id,Values=$VPC_ID Name=group-name,Values=telemo-rds-secgrp \
  --query 'SecurityGroups[*].[GroupId]' \
  --output text)
    
echo export RDS_SECG_ID=$RDS_SECG_ID
	
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SECG \
  --protocol tcp \
  --port $RDS_PORT \
  --cidr $RDS_CIDR

aws rds create-db-subnet-group \
    --db-subnet-group-name $RDS_NETGRP \
    --db-subnet-group-description "Telemo RDS Subnet Group" \
    --subnet-ids $NET_A $NET_B
    

export RDS_ID=$(aws rds create-db-instance \
  --db-name $RDS_DB  \
  --db-instance-identifier $RDS_NAME \
  --allocated-storage 20 \
  --db-instance-class db.t3.large \
  --engine mysql \
  --engine-version 5.7 \
  --master-username $RDS_ROOT_USER \
  --master-user-password $RDS_ROOT_PASSWORD \
  --db-subnet-group-name  $RDS_NETGRP \
  --backup-retention-period 0 \
  --publicly-accessible \
  --vpc-security-group-ids $RDS_SECG \
  --query "DBInstance.DBInstanceIdentifier" \
  --output text)

echo export RDS_ID=$RDS_ID

aws rds wait db-instance-available --db-instance-identifier $RDS_ID

export RDS_ENDPOINT=$(aws rds describe-db-instances  \
  --db-instance-identifier $RDS_ID  \
  --query "DBInstances[0].Endpoint.Address"  \
  --output text)
  
export RDS_PORT=$(aws rds describe-db-instances  \
  --db-instance-identifier $RDS_ID  \
  --query "DBInstances[0].Endpoint.Port"\
  --output text)

export RDS_JDBC=jdbc:mysql://$RDS_ENDPOINT:$RDS_PORT/$MYSQL_DB
echo export RDS_JDBC=$RDS_JDBC

```

```
echo export VPC_ID=$VPC_ID
echo export NET_A=$NET_A
echo export NET_B=$NET_B
echo export RDS_ID=$RDS_ID
echo export RDS_JDBC=$RDS_JDBC
```

## [Cloud9](https://aws.amazon.com/cloud9/)

* Shareable
* Scale
* Reproducible
* Restorable
* Proximal

```
export C9_ITYPE=t3.2xlarge
export C9_ID=$(aws cloud9 create-environment-ec2 \
    --name "ide-$UNIQ" \
    --instance-type "$C9_ITYPE" \
    --subnet-id $NET_A \
    --automatic-stop-time-minutes 240 \
    --query "environmentId" \
    --output text)

echo https://us-west-2.console.aws.amazon.com/cloud9/ide/$C9_ID

aws cloud9 describe-environment-status \
    --environment-id $C9_ID 
```

# Inside C9

Homebrew
```
sudo passwd ec2-user
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ec2-user/.bash_profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc
```

GitHub
```
brew install gh
gh auth login

git clone git@github.com:CaravanaCloud/telemetry-demo.git
cd telemetry-demo 
```


EBS Resize
```
export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo $INSTANCE_ID

export VOL_ID=$(aws ec2 describe-volumes \
    --filters Name=attachment.instance-id,Values=$INSTANCE_ID \
    --query "Volumes[0].Attachments[0].VolumeId" \
    --output text)
echo $VOL_ID

aws ec2 modify-volume --volume-id $VOL_ID --size 64

sleep 10
sudo growpart /dev/nvme0n1 1
sudo resize2fs /dev/nvme0n1p1
df -h
```

Security Group
```
export C9_SECG=$(curl -s http://169.254.169.254/latest/meta-data/security-groups/)
export C9_MAC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
export C9_VPC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${C9_MAC}/vpc-id)

echo $C9_SECG
echo $C9_MAC
echo $C9_VPC

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
export JAVA_HOME=$HOME/.sdkman/candidates/java/current/
```

## Maven
```
sdk install maven
```

## DirEnv

```
curl -sfL https://direnv.net/install.sh | bash
echo "" >> $HOME/.bashrc
echo 'eval "$(direnv hook bash)"' >> $HOME/.bashrc
echo "" >> $HOME/.bashrc
eval "$(direnv hook bash)"
ln -s envrc .envrc
direnv allow .
```

## HTop
```
sudo yum -y install htop
```

## AWS CLI

```
sudo pip uninstall awscli

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm rf ./aws
/usr/local/bin/aws --version
```

## AWS Soundcheck
```
aws sts get-caller-identity --output json
```

# MySQL
```
docker run --rm -p $MYSQL_HOST:$MYSQL_PORT:3306 \
    --name telemo-mysql \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DB \
    -d mysql:5.7 && docker logs telemo-mysql --follow 
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
export GATLING_BASE_URL=http://localhost:8080
export GATLING_USERS_SEC=1
export GATLING_TIMES=3
export GATLING_LEVEL_MINUTES=2
mvn -f telemo-gatling/pom.xml clean compile gatling:test
```

```
pushd /home/ec2-user/environment/telemetry-demo/telemo-gatling/target/gatling/
python -m http.server 8000
```

# Native Build
```
export GRAALVM_VERSION="21.1.0" 
mvn -f telemo-quarkus/pom.xml clean package -Pnative -Dquarkus.native.container-build=true
```

```
ls ./telemo-quarkus/target/
./telemo-quarkus/target/telemo-quarkus-1.0.0-SNAPSHOT-runner 
```

More at: https://quarkus.io/guides/building-native-image

## AWS Pricing

EC2 On-Demand: https://aws.amazon.com/ec2/pricing/on-demand/

Fargate Pricing: https://aws.amazon.com/fargate/pricing/

Lambda Pricing: https://aws.amazon.com/lambda/pricing/

https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/#:~:text=AWS%20Lambda%20functions%20execute%20in,specified%20in%20the%20function's%20configuration.


# AWS Elastic Beanstalk
```
git clone https://github.com/CaravanaCloud/telemetry-demo.git
cd telemetry-demo
```

```
echo aws s3 mb s3://$EB_BUCKET
aws s3 mb s3://$EB_BUCKET

aws elasticbeanstalk create-application --application-name $EB_APP

aws iam create-role --role-name $EB_ROLE --assume-role-policy-document file://eb-ip-trust.json
aws iam put-role-policy --role-name $EB_ROLE --policy-name AllowS3 --policy-document file://eb-ip-policy.json
aws iam create-instance-profile --instance-profile-name eb-instance-profile
aws iam add-role-to-instance-profile --instance-profile-name eb-instance-profile --role-name $EB_ROLE
```

```
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
aws iam put-role-policy --role-name $EB_ROLE --policy-name AllowAPIs --policy-document file://lambda-role-policy.json
```

```
mvn -f telemo-quarkus/pom.xml clean package -Plambda
```
```
cat target/sam.jvm.yaml
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
mvn -f telemo-quarkus/pom.xml clean package -Plambda -Dquarkus.package.type=native -Dquarkus.native.container-build=true
```

```
sam deploy --guided -t target/sam.native.yaml 
```


```
export SAM_NATIVE_STACK=telemo-app
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

```
export GATLING_BASE_URL=https://grtc02dhfd.execute-api.us-west-2.amazonaws.com/
export GATLING_USERS_SEC=1
export GATLING_TIMES=5
export GATLING_LEVEL_MINUTES=5

mvn -f telemo-gatling/pom.xml clean compile gatling:test
```


# Holy Grail?

Reactive? Containers?
Kubernetes? On-Premises?

¯\_(ツ)_/¯

# Conclusion

5- Test your compute costs to define "normal".
4- Undertand your percentiles and detect "anomalies".
3- Beware of Database Pooling and HTTP Caching / Throttling.
2- Make it as fast as viable, but not faster.
1- Try the [Telemetry Demo](https://github.com/CaravanaCloud/telemetry-demo)!

## Gatling Results

[Local JVM](https://s3-us-west-2.amazonaws.com/faermanj.me/telemosimulation_local_jvm_c52xlarge_20210607010245004/index.html)
[Local Native](https://s3-us-west-2.amazonaws.com/faermanj.me/telemosimulation_local_native_c52xlarge_20210607084658441/index.html)
[Elastic Beanstalk](https://s3-us-west-2.amazonaws.com/faermanj.me/telemosimulation_eb_20210605185313815/index.html)


Thank you! <3

Julio @faermanj
faermanj.me/ama
