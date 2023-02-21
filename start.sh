#!/usr/bin/env sh

_catch() {
    echo "Killing process..."
    [ -z $(jobs -p) ] || kill $(jobs -p)
    exit #$
}

trap _catch INT TERM

if [ ! -e /var/run/docker.sock ]; then
    echo "You must mount the host docker socket as a volume to /var/run/docker.sock"
    exit 1
fi;

if [ -z "$AwsAccessKey" ]; then
    echo "You must set AwsAccessKey"
    exit 1
fi

if [ -z "$AwsSecretKey" ]; then
    echo "You must set AwsSecretKey"
    exit 1
fi

if [ -z "$AwsRegion" ]; then
    echo "You must set AwsRegion"
    exit 1
fi

if [ -z "$AwsAccountId" ]; then
    echo "You must set AwsAccountId"
    exit 1
fi

aws configure set aws_access_key_id $AwsAccessKey
aws configure set aws_secret_access_key $AwsSecretKey
aws configure set default.region $AwsRegion

while true; do
    aws ecr get-login-password --region $AwsRegion | docker login --username AWS --password-stdin $AwsAccountId.dkr.ecr.$AwsRegion.amazonaws.com
    services=$(docker service ls --format "{{.Name}} {{.Image}}" | grep "dkr.ecr" | awk '{print $1;}')
    for service in ${services}; do
        docker service update --with-registry-auth --detach=true "$service"
    done;

    sleep 6h &
    wait
done;