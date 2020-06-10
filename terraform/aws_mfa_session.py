#!/usr/bin/python3
import subprocess
import json
import configparser
from pathlib import Path

def main():
    # arn:aws:iam::628225207189:mfa/peter
    prYellow("MFA serial number (e.g. arn:aws:iam::12344566777890:mfa/iamusername):")
    mfa_serial_number = input("")

    prYellow("MFA token:")
    mfa_token = input("")

    credentials = get_aws_creds(mfa_serial_number, mfa_token)

    if credentials:
        set_aws_session_creds(credentials)



# Set proper variables to config.
def set_aws_session_creds(credentials: dict):
    home = str(Path.home())
    aws_credentials_path = f"{home}/.aws/credentials"
    config = configparser.ConfigParser()
    config.read(aws_credentials_path)

    config["session"] = {}
    config["session"]["aws_access_key_id"] = credentials['AccessKeyId']
    config["session"]["aws_secret_access_key"] = credentials['SecretAccessKey']
    config["session"]["aws_session_token"] = credentials['SessionToken']
    with open(aws_credentials_path, 'w') as configfile:
        config.write(configfile)
        prGreen("Credentials are written. Let's proceed")

# Return aws Credentials object or False.
# Use the "personal" profile with Access Key ID and Secret Access Key stored.
def get_aws_creds(mfa_serial_number: str, mfa_token: str):

    command = f"export AWS_PROFILE=personal;aws sts get-session-token --serial-number {mfa_serial_number} --token-code {mfa_token}"

    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if result.stdout is None:
        prRed("Something happened")
        prRed(result.stderr)
        return False
    else:
        # Example:
        # {'Credentials': {'AccessKeyId': 'ASIAZERJD5OK4GZONOPS', 'SecretAccessKey': 'hW7qNXucxk0jiCXxf8GRL6wYLjSr4+4EK1z4gu22', 'SessionToken': 'FQoGZXIvYXdzEGUaDIZHAAdITSSbjoGqzyKwAQlacQ38P9e+JKVB/+EahcqF6usf3kPcNkwzEY05WWJuRPl11uBq4JF0K/RRM/qCqUdr9TgLeh+FChXDzK7DeQbOAksYEN+TX4OF6XxPS/kQdMEUOJSHqjnUUI0EdU082WNKnpZl+VXvaVMmSMUiyNRjcz2mySn0C/BPN4TUsdhfPXjASo+iYHMSr79oRMpm1Ttg7yGWQnNNcdZ9Gaw05MClGD7xKPEv0XlMxN474UXUKI3Y7+sF', 'Expiration': '2019-09-14T07:20:45Z'}}
        aws_creds = json.loads(result.stdout)
        return aws_creds["Credentials"]

def prRed(skk): print("\033[00;31m {}\033[00m" .format(skk)) 
def prGreen(skk): print("\033[00;32m {}\033[00m" .format(skk)) 
def prYellow(skk): print("\033[00;33m {}\033[00m" .format(skk)) 

if __name__ == "__main__":
    main()
