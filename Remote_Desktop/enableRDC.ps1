<#
  

#>
# Prompt for input values with descriptive messages
$TargetComputer = Read-Host "Enter the hostname or IP address of the target computer (e.g., Server01 or 192.168.1.10)"
$Domain = Read-Host "Enter the domain name (e.g., Contoso)"
$AdminUser = Read-Host "Enter the username of the domain admin (e.g., Administrator)"

# Step 1: Enable Remote Desktop by modifying the registry value
Write-Host "Enabling Remote Desktop via registry change on $TargetComputer..."
try {
    Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    }
    Write-Host "Success: Remote Desktop enabled via registry." -ForegroundColor Green
} catch {
    Write-Host "Failure: Unable to enable Remote Desktop via registry." -ForegroundColor Red
}

# Step 2: Allow Remote Desktop through the Windows Firewall
Write-Host "Allowing Remote Desktop through Windows Firewall on $TargetComputer..."
try {
    Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    }
    Write-Host "Success: Remote Desktop allowed through Windows Firewall." -ForegroundColor Green
} catch {
    Write-Host "Failure: Unable to allow Remote Desktop through Windows Firewall." -ForegroundColor Red
}

# Step 3: Add the default domain admin to the Remote Desktop Users group
Write-Host "Adding $Domain\$AdminUser to the Remote Desktop Users group on $TargetComputer..."
try {
    Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member "$using:Domain\$using:AdminUser"
    }
    Write-Host "Success: $Domain\$AdminUser added to Remote Desktop Users group." -ForegroundColor Green
} catch {
    Write-Host "Failure: Unable to add $Domain\$AdminUser to the Remote Desktop Users group." -ForegroundColor Red
}

# Step 4: Verify Remote Desktop is enabled
Write-Host "Verifying that Remote Desktop is enabled on $TargetComputer..."
try {
    $RDCStatus = Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
        Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
    }

    if ($RDCStatus.fDenyTSConnections -eq 0) {
        Write-Host "Success: Remote Desktop is enabled on $TargetComputer." -ForegroundColor Green
    } else {
        Write-Host "Failure: Remote Desktop is not enabled on $TargetComputer." -ForegroundColor Red
    }
} catch {
    Write-Host "Failure: Unable to verify the Remote Desktop status on $TargetComputer." -ForegroundColor Red
}
