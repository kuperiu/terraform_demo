# ops_solution
Dependencies:
1. Terraform v0.11.8
2. Please export the aws credintials to environment variables, using the following commands
        export AWS_ACCESS_KEY_ID=""
        export AWS_SECRET_ACCESS_KEY=""
        export AWS_DEFAULT_REGION=""
3. This module depend on a default vpc, please make sure it exist in your region and put the id of the vpc in the var file
4. change the key to your own key in the var file and make sure it exist in every region that you want to use
5. run terraform init to load the modules