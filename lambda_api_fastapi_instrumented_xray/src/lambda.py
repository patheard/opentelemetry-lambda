"""
Main API handler that defines all routes.
"""

import boto3
import os

from fastapi import FastAPI
from mangum import Mangum

from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.sdk.resources import Resource
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import BatchSpanProcessor




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

trace.set_tracer_provider(TracerProvider(resource=Resource.create({"service.name": "open-telemetry-test"})))
span_processor = BatchSpanProcessor(
    OTLPSpanExporter(endpoint="http://localhost:4317")
)
trace.get_tracer_provider().add_span_processor(span_processor)

FastAPIInstrumentor.instrument_app(app)
# Mangum allows us to use Lambdas to process requests
handler = Mangum(app=app)
