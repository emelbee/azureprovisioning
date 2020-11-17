# deploy a new windows machine in azure

New-AzResourceGroup `
   -ResourceGroupName "myResourceGroupVM" `
   -Location "East US"
 
# temp password that will be changed afer onboarding

  $username = "breakglass"
  $PW = [System.Web.Security.Membership]::GeneratePassword(24,0)
  $password = ConvertTo-SecureString $PW -AsPlainText -Force
  $Cred = New-Object System.Management.Automation.PSCredential($username, $password)
   

New-AzVm `
    -ResourceGroupName "myResourceGroupVM" `
    -Name "myVM" `
    -Location "East US" `
    -VirtualNetworkName "myVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "myNetworkSecurityGroup" `
    -PublicIpAddressName "myPublicIpAddress" `
    -OpenPorts 80,3389,139,445 `
    -Credential $Cred 

"$(Get-Date) azure resource created succesfully"

"$(Get-AzPublicIpAddress -Name myPublicIpAddress -ResourceGroupName myResourceGroupVM)"
(Get-AzPublicIpAddress -ResourceGroupName myResourceGroupVM).IpAddress


########################################
# now onboard this virtual machine     #
########################################
# Define the FQDN for the REST APIs
$FQDN = 'https://comp01.cybr.com'

# get the api logon credentials
# here we will use the dap integration
# to retrieve the api credentials

# We got the creds for the REST APIs so we are good to go!
 "$(Get-Date) Credentials retrieved, logging in to REST APIs"
  


$logonInfo = @{}

  #$logonInfo.username = $username
  #$logonInfo.password = $password
  $logonInfo.username = "dapprovisioning"
  $logonInfo.password = "Cyberark1"


$targetaddress = (Get-AzPublicIpAddress -ResourceGroupName myResourceGroupVM).IpAddress

 "$(Get-Date) test input done "
 "$(Get-Date) the input used is $username $targetpassword $targetaddress"
 

##########################################################
  # Use REST APIs to logon to the CyberArk Vault
  ##########################################################
  $loginURI = $FQDN + '/PasswordVault/WebServices/auth/cyberark/CyberArkAuthenticationService.svc/logon'
  #login to the Vault
  $result = Invoke-RestMethod -Method Post -Uri $loginURI -ContentType "application/json" -Body (ConvertTo-Json($logonInfo))
  "$(Get-Date) Vault login successful"
  
  $logonToken = $result.CyberArkLogonResult
  # Define the Account Management URL
  $createAccountURI = $FQDN + '/PasswordVault/WebServices/PIMServices.svc/Account'
  # Account parameters
  $newAccounts = @{}
  $newAccount = @{}
  $newAccount.safe = "Azure"
  $newAccount.platformID = "AzureWindowsServerAccounts"
  # We could use the IP or DNS address, IP is neater...
  #$newAccount.address = $FullyQualifiedDomainName
  $newAccount.address = "$targetaddress"
  # The default Windows account is always Administrator...
  $newAccount.username = $username
  $newAccount.password = $password
  $newAccount.accountName = $instanceid
  # Add the account to create to the accounts array
  $newAccounts.account = $newAccount
  # Set the authorisation token in the headers for the REST call
  $headers = @{ "Authorization" = $logonToken }
  ##########################################################
  # Use REST APIs to create the account in the CyberArk Vault
  ##########################################################
  $result = Invoke-RestMethod -Method Post -Uri $createAccountURI -headers $headers -ContentType "application/json" -Body (ConvertTo-Json($newAccounts))
  "$(Get-Date) Account created successfully" 
  ##########################################################
  # Use REST APIs to logoff from the Vault
  ##########################################################
  $logoffURI = $FQDN + '/PasswordVault/WebServices/auth/cyberark/CyberArkAuthenticationService.svc/logoff'
  $result = Invoke-RestMethod -Method Post -Uri $logoffURI -headers $headers -ContentType "application/json" -Body (ConvertTo-Json($logonInfo))
  "$(Get-Date) Vault logoff successful"
 # "$(Get-Date) Finished provisioning instance in AWS and the privileged account of instance $instanceid, with IP address $publicIP in the CyberArk Vault"
 # pause
  # Clear AWS credentials so no PowerShell script in the same context can access them
 # Remove-AWSCredentialProfile -ProfileName default -Force
  # This will delete the only way you can decrypt the password using AWS provided capabilities
 # Remove-Item "$KeyFilePath"
#}
