#!/bin/bash

# Test Ultimate Onboarding Automation

echo "🧪 Testing Ultimate Onboarding Automation..."

BUCKET_NAME="d-stack-onboarding-client-automation-bkt"
TEST_FILE="test-company.csv"
REGION="us-west-2"

# Upload test CSV file to trigger automation
echo "📤 Uploading test CSV file to trigger automation..."
aws s3 cp $TEST_FILE s3://$BUCKET_NAME/$TEST_FILE --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ Test file uploaded successfully"
    echo "🔄 Automation should start within seconds..."
    echo ""
    echo "🔗 Monitor progress:"
    echo "   First Workflow: https://$REGION.console.aws.amazon.com/states/home?region=$REGION#/statemachines/view/arn:aws:states:$REGION:762233731285:stateMachine:ultimate-first-workflow"
    echo "   Second Workflow: https://$REGION.console.aws.amazon.com/states/home?region=$REGION#/statemachines/view/arn:aws:states:$REGION:762233731285:stateMachine:ultimate-second-workflow"
    echo "   Third Workflow: https://$REGION.console.aws.amazon.com/states/home?region=$REGION#/statemachines/view/arn:aws:states:$REGION:762233731285:stateMachine:ultimate-third-workflow"
else
    echo "❌ Failed to upload test file"
    exit 1
fi
