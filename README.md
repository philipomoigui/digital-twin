# AI Digital Twin - Complete Deployment Guide

A production-ready AI Digital Twin application deployed on AWS with full CI/CD automation. This project demonstrates end-to-end deployment of a conversational AI application using modern DevOps practices.

## 🎯 Project Overview

This Digital Twin is a conversational AI that represents you (or anyone you choose) and can interact with visitors on your behalf. It features:

- **Next.js Frontend** - Modern React application with chat interface
- **FastAPI Backend** - Python API with AWS Bedrock integration
- **AWS Infrastructure** - Serverless architecture with Lambda, API Gateway, S3, and CloudFront
- **Terraform** - Infrastructure as Code for automated deployments
- **GitHub Actions** - CI/CD pipelines for automated deployments
- **Multi-Environment Support** - Separate dev, test, and production environments

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Initial Setup](#initial-setup)
- [Local Development](#local-development)
- [AWS Setup](#aws-setup)
- [Deployment](#deployment)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [Cost Estimates](#cost-estimates)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Node.js** (v20 or later)
   - Download from [nodejs.org](https://nodejs.org/)
   - Verify: `node --version`

2. **Python** (v3.12)
   - Download from [python.org](https://www.python.org/downloads/)
   - Verify: `python --version`

3. **uv** (Python package manager)
   - **Mac/Linux**: `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - **Windows**: `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
   - Verify: `uv --version`

4. **Terraform** (v1.0 or later)
   - Download from [terraform.io](https://www.terraform.io/downloads)
   - Verify: `terraform --version`

5. **AWS CLI** (v2)
   - Download from [aws.amazon.com/cli](https://aws.amazon.com/cli/)
   - Verify: `aws --version`
   - Configure: `aws configure`

6. **Docker Desktop**
   - Required for building Lambda packages
   - Download from [docker.com](https://www.docker.com/products/docker-desktop)
   - Verify: `docker --version`

7. **Git**
   - Usually pre-installed on Mac/Linux
   - Windows: Download from [git-scm.com](https://git-scm.com/download/win)

### AWS Account Setup

1. **Create AWS Account** (if you don't have one)
   - Sign up at [aws.amazon.com](https://aws.amazon.com)
   - You'll need a credit card (but costs should stay under $5/month)

2. **Configure AWS CLI**
   ```bash
   aws configure
   ```
   - Enter your AWS Access Key ID
   - Enter your AWS Secret Access Key
   - Default region: `us-east-1` (or your preferred region)
   - Default output format: `json`

3. **Get Your AWS Account ID**
   ```bash
   aws sts get-caller-identity --query Account --output text
   ```
   Save this 12-digit number - you'll need it later.

### GitHub Account

1. **Create GitHub Account** (if needed)
   - Sign up at [github.com](https://github.com)

2. **Create Personal Access Token**
   - Go to Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `repo` scope
   - Save the token securely

## 📁 Project Structure

```
digital-twin/
├── backend/                 # FastAPI application
│   ├── server.py           # Main FastAPI server
│   ├── lambda_handler.py   # Lambda entry point
│   ├── context.py          # System prompt generation
│   ├── resources.py        # Data loading
│   ├── deploy.py           # Lambda packaging script
│   ├── requirements.txt    # Python dependencies
│   ├── data/               # Personal data files
│   │   ├── facts.json      # Personal information
│   │   ├── summary.txt     # Personal summary
│   │   ├── style.txt       # Communication style
│   │   └── linkedin.pdf    # LinkedIn profile (optional)
│   └── me.txt              # Personality description
├── frontend/                # Next.js application
│   ├── app/                # App Router structure
│   ├── components/         # React components
│   │   └── twin.tsx       # Chat interface
│   ├── public/             # Static assets
│   └── package.json        # Node dependencies
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Main infrastructure
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   ├── versions.tf        # Provider config
│   ├── backend.tf          # S3 backend config
│   └── terraform.tfvars    # Default values
├── scripts/                 # Deployment scripts
│   ├── deploy.sh           # Deploy (Mac/Linux)
│   ├── deploy.ps1          # Deploy (Windows)
│   ├── destroy.sh          # Destroy (Mac/Linux)
│   └── destroy.ps1          # Destroy (Windows)
├── .github/                # GitHub Actions
│   └── workflows/
│       ├── deploy.yml      # Deployment workflow
│       └── destroy.yml     # Destruction workflow
└── README.md               # This file
```

## 🚀 Initial Setup

### 1. Clone or Navigate to Project

If you're starting fresh:
```bash
cd digital-twin
```

### 2. Configure Personal Data

Edit the following files to personalize your Digital Twin:

**`backend/me.txt`** - Update with your name and description
```text
You are a chatbot acting as a "Digital Twin", representing [Your Name]...
```

**`backend/data/facts.json`** - Add your personal information
```json
{
  "full_name": "Your Full Name",
  "name": "Your Nickname",
  "current_role": "Your Current Role",
  ...
}
```

**`backend/data/summary.txt`** - Add your professional summary

**`backend/data/style.txt`** - Define your communication style

**Optional**: Add `backend/data/linkedin.pdf` - Export your LinkedIn profile as PDF

### 3. Set Up Frontend

```bash
cd frontend
npm install
cd ..
```

### 4. Set Up Backend

```bash
cd backend
uv init --bare
uv python pin 3.12
uv add -r requirements.txt
cd ..
```

### 5. Create Environment File

Create `.env` in the project root:
```bash
# AWS Configuration
AWS_ACCOUNT_ID=your_12_digit_account_id
DEFAULT_AWS_REGION=us-east-1

# Project Configuration
PROJECT_NAME=twin
```

Replace `your_12_digit_account_id` with your actual AWS account ID.

## 💻 Local Development

### Start Backend Locally

```bash
cd backend
uv run uvicorn server:app --reload
```

The backend will run on `http://localhost:8000`

### Start Frontend Locally

In a new terminal:
```bash
cd frontend
npm run dev
```

The frontend will run on `http://localhost:3000`

### Test Locally

1. Open `http://localhost:3000` in your browser
2. Start a conversation with your Digital Twin
3. Check `memory/` directory for conversation files

## ☁️ AWS Setup

### Step 1: Create IAM User Group

1. Sign in to AWS Console as **root user**
2. Go to **IAM** → **User groups** → **Create group**
3. Group name: `TwinAccess`
4. Attach these policies:
   - `AWSLambda_FullAccess`
   - `AmazonS3FullAccess`
   - `AmazonAPIGatewayAdministrator`
   - `CloudFrontFullAccess`
   - `IAMReadOnlyAccess`
   - `AmazonBedrockFullAccess`
   - `CloudWatchFullAccess`
   - `AmazonDynamoDBFullAccess`
5. Click **Create group**

### Step 2: Add User to Group

1. Go to **IAM** → **Users**
2. Select your IAM user (or create one)
3. Click **Add to groups**
4. Select `TwinAccess`
5. Click **Add to groups**

### Step 3: Request Bedrock Model Access

1. Sign in as your IAM user
2. Go to **Bedrock** in AWS Console
3. Click **Model access** (left sidebar)
4. Click **Manage model access**
5. Find **Amazon** section
6. Check:
   - ✅ Nova Micro
   - ✅ Nova Lite
   - ✅ Nova Pro
7. Click **Request model access**
8. Wait for access to be granted (usually immediate)

**Note**: You may need to change the AWS region (top right) to `us-east-1` or `us-west-2` to see these models.

### Step 4: Set Up Terraform Backend

The first time you deploy, you need to create the S3 bucket and DynamoDB table for Terraform state:

```bash
cd terraform

# Create backend-setup.tf (temporary file)
cat > backend-setup.tf << 'EOF'
resource "aws_s3_bucket" "terraform_state" {
  bucket = "twin-terraform-state-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "Terraform State Store"
    Environment = "global"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "twin-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "Terraform State Locks"
    Environment = "global"
    ManagedBy   = "terraform"
  }
}

data "aws_caller_identity" "current" {}
EOF

# Initialize and apply
terraform init
terraform apply -target=aws_s3_bucket.terraform_state \
                -target=aws_s3_bucket_versioning.terraform_state \
                -target=aws_s3_bucket_server_side_encryption_configuration.terraform_state \
                -target=aws_s3_bucket_public_access_block.terraform_state \
                -target=aws_dynamodb_table.terraform_locks

# Remove the setup file
rm backend-setup.tf
cd ..
```

## 🚢 Deployment

### Option 1: Local Deployment (Recommended for First Time)

**Mac/Linux:**
```bash
./scripts/deploy.sh dev
```

**Windows (PowerShell):**
```powershell
.\scripts\deploy.ps1 -Environment dev
```

This will:
1. Build the Lambda package
2. Deploy infrastructure with Terraform
3. Build and deploy the frontend
4. Display deployment URLs

### Option 2: GitHub Actions Deployment

#### Step 1: Create GitHub Repository

1. Go to [github.com](https://github.com)
2. Click **New repository**
3. Name: `digital-twin`
4. Choose Public or Private
5. **Don't** initialize with README
6. Click **Create repository**

#### Step 2: Push Code to GitHub

```bash
# Initialize git (if not already done)
git init -b main
git add .
git commit -m "Initial commit: Digital Twin project"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/digital-twin.git
git push -u origin main
```

#### Step 3: Set Up GitHub OIDC for AWS

Create the IAM role that GitHub Actions will use:

```bash
cd terraform

# Create github-oidc.tf (temporary file)
# See Day 5 instructions for the full file content
# This creates an IAM role for GitHub Actions

# Apply the OIDC resources
terraform apply -target=aws_iam_openid_connect_provider.github \
                -target=aws_iam_role.github_actions \
                ... (all other targets)

# Get the role ARN
terraform output github_actions_role_arn

# Remove the setup file
rm github-oidc.tf
cd ..
```

#### Step 4: Configure GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each:

   - **Name**: `AWS_ROLE_ARN`
     **Value**: The ARN from terraform output (e.g., `arn:aws:iam::123456789012:role/github-actions-twin-deploy`)

   - **Name**: `DEFAULT_AWS_REGION`
     **Value**: `us-east-1` (or your region)

   - **Name**: `AWS_ACCOUNT_ID`
     **Value**: Your 12-digit AWS account ID

#### Step 5: Deploy via GitHub Actions

1. Go to **Actions** tab in your repository
2. Click **Deploy Digital Twin**
3. Click **Run workflow**
4. Select environment: `dev`
5. Click **Run workflow**

The deployment will take 5-10 minutes. Once complete, you'll see the CloudFront URL in the workflow summary.

### Deploying to Other Environments

**Test Environment:**
```bash
./scripts/deploy.sh test  # Mac/Linux
.\scripts\deploy.ps1 -Environment test  # Windows
```

**Production Environment:**
1. Create `terraform/prod.tfvars`:
```hcl
project_name             = "twin"
environment              = "prod"
bedrock_model_id         = "amazon.nova-lite-v1:0"
lambda_timeout           = 60
api_throttle_burst_limit = 20
api_throttle_rate_limit  = 10
use_custom_domain        = false
root_domain              = ""
```

2. Deploy:
```bash
./scripts/deploy.sh prod
```

## 🏗️ Architecture

```
User Browser
    ↓ HTTPS
CloudFront (CDN)
    ↓ 
S3 Static Website (Frontend)
    ↓ HTTPS API Calls
API Gateway
    ↓
Lambda Function (Backend)
    ↓
    ├── AWS Bedrock (AI responses)
    └── S3 Memory Bucket (conversation persistence)
```

### Components

- **CloudFront**: Global CDN, provides HTTPS, caches static content
- **S3 Frontend Bucket**: Hosts static Next.js files
- **API Gateway**: Manages API routes, handles CORS
- **Lambda**: Runs Python backend serverlessly
- **Bedrock**: AWS AI service for generating responses
- **S3 Memory Bucket**: Stores conversation history as JSON files
- **Terraform**: Manages all infrastructure as code
- **GitHub Actions**: Automates deployments

## 🔍 Troubleshooting

### Common Issues

**"Connection refused" error**
- Ensure both backend and frontend are running locally
- Check ports: backend on 8000, frontend on 3000

**OpenAI/Bedrock API errors**
- Verify Bedrock model access is granted
- Check IAM permissions for Bedrock
- Ensure model ID is correct (may need `us.` or `eu.` prefix)

**CORS errors**
- Verify `CORS_ORIGINS` environment variable in Lambda
- Check API Gateway CORS configuration
- Ensure CloudFront URL matches exactly (with `https://`, no trailing `/`)

**Terraform state errors**
- Ensure S3 backend bucket exists
- Check DynamoDB table exists
- Verify AWS credentials are configured

**Lambda deployment fails**
- Ensure Docker is running
- Check Lambda package size (must be under 50MB unzipped)
- Verify all dependencies are in requirements.txt

**Frontend not updating**
- CloudFront caches content - wait 5-10 minutes or create invalidation
- Check S3 sync completed successfully
- Verify build output in `frontend/out/`

### Getting Help

1. Check CloudWatch logs for Lambda errors
2. Review GitHub Actions workflow logs
3. Verify all environment variables are set
4. Check AWS service quotas and limits

## 💰 Cost Estimates

### Monthly Costs (Approximate)

- **Lambda**: First 1M requests free, then $0.20 per 1M requests
- **API Gateway**: First 1M requests free, then $1.00 per 1M requests
- **S3**: ~$0.023 per GB stored, ~$0.0004 per 1,000 requests
- **CloudFront**: First 1TB free, then ~$0.085 per GB
- **Bedrock**: Varies by model (Nova Micro is cheapest)
- **DynamoDB**: PAY_PER_REQUEST - minimal cost when not in use

**Total**: Should stay under **$5/month** for moderate usage

### Cost Optimization Tips

1. **Destroy unused environments** - Don't leave test running
2. **Use Nova Micro for dev/test** - Cheapest model
3. **Set API throttling** - Prevent runaway costs
4. **Monitor with CloudWatch** - Set up billing alerts
5. **Clean old S3 files** - Delete old conversation logs periodically

## 🧹 Cleanup

### Destroy an Environment

**Mac/Linux:**
```bash
./scripts/destroy.sh dev
```

**Windows:**
```powershell
.\scripts\destroy.ps1 -Environment dev
```

**Via GitHub Actions:**
1. Go to **Actions** → **Destroy Environment**
2. Run workflow with environment name
3. Type environment name to confirm

### Complete Cleanup

To remove everything (including Terraform state):

```bash
# Destroy all environments first
./scripts/destroy.sh dev
./scripts/destroy.sh test
./scripts/destroy.sh prod

# Then manually delete:
# - S3 state bucket: twin-terraform-state-*
# - DynamoDB table: twin-terraform-locks
# - IAM role: github-actions-twin-deploy
```

## 📚 Next Steps

### Enhancements You Can Add

1. **Custom Domain**: Add your own domain with SSL
2. **User Authentication**: Add login/signup
3. **Analytics**: Track conversation metrics
4. **Multiple Personalities**: Support multiple twin personas
5. **Voice Interface**: Add speech-to-text
6. **Testing**: Add unit and integration tests
7. **Monitoring**: Set up CloudWatch dashboards and alerts

### Learning Resources

- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Next.js Documentation](https://nextjs.org/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

## 📝 License

This project is part of the "AI in Production" course. Feel free to use and modify for your own projects.

## 🙏 Acknowledgments

Built as part of Week 2 of the "AI in Production" course, demonstrating professional DevOps practices for AI applications.

---

**Happy Deploying! 🚀**

If you encounter issues, check the troubleshooting section or review the course materials for detailed explanations.

