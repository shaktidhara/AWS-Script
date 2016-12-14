
$InstanceIDs = 'i-1cd43df8', 'i-c5ebd07c', 'i-bd5f9236', 'i-47be0ecc','i-d19aff69'
#$InstanceIDs = 'i-62a767db'



Function VolumeSizeValidation ($VolumesSize, $Platform, $InstanceID)
{
#$VolumeId = $volumes.ebs.VolumeId
#$VolumesSize = (Get-EC2Volume -VolumeId $VolumeId -Region eu-west-1).Size

    if ($Platform -eq "Linux" -or [System.String]::IsNullOrEmpty($Platform))
    {
        if ($VolumesSize -ge 60 )
        {
        Write-Host "The $InstanceID Instance have Valid ebs volume , size is $VolumesSize" -f Green
        }
        else {Write-Host  "The $InstanceID instance size is not valid, iit is less than equal to 60 GB" -f red }
    }

    if ($Platform -eq "Windows")
    {
        if ($VolumesSize -ge 80 )
        {
        Write-Host "The $InstanceID Instance have Valid ebs volume , size is $VolumesSize" -f Green
        }
        else {Write-Host  "The $InstanceID instance size is not valid, it is less than equal to  80 GB" -f red }
    }

   <# if ([System.String]::IsNullOrEmpty($Platform))
    {
       Write-Host "The $InstanceID Instance have InValid ebs Platform" -f Red
    }#>

}


Function CheckInvalidMailAddress ($Mailaddress)
{
    $Val1=$Mailaddress.EndsWith("@news.co.uk")
        if ($val1)
        {
        write-host "Valid EMail address : $Mailaddress" -f Green
        }
        else
        {
        Write-Host "invalid email address" -f Red
        }
}


Function CheckHostname ($HostName,$Platform)
{
$HostName = @()

        if ($HostName -and ($Platform -eq "Windows"))
        {
        $Host1 = $HostName.StartsWith("UAWSMS") -or $HostName.StartsWith("uawsms") 
        $Host2 = $HostName.StartsWith("PAWSMS") -or $HostName.StartsWith("pawsms") 
        $Host3 = $HostName.StartsWith("DAWSMS") -or $HostName.StartsWith("dawsms") 
        }
        if ($HostName -and (($Platform -eq "Linux") -or ([System.String]::IsNullOrEmpty($Platform))))
        {
        $Host1 = $HostName.StartsWith("UAWSLX") -or $HostName.StartsWith("uawslx") 
        $Host2 = $HostName.StartsWith("PAWSLX") -or $HostName.StartsWith("pawslx") 
        $Host3 = $HostName.StartsWith("DAWSLX") -or $HostName.StartsWith("dawslx") 
        }
       <# If ($HostName -and [System.String]::IsNullOrEmpty($Platform))
        {
        $Host1 = $HostName.StartsWith("UAWSLX") -or $HostName.StartsWith("uawslx") 
        $Host2 = $HostName.StartsWith("PAWSLX") -or $HostName.StartsWith("pawslx") 
        $Host3 = $HostName.StartsWith("DAWSLX") -or $HostName.StartsWith("dawslx") 
        }#>

    if (($Host1 -or $Host2 -or $Host3) -match "\d")
    {
        Write-Host "Host Name with valid format : $HostName" -f Green
    }
    else 
    {
        Write-Host "Host Name with invalid format" -f Red
    }
 }



foreach ($InstanceID in $InstanceIDs)
{
$InstanceDetails = ((Get-EC2Instance $InstanceID -Region eu-west-1).Instances)
$volumes = $InstanceDetails.BlockDeviceMappings[0]

$VolumeId = $volumes.ebs.VolumeId
$VolumesSize = (Get-EC2Volume -VolumeId $VolumeId -Region eu-west-1).Size
$Platform=(($InstanceDetails | Select-Object Platform).Platform).value

$TagName=($InstanceDetails.Tag | where-object { $_.key -eq "Name"}).value
$TagHostName=($InstanceDetails.Tag | where-object { $_.key -eq "Hostname"}).value
$TagSupportTeam=($InstanceDetails.Tag | where-object { $_.key -eq "SupportTeam"}).value
$TagServiceOwner=($InstanceDetails.Tag | where-object { $_.key -eq "ServiceOwner"}).value
$TagServiceName=($InstanceDetails.Tag | where-object { $_.key -eq "ServiceName"}).value
$TagCostCentre=($InstanceDetails.Tag | where-object { $_.key -eq "CostCentre"}).value
$TagShutdownTime=($InstanceDetails.Tag | where-object { $_.key -eq "ShutdownTime"}).value


Write-Host `n`n "==========Instance ID details ============" `n
Write-Host "Instance ID is           :" $InstanceID
Write-Host "Host Name                :" $TagHostName
Write-Host "Tag Name                 :" $TagName
Write-Host "ServiceName              :" $TagServiceName
Write-Host "SupportTeam Name         :" $TagSupportTeam
Write-Host "ServiceOwner             :" $TagServiceOwner
Write-Host "CostCentre               :" $TagCostCentre
Write-Host "ShutdownTime             :" $TagShutdownTime
Write-Host "Platform                 :" $Platform
Write-Host "Volume Size is           :" $VolumesSize
Write-Host "VolumeSizeValidation     :" $VolumeSizeValidation
Write-Host `n `t `t "============================" 

$TagReport=""

#Checking Tagname
If([System.String]::IsNullOrEmpty($TagName))
{
$InstanceTagged=0
$TagReport+="TagName : $TagName`n"
Write-Host "Instance Tag Name is empty" -f Red
}
else {Write-Host "Instance have Tag Name : $TagName " -f Green}

#Checking HostName
If([System.String]::IsNullOrEmpty($TagHostName))
{
$InstanceTagged=0
$TagReport+= "TagHostname : $TagHostName`n"
Write-Host "Instance Host Name is empty" -f Red
}
else {
$HostNameFormat=CheckHostname $TagHostName $Platform
#$TagHostNamevalidation = CheckHostname $TagHostName $Platform
$VolumeSizeValidation=VolumeSizeValidation $VolumesSize $Platform $InstanceID
 }

#Checking SupportTeam
If([System.String]::IsNullOrEmpty($TagSupportTeam))
{
$InstanceTagged=0
$TagReport+= "TagSupportTeam : $TagSupportTeam `n"
Write-Host "Instance Support Team Name is empty" -f Red
}
else {Write-Host "Instance have Support Team Name : $TagSupportTeam " -f Green}


#checking ServicOwner & mail ID
If([System.String]::IsNullOrEmpty($TagServiceOwner))
{
$InstanceTagged=0
$TagReport+= "TagServiceOwner: $TagServiceOwner `n"
}
else
{
#call function to validate incorrect email address. returns true if its not a valid mail address
$serviceOwnerValidation=CheckInvalidMailAddress($TagServiceOwner)
}


#Checking ServiceName
if([System.String]::IsNullOrEmpty($TagServiceName))
{
$InstanceTagged=0
$TagReport+= "TagServiceName : $TagServiceName`n"
Write-Host "Instance Service Name is empty" -f Red
}
else {Write-Host "Instance have Service Name :$TagServiceName " -f Green}


#Checking CostCenter
if([System.String]::IsNullOrEmpty($TagCostCentre))
{
$InstanceTagged=0
$TagReport+= "TagCostCentre : $TagCostCentre `n"
Write-Host "Instance Cost center id is empty" -f Red
}
else {Write-Host "Instance have Cost center id :$TagCostCentre " -f Green}


#Checking Shutdowntime
if([System.String]::IsNullOrEmpty($TagShutdowntime))
{
$InstanceTagged=0
$TagReport+= "TagShutdownTime : $TagShutdownTime`n"
Write-Host "Instance shutdowntime is empty" -f Red
}
else {Write-Host "Instance have shutdowntime : $TagShutdownTime " -f Green}


$AWSInstanceInventory=@()
$row=""| select InstanceID, Name, HostName, ServiceName, SupportTeam, ServiceOwner, Platform

$row.InstanceID=$InstanceID
$row.Name=$TagName
$row.HostName=$TagHostName
$row.ServiceName=$TagServiceName
$row.SupportTeam=$TagSupportTeam
$row.ServiceOwner=$TagServiceOwner
$row.Platform=$Platform

$AWSInstanceInventory+=$row

$CSVFile = 'C:\temp\volume.csv'
$AWSInstanceInventory | export-csv $CSVFile -NoTypeInformation -append



}