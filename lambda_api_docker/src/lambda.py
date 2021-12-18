"""
Main API handler that defines all routes.
"""

import boto3
import os
import asyncio

from fastapi import FastAPI
from mangum import Mangum

app = FastAPI(
    title="AWS + FastAPI",
    description="AWS API Gateway, Lambdas and FastAPI (oh my)",
    root_path="/dev"
)

@app.get("/hello")
def hello():
    "Hello path request"
    return {"Hello": "World"}

@app.get("/list")
def hello():
    client = boto3.client("s3")
    client.list_buckets()
    
    client = boto3.client("ec2")
    client.describe_instances()

    return {"Region ": os.environ['AWS_REGION']}  

def handler(event, context):
    asgi_handler = Mangum(app=app)
    return asgi_handler(event, context)
