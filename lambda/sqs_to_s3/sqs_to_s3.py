import json
import boto3
import os

s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')
bucket = os.environ['S3_BUCKET']
queue_url = os.environ['QUEUE_URL']

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            s3_response = s3_client.put_object(
                Body=json.dumps(record),
                Bucket=bucket,
                Key=record['messageId']
            )
        except Exception as e:
            print(e)
        try:
            sqs_response = sqs_client.delete_message(
                QueueUrl=queue_url,
                ReceiptHandle=record['receiptHandle']
            )
        except Exception as e:
            print(e)
    print(s3_response, sqs_response)
    return
