# FinSetu API Tests

This directory contains Postman test files for the FinSetu backend API.

## Files

- `FinSetu_API_Tests.postman_collection.json`: Contains all API test requests and test scripts
- `FinSetu_Production.postman_environment.json`: Production environment variables

## Setup Instructions

1. Import the collection and environment files into Postman:
   - Click "Import" in Postman
   - Select both JSON files from this directory

2. Select the "FinSetu Production" environment from the environment dropdown

3. Update the environment variables if needed:
   - `baseUrl`: Your production API URL
   - `userId`: Will be automatically set after successful registration
   - `otp`: Will be automatically set after successful registration

## Test Flow

1. Run the "Register User" request first
   - This will create a new user and save the userId and OTP
   - The test script will automatically set these values in the environment

2. Run the "Verify OTP" request
   - This will use the saved userId and OTP to verify the user
   - All test assertions will run automatically

## Test Cases

### Register User
- Success case: Creates new user and returns userId and OTP
- Error cases:
  - Missing required fields
  - User already exists
  - Invalid phone number format

### Verify OTP
- Success case: Verifies OTP and marks user as verified
- Error cases:
  - Invalid OTP
  - Expired OTP
  - Invalid userId

## Running Tests

1. Individual Requests:
   - Select the request in Postman
   - Click "Send"
   - View test results in the "Test Results" tab

2. Collection Runner:
   - Click "Runner" in Postman
   - Select "FinSetu API Tests" collection
   - Select "FinSetu Production" environment
   - Click "Run FinSetu API Tests"

## Notes

- All tests are designed for production environment
- Sensitive data (userId, OTP) is stored as secret variables
- Test scripts automatically handle data flow between requests 