# Documentation :memo: #
## Objective: ##
> Create an automation script that will fix the cloudhealth status for an ENTERPRISE AWS Accounts from warning to healthy by updating the policies for every AWS account that has an status of “warning”. Used AWS Accounts API, CloudHealth Accounts API, and AWS CLI, it was written in ruby.
## The program should update the policy in AWS accordingly, such that updating a new version of the policy by uploading a json file (v2.json). :page_facing_up: ##

## Change the location, of the following in the script ##
- location of the v2.json in your system
- location of the your config file

## Changes the user should do before running the program :bangbang: ##
- [x] **Update the location of your _config_ file** 
- [x] **Update the location of your _v2.json_ file** 

### Code to change for config file: :red_circle:
> File.read('C:\Users\kougav01\.aws\config')

### Code to change for v2.json file :red_circle:
> File.open('C:\Users\v2.json', 'w')

## The Scripts works in four phases  ##
1. Get all the accounts that have an status warning of yellow in CloudHealth
2. Get all the Enterprise AWS accounts that belong to Enterprise
3. Produce a array that contains both AWS RH with AWS CloudHealth
4. Loop through each RH AWS ACCOUNT that has an status of Yellow, but updating v2.json with the proper cloudtrail tag

![alt text](https://imgur.com/gallery/kPGXK)
