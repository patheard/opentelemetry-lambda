#! /usr/bin/python3

import boto3
import json
import os

def handler(event, context):
    client = boto3.client("s3")
    client.list_buckets()
    
    client = boto3.client("ec2")
    client.describe_instances()

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "Region ": os.environ['AWS_REGION']
        })
    }