resource "aws_sqs_queue" "my_queue" {
  name                      = "my-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "my_queue_dlq" {
  name                      = "my-queue-dlq"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
}

resource "aws_sqs_queue_policy" "my_queue_policy" {
  queue_url = aws_sqs_queue.my_queue.url

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "my_queue_policy",
  "Statement": [
    {
      "Sid": "AllowAll",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": "${aws_sqs_queue.my_queue.arn}"
    },
    {
      "Sid": "AllowDeadLetterQueue",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": "${aws_sqs_queue.my_queue_dlq.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.my_queue.arn}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_sqs_queue_dead_letter_source" "my_queue_dlq_source" {
  queue_url = aws_sqs_queue.my_queue_dlq.url
  arn       = aws_sqs_queue.my_queue.arn
  max_receive_count = 5
}
