#!/bin/bash
apt update -y && apt -y install awscli
apt -y install openjdk-8-jre-headless
export AWS_ACCESS_KEY_ID=AKIAX5R6ABP6UUFEGNW5
export AWS_SECRET_ACCESS_KEY=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
export AWS_REGION=us-west-2
export PATH=$PATH:$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY:$AWS_REGION