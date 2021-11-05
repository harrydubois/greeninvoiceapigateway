# Green Invoice Devops Task

An API Gateway that invokes a lambda functions to store the event in an encrypted SQS message queue, and then from the SQS queue to an encrypted S3 bucket.

Backend configuration is in `main.tf` -
Credentials are (against best practice, and simply for the purpose of this exercise) set in `variables.tf`, along with the custom domain name to use for the API Gateway and several other variables.

Had a blast doing this - one thing I would change if time permitted is allowing the use of an already ACM-enabled, validated domain for the API gateway, and maybe even use modules for a change.

Also I would sleep more.
