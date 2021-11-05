import boto3
import json
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['QUEUE_URL']

def lambda_handler(event, context):
    responseMessage = ''
    statusCode = 500
    try:
        response = sqs.send_message(
            QueueUrl=QUEUE_URL,
            DelaySeconds=10,
            MessageBody=json.dumps(event)
        )
        statusCode = 200
        responseMessage = 'Message processed. Message ID: ' + response['MessageId']
    except Exception as e:
        statusCode = 500
        responseMessage = 'An error has occurred, we are looking into it.'
        print(e)
    return {
        'statusCode': statusCode,
        'body': json.dumps({
            'message': responseMessage,
        })
    }