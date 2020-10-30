New-AzResourceGroup `
   -ResourceGroupName "myResourceGroupVM" `
   -Location "East US"
 
   
  
  $username = "newuser"
  $password = ConvertTo-SecureString "P@ssW0rD!" -AsPlainText -Force
  $Cred = New-Object System.Management.Automation.PSCredential($username, $password)
  
      
 #New-AzVm `
  #-ResourceGroupName "myResourceGroupVM" `
   #-Name "myVM" `
   #-Location "East US" `
   #-VirtualNetworkName "myVnet" `
   #-SubnetName "mySubnet" `
   #-SecurityGroupName "myNetworkSecurityGroup" `
   #-PublicIpAddressName "myPublicIpAddress" `
   #-Credential $Cred
   #-Force


New-AzVm `
    -ResourceGroupName "myResourceGroupVM" `
    -Name "myVM" `
    -Location "East US" `
    -VirtualNetworkName "myVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "myNetworkSecurityGroup" `
    -PublicIpAddressName "myPublicIpAddress" `
    -OpenPorts 80,3389 `
    -Credential $Cred 
