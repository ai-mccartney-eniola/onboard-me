# Ultimate Onboarding Automation

Complete end-to-end client onboarding automation using AWS Step Functions, EventBridge, and cross-account operations.

## Architecture Overview

```
S3 Upload (CSV) → EventBridge → First Workflow → DynamoDB → Second Workflow → Third Workflow
     ↓              ↓              ↓               ↓            ↓              ↓
CSV Processing → Event Rule → User Creation → Stream Trigger → Infrastructure → Identity Setup
```

## Workflow Chain

### 1. **First Workflow** (ultimate-te-first-workflow)
- **Trigger**: S3 PUT event via EventBridge
- **Actions**: 
  - Extract company info from CSV filename
  - Parse CSV content for user details
  - Create DynamoDB entry
- **Output**: Triggers DynamoDB stream

### 2. **Second Workflow** (ultimate-te-second-workflow)  
- **Trigger**: DynamoDB stream from First Workflow
- **Actions**:
  - Parse DynamoDB stream event
  - Create Account A S3 bucket with versioning
  - Create Account B S3 bucket (cross-account)
  - Trigger Third Workflow
- **Output**: Infrastructure ready

### 3. **Third Workflow** (ultimate-te-third-workflow)
- **Trigger**: Lambda call from Second Workflow
- **Actions**:
  - Setup IAM Identity Center groups
  - Configure Transfer Family access
  - Complete onboarding process
- **Output**: Client ready for access

## Files Structure

```
ultimate-onboarding-automation/
├── ultimate-onboarding-stack.yaml    # Main CloudFormation template
├── account-b-cross-account-role.yaml # Account B role template
├── deploy.sh                         # Deployment script
├── test-automation.sh               # Test script
├── test-company.csv                 # Sample CSV file
└── README.md                        # This file
```

## Deployment Instructions

### Prerequisites
- AWS CLI configured for both accounts
- Account A: 762233731285 (primary)
- Account B: 329599656204 (secondary)
- DynamoDB table: `user_sftp_table_center` with streams enabled

### Step 1: Deploy
```bash
chmod +x deploy.sh
./deploy.sh
```

### Step 2: Test
```bash
chmod +x test-automation.sh
./test-automation.sh
```

## Key Components

### S3 Bucket
- **Name**: `d-stack-te-onboarding-client-automation-bkt`
- **EventBridge**: Enabled for PUT events
- **Trigger**: CSV files with `.csv` suffix

### EventBridge Rule
- **Source**: `aws.s3`
- **Event Type**: `Object Created`
- **Filter**: `.csv` files only
- **Target**: First Workflow Step Function

### Cross-Account Setup
- **Account A**: Main automation and workflows
- **Account B**: Target infrastructure and Identity Center
- **Role**: `CrossAccountBucketCreationTeRole` in Account B

### Lambda Functions
- `extract-te-company-info`: Parse CSV and extract company details
- `parse-dynamodb-event-te-ultimate`: Process DynamoDB stream events
- `create-cross-account-bucket-te-ultimate`: Create buckets in Account B
- `trigger-*-workflow-te-ultimate`: Chain workflow executions

## Monitoring

### Step Functions Console URLs
- **First**: `https://us-west-2.console.aws.amazon.com/states/home?region=us-west-2#/statemachines`
- **Second**: Same console, look for `ultimate-te-second-workflow`
- **Third**: Same console, look for `ultimate-te-third-workflow`

### CloudWatch Logs
- All Lambda functions log to CloudWatch
- Step Function execution history available in console

## Testing

### Manual Test
1. Upload any `.csv` file to `d-stack-te-onboarding-client-automation-bkt`
2. Filename becomes company name (e.g., `acme-corp.csv` → company: `acme-corp`)
3. Monitor Step Functions executions

### Expected Results
- ✅ Account A bucket: `mnt-prod-te-d-stack-client-{company}`
- ✅ Account B bucket: `prod-te-d-stack-client-{company}`
- ✅ DynamoDB entry with user details
- ✅ Identity Center group setup (demo)
- ✅ Transfer Family configuration (demo)

## Troubleshooting

### Common Issues
1. **Cross-account role not found**: Ensure Account B role is deployed first
2. **DynamoDB stream not triggering**: Check stream is enabled on table
3. **EventBridge not triggering**: Verify S3 EventBridge configuration

### Debug Steps
1. Check CloudWatch logs for Lambda functions
2. Review Step Function execution details
3. Verify IAM permissions for cross-account access

## Security Notes

- All cross-account operations use IAM roles with minimal permissions
- S3 buckets have public access blocked by default
- Lambda functions use least-privilege IAM policies
- EventBridge rules are scoped to specific S3 events only

## Customization

### Adding New Steps
1. Modify the Step Function ASL in CloudFormation template
2. Add new Lambda functions as needed
3. Update IAM policies for new permissions
4. Redeploy using `deploy.sh`

### Changing Accounts
1. Update account IDs in `deploy.sh`
2. Modify CloudFormation parameters
3. Ensure cross-account trust relationships

This automation provides a complete, production-ready client onboarding solution with proper error handling, monitoring, and security controls.
# onboard-me
