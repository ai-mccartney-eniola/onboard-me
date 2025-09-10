import json
import boto3

def lambda_handler(event, context):
    # Assume cross-account role and create bucket
    sts_client = boto3.client('sts')
    
    role_arn = f"arn:aws:iam::{event['targetAccount']}:role/CrossAccountBucketCreationTeRole"
    
    assumed_role = sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName='CreateBucketSession',
        ExternalId='ultimate-te-onboarding-automation'
    )
    
    credentials = assumed_role['Credentials']
    s3_client = boto3.client(
        's3',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'],
        region_name=event['region']
    )
    
    # Create bucket in Account B
    bucket_name = event['bucketName']
    
    try:
        s3_client.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={'LocationConstraint': event['region']}
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Bucket {bucket_name} created successfully in Account B')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error creating bucket: {str(e)}')
        }
