# Name: 
#
#Modify the variables according to your system. Do not Add or remove any of the variables
#
#Set a variable for the location of the CSV file. For example, if CSV file
#is located in C:\PowerShell
$ScriptsFilePath = "C:\Scripts"
#
#Set a variable for the CSV file name. 
$csvFileName = 'SmallSample.csv'
#
#Set a variable for the OU where user accounts will be stored
#For example, "OU=Student Accounts,OU=MyExampleUniversity,DC=MyDomainExample,DC=local"
$OUPathForAccounts = "OU=Student Accounts,OU=IoT University,DC=CharlieDolton,DC=local"
#
#Set a variable for the OU where user Groups will be stored
#For example, "OU=Course Groups,OU=MyExampleUniversity,DC=CST412Project,DC=local"
$OUPathForGroups = "OU=Course Groups,OU=IoT University,DC=CharlieDolton,DC=local"
#
#Set a variable to the location of users home directory
$HomeDirectory = "\\server2019-1\sysvol\CharlieDolton.local\StudentsHomeDir\"
#
#Set a variable for your server name
$ServerName = "Server2019-1"
#
#Set a variable for the shared folder name
$FolderShare = "StudentsHomeDir"
#
#Set a variable for the domain Name
$DomainName = "CharlieDolton.local"
# 

