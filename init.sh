#!/usr/bin/env bash

INPUT_QUEUE_NAME="input-queue"
RESULT_TOPIC_NAME="result-topic"
RESULT_QUEUE_NAME="result-queue"
RESULT_BUCKET_NAME="result-bucket"

RESULT_TOPIC_ARN=$(aws --endpoint-url=http://localhost:4575 sns create-topic --name ${RESULT_TOPIC_NAME} | jq .TopicArn)
INPUT_QUEUE_URL=$(aws --endpoint-url=http://localhost:4576 sqs create-queue --queue-name ${INPUT_QUEUE_NAME} | jq .QueueUrl)
RESULT_QUEUE_URL=$(aws --endpoint-url=http://localhost:4576 sqs create-queue --queue-name ${RESULT_QUEUE_NAME} | jq .QueueUrl)

GET_RESULT_QUEUE_ARN_COMMAND="aws --endpoint-url=http://localhost:4576 sqs get-queue-attributes --queue-url ${RESULT_QUEUE_URL} --attribute-names QueueArn | jq .Attributes.QueueArn"
echo ${GET_RESULT_QUEUE_ARN_COMMAND} && RESULT_QUEUE_ARN=$(eval ${GET_RESULT_QUEUE_ARN_COMMAND})

SUBSCRIBE_COMMAND="aws --endpoint-url=http://localhost:4575 sns subscribe --topic-arn ${RESULT_TOPIC_ARN} --protocol sqs --notification-endpoint ${RESULT_QUEUE_ARN} | jq .SubscriptionArn"
echo ${SUBSCRIBE_COMMAND} && eval ${SUBSCRIBE_COMMAND}

CREATE_BUCKET_COMMAND="aws --endpoint-url=http://localhost:4572 s3api create-bucket --bucket ${RESULT_BUCKET_NAME}"
echo ${CREATE_BUCKET_COMMAND} && eval ${CREATE_BUCKET_COMMAND}

echo "Input queue: ${INPUT_QUEUE_NAME}"
echo "Result queue: ${RESULT_QUEUE_NAME}"
echo "Topic ARN: ${RESULT_TOPIC_ARN}"
echo "Bucket: ${RESULT_BUCKET_NAME}"
