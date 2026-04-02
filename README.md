# Jenkins Server CI/CD with Terraform Deployments

This repository contains the Infrastructure as Code and Pipeline configurations to automatically provision an AWS S3 bucket via Jenkins and Terraform.

## Project Structure
* `Jenkinsfile`: Declarative pipeline executing Terraform `init`, `plan`, and `apply`.
* `test-bucket.tf`: Terraform configuration deploying an S3 bucket with an S3 state backend.
* `user-data.sh`: Immutable EC2 bootstrap script configuring Jenkins, Java 21, Terraform, and required plugins automatically.
* `armageddon.txt`: Link to my Armageddon project.

## Evidence
Screenshots validating the Webhook (`screenshot-webhook.png`) and successful Terraform Apply (`screenshot-tf-apply.png`) and the other evidence objects below have been uploaded to the `jenkins-gcheck-assets` bucket.


* https://jenkins-bucket-20260330225925331200000001.s3.us-east-1.amazonaws.com/Apply-complete.JPG
* https://jenkins-bucket-20260330225925331200000001.s3.us-east-1.amazonaws.com/Destroy-complete.JPG
* https://jenkins-bucket-20260330225925331200000001.s3.us-east-1.amazonaws.com/SUCCESS.JPG
* https://jenkins-bucket-20260330225925331200000001.s3.us-east-1.amazonaws.com/u6KxR-1W.jpg
* https://jenkins-bucket-20260330225925331200000001.s3.us-east-1.amazonaws.com/webhook-delivery.JPG
* https://jenkins-bucket-20260330225925331200000001.s3.us-east-1.amazonaws.com/wub8Qfph.jpg 