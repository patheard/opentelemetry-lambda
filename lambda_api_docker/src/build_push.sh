#!/bin/bash

IMAGE=$1

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build --tag "$IMAGE" .
docker push "$IMAGE"