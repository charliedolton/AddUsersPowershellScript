. C:\Scripts\Var_Definition.ps1

$CSVFile = $args[0]
$CSVFilePath = $ScriptsFilePath + "\" + $CSVFile
$List = Import-Csv $CSVFilePath
$UniqueUserList = $List | Select-Object FirstName,LastName,'Student ID',DOB -Unique
$UniqueCourseList = $List | Select-Object Class -Unique


#This loop creates the class groups
foreach ($line in $UniqueCourseList)
{
    $ClassGRP = $line.Class

    try {
        New-ADGroup -GroupScope Global -Name $ClassGRP -Path $OUPathForGroups
        "$Time $ClassGRP was added to Groups" | Out-File $ScriptsFilePath\groupCreation.log -Append
    } catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        "$Time Failed to create group $ClassGRP $ErrorMessage" | Out-File $ScriptsFilePath\groupCreation.log -Append
        }
}

#This loop creates the unique user accounts
foreach ($line in $UniqueUserList)
{
    $FirstName = $line.firstname
    $FirstNameLetter = $line.Firstname[0]
    $LastName = $line.lastname
    $SID = $line.'Student ID'

    $fullName = $SID + $FirstNameLetter + $LastName

    $EncPass = (ConvertTo-SecureString -AsPlainText $line.DOB -Force)

    $HomeDirectoryLocation = $HomeDirectory + $fullName

    if (!(Test-Path -Path $HomeDirectoryLocation)) {
        New-Item -ItemType Directory -Path $HomeDirectory -Name $fullName
        "$Time Home directory created for $fullName" | Out-File $ScriptsFilePath\userCreation.log -Append
    } else {
        "$Time Home directory for $fullName already exists" | Out-File $ScriptsFilePath\userCreation.log -Append
        }
   
    $HomeDirectoryLocation = $HomeDirectory + $fullName
    
    try {
        New-ADUser -Name $fullName -GivenName $FirstName -Surname $LastName -Path $OUPathForAccounts -AccountPassword $EncPass -HomeDirectory $HomeDirectoryLocation -PostalCode 0
        Set-ADUser -Identity $fullName
        "$Time User $fullName was created successfully." | Out-File $ScriptsFilePath\userCreation.log -Append
    } catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        "$Time Failed to create user $fullName $ErrorMessage" | Out-File $ScriptsFilePath\userCreation.log -Append
    }
}

#loop to add and remove students from class groups
foreach ($line in $List)
{

    $FirstName = $line.firstname
    $FirstNameLetter = $line.Firstname[0]
    $LastName = $line.lastname
    $SID = $line.'Student ID'

    $fullName = $SID + $FirstNameLetter + $LastName

    $class = $line.Class
    $status = $line.Status
    $currentUserClasses = Get-ADPrincipalGroupMembership -Identity $fullName | select name
    $checkClass = "*"+$class+"*"
    
    if ($currentUserClasses -like $checkClass)
    {
        "$Time $fullName already enrolled in $class" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        continue
    }

    if ($status -eq "R" -or $status -eq "A")
    {   
        try {
            $currentUser = Get-ADUser -Identity $fullName -Properties postalCode
            $currentGroup = Get-ADGroup -Identity $class
            Add-ADGroupMember -Identity $currentGroup -Members $currentUser -Confirm:$false
            "$Time $fullName added to $class" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            "$Time Problem adding $fullName to $class $ErrorMessage" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        }

        try {
            $currentCount = $currentUser.postalCode
            $currentCountInt = [int]$currentCount
            $newCount = $currentCountInt + 1
            Set-ADUser -Identity $fullName -PostalCode $newCount
            "$Time $fullName class count incremented" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            "$Time Problem incrementing class count of $fullName $ErrorMessage" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        }
    }
    elseif ($status -eq "X" -or $status -eq "D")
    {
        try {
            $currentUser = Get-ADUser -Identity $fullName -Properties postalCode
            $currentGroup = Get-ADGroup -Identity $class
            Remove-ADGroupMember -Identity $currentGroup -Members $currentUser -Confirm:$false
            "$Time $fullName removed from $class" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            "$Time Problem deleting $fullName from $class $ErrorMessage" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        }
        try {
            $currentCount = $currentUser.postalCode
            $currentCountInt = [int]$currentCount
            $newCount = $currentCountInt - 1
            Set-ADUser -Identity $fullName -PostalCode $newCount
            "$Time $fullName class count decremented" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            "$Time Problem decrementing class count of $fullName $ErrorMessage" | Out-File $ScriptsFilePath\groupAssignment.log -Append
        }
    }
}

#final loop to remove users with 0 classes
foreach ($line in $UniqueUserList)
{

    $FirstName = $line.firstname
    $FirstNameLetter = $line.Firstname[0]
    $LastName = $line.lastname
    $SID = $line.'Student ID'

    $fullName = $SID + $FirstNameLetter + $LastName
     
    $currentUser = Get-ADUser -Identity $fullName -Properties postalCode

    $classCount = $currentUser.postalCode
    $classCountInt = [int]$ClassCount

    $HomeDirectoryLocation = $HomeDirectory + $fullName

    if ($classCountInt -le 0)
    {
        try {
            Remove-ADUser -Identity $fullName -Confirm:$false
            Remove-Item -Recurse -Path $HomeDirectoryLocation -Confirm:$false
            "$Time $fullName successfully deleted" | Out-File $ScriptsFilePath\userDeletion.log -Append
        } catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            "$Time  $ErrorMessage" | Out-File $ScriptsFilePath\userDeletion.log -Append
        }
    }

}
