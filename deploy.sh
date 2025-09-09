#!/bin/bash

# Ultimate Onboarding Automation Deployment Script

echo "🚀 Starting Ultimate Onboarding Automation Deployment..."

# Account IDs
ACCOUNT_A="762233731285"
ACCOUNT_B="329599656204"
REGION="us-west-2"

# Deploy Account B cross-account role first
echo "📋 Step 1: Deploying cross-account role in Account B..."
echo "⚠️  Please configure AWS credentials for Account B before running this script"
echo "    aws configure --profile account-b"
echo "    or set environment variables:"
echo "    export AWS_ACCESS_KEY_ID=your_account_b_access_key"
echo "    export AWS_SECRET_ACCESS_KEY=your_account_b_secret_key"
echo "    export AWS_DEFAULT_REGION=$REGION"

aws cloudformation deploy \
  --template-file account-b-cross-account-role.yaml \
  --stack-name ultimate-onboarding-account-b-role \
  --parameter-overrides AccountAId=$ACCOUNT_A \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Account B cross-account role deployed successfully"
else
    echo "❌ Failed to deploy Account B role"
    exit 1
fi

# Switch to Account A credentials
echo "📋 Step 2: Deploying main automation stack in Account A..."
echo "⚠️  Please configure AWS credentials for Account A before running this script"

aws cloudformation deploy \
  --template-file ultimate-onboarding-stack.yaml \
  --stack-name ultimate-onboarding-automation \
  --parameter-overrides AccountBId=$ACCOUNT_B \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Ultimate onboarding automation deployed successfully"
else
    echo "❌ Failed to deploy main automation stack"
    exit 1
fi

echo "🎉 Ultimate Onboarding Automation Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Upload a CSV file to: d-stack-onboarding-client-automation-bkt"
echo "2. The complete workflow chain will automatically trigger:"
echo "   - First Workflow: CSV processing → DynamoDB entry"
echo "   - Second Workflow: Account A & B infrastructure setup"
echo "   - Third Workflow: Identity Center & Transfer Family setup"
echo ""
echo "🔗 Monitor executions in Step Functions console:"
echo "   - First: ultimate-first-workflow"
echo "   - Second: ultimate-second-workflow" 
echo "   - Third: ultimate-third-workflow"
