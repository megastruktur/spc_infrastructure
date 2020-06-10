#!/bin/bash

# Variables
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
RESTORE_FORMAT='\033[0m'
CONTINUE=""

# Env variables
# export TF_LOG=DEBUG
export TF_LOG=
export AWS_PROFILE=session

echo "If running locally and errors occur with AWS S3, make sure credntials are set"
echo "e.g. export AWS_ACCESS_KEY_ID=... and export AWS_SECRET_ACCESS_KEY=..."
echo -e "Terraform infrastructure creation${RESTORE_FORMAT}"

### Validations
echo "Validating the requirements"
if ! which aws
then
  echo -e "${RED}Please install and configure aws-cli"
  exit 1
fi
echo -e "- AWS cli: ${GREEN}OK${RESTORE_FORMAT}"

# Check whether AWS token not expired and provide a new one if so.
aws s3 ls > /dev/null 2>&1
until [[ $? -eq 0 ]]
do
  # If access denied - force to gen a new session token.
  echo -e "${RED}AWS Access Denied${RESTORE_FORMAT}"

  while [[ "$CONTINUE" != "y" && "$CONTINUE" != "n" ]]
  do
    echo -e "${YELLOW}Will generate new session access key for AWS. Continue y/n?${RESTORE_FORMAT}"
    read CONTINUE
  done

  if [ "$CONTINUE" == "y" ]
  then
    python3 ./aws_mfa_session.py
  else
    echo -e "${RED}Aborting.${RESTORE_FORMAT}"
    exit 1
  fi
  # Execute command again for "until" to catch $?
  aws s3 ls > /dev/null 2>&1
done

echo -e "- AWS access: ${GREEN}OK${RESTORE_FORMAT}"
echo $*
# Main
if [ "$1" == "" ]
then
  echo "Usage:"
  echo "To see current status use ./run.sh show"
  echo ""
  echo "To update confguration use:"
  echo "./run.sh init"
  echo "./run.sh plan"
  echo "./run.sh apply"
else
  if [ "$1" == "show" ]
  then
    terraform $*
  else
    # We need to pass action as a 1-st option and all other options should go after the command.
    terraform $1 -var-file=global.tfvars ${@:2}
  fi
fi
