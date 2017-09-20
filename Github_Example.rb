require 'aws-sdk'
require 'json'
require 'rest-client'

#current CloudHealth API restricts
 j = RestClient.get 'https://chapi.cloudhealthtech.com/v1/aws_accounts?api_key=API_KEY&page=1&per_page=100'
 j2 = RestClient.get 'https://chapi.cloudhealthtech.com/v1/aws_accounts?api_key=API_KEY&page=2&per_page=100'
#  Enterprise API IMPLEMENTATION (AWS ACCOUNT API)
 kens_api = RestClient.get("https://AWS ACCOUNT API")
 k_api_hash = JSON.parse(kens_api)
 aws_account_size = k_api_hash["awsaccounts"].size
 aws_account_array = []
i = 0
while i < aws_account_size
  if  k_api_hash['awsaccounts'][i]['accountnumber'] == "361551674057"  #Because of special Enterprise requirement exception
    puts "361551674057 account is being skipped over" 
    i += 1
  else
    aws_account_array.push(k_api_hash['awsaccounts'][i]['accountnumber'])
    i += 1
  end
end
puts "Here are all the aws accounts excluding prod account 361551674057"
puts aws_account_array.inspect
 #CHANGE the location of the file location
 file = File.read('C:\Users\v2.json')
 my_hash = JSON.parse(j)
 my_hash2 = JSON.parse(j2)
 my_hash4 = JSON.parse(file)
 cloudtrail_size2 = my_hash4["Statement"][1]["Resource"]
#Getting all the CloudHealth Accounts with status of Yellow 
 account_number_array = Array.new
 my_hash["aws_accounts"].each do |account|
  if account["status"]["level"] == "yellow"
    account_number_array << account["owner_id"]
  end
end
my_hash2["aws_accounts"].each do |account|
  if account["status"]["level"] == "yellow"
    account_number_array << account["owner_id"]
  end
end
puts "Here are the accounts that have an warning(status = yellow) from cloudhealth"
puts
puts account_number_array.inspect
puts
# COMPARING SO THAT ONLY RH AWS ACCOUNTS ARE USED
puts "Comparing aws_account_array(Ken's API) with account_number_array(CloudHealth_API) then processing the data and replacing the data from account_number_array"
puts
account_number_array = account_number_array & aws_account_array
puts "Here is the new processed array of accounts that are going to be processed with status = yellow and belong to RH"
puts
puts account_number_array.inspect

#READING CONFIG FILE SO THAT ONLY ACCOUNT NUMBERS IN YOUR CONFIG FILE ARE PROCESSED

config_array = [] #Array that will contain only account numbers that are in your config file
not_config_array = [] #Array that will only contain account numbers not in the config file

account_number_array.each do |awsid|
if File.read('C:\Users\kougav01\.aws\config').include?("#{awsid}")  # change the location of the config file to your system's
    config_array.push("#{awsid}")
else
    not_config_array.push("#{awsid}")
end
end

puts "HERE are the accounts that are in your config file"
puts config_array.inspect
puts "HERE are the accounts that are not in your config file and will not be taken in account"
puts not_config_array.inspect
account_number_array = config_array
puts account_number_array.inspect
#This is to edit the cloudtrail
account_number_array.each do |awsid|
j4 = `aws cloudtrail describe-trails --profile #{awsid}`
j5 = `aws iam list-policy-versions --policy-arn arn:aws:iam::#{awsid}:policy/cloudhealth-access-policy --profile #{awsid}`

version_hash = JSON.parse(j5)
my_hash5 = JSON.parse(j4)
cloud_trail_name = []
version_size = version_hash["Versions"].size.to_i
puts version_size
# case version_size
if version_size == 5  #TO SEE IF VERSION POLICY SUPPOSED TO BE DELETED or NOT
  puts "There are 5 versions, deleting second newest version"
  #For Deleting AN POLICY VERSION 
  delete_version_array = []
  delete_version_array.push(version_hash["Versions"][1]["VersionId"])
  `aws iam delete-policy-version --policy-arn arn:aws:iam::#{awsid}:policy/cloudhealth-access-policy --version-id #{delete_version_array[0]} --profile #{awsid}`
  delete_version_array.pop #to empty the array for the next account
else
  puts "Four or less versions avaliable, going to continue to edit cloudtrail injection and upload the new policy version"
end
# CloudTrail Injection
cloudtrail_size2.pop
cloudtrail_size2.pop
cloud_trail_name.push(my_hash5["trailList"][0]["S3BucketName"]) #TAKING THE S3BUCKETNAME ATTRIBUTE OF CLOUDTRAIL
cloudtrail_size2.push("arn:aws:s3:::#{cloud_trail_name[0]}")
cloudtrail_size2.push("arn:aws:s3:::#{cloud_trail_name[0]}/*")
puts "The CloudTrail Injections are"
puts 
puts cloudtrail_size2
puts
puts JSON.pretty_generate(my_hash4)


# Writing to the v2.json file
File.open('C:\Users\kougav01\Desktop\GitCH\CloudHealthWarningFix\v2.json', 'w') do |f|  #Change the location of the file
  f.write(my_hash4.to_json)
end
#CHANGE the location of the file location
`aws iam create-policy-version --policy-arn arn:aws:iam::#{awsid}:policy/cloudhealth-access-policy --policy-document  file:///v2.json --set-as-default --profile #{awsid}`
#EMPTY the cloud_trail_name, for next aws account insertion
puts "Successful insertion of new policy for account number #{awsid}"
end