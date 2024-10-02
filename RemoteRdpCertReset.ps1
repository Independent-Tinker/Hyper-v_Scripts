<#
  Script From: TechsavvyProductions
    Mastering Remote Desktop Connection: From Fundamentals to Advanced Troubleshooting
    https://www.youtube.com/watch?v=Zb-R-6oPCUE
#>

# Prompt for target computer name
$TargetComputer = Read-Host -Prompt "Enter the name of the remote computer (e.g., PC1234 or IP address)"

# Prompt for credentials with a description
$Credential = Get-Credential -Message "Enter credentials for the remote computer ($TargetComputer). Use a domain account with administrative privileges."

# Display the initial operation
Write-Output "Attempting to connect to $TargetComputer with provided credentials..."

# Define a script block for operations on the remote machine
$ScriptBlock = {
    param ($ComputerName)

    Write-Output "Stopping Remote Desktop Services (TermService) on $ComputerName..."
    
    try {
        # Stop the Remote Desktop Services
        Stop-Service -Name "TermService" -Force -ErrorAction Stop
        Write-Output "Remote Desktop Services stopped successfully."
    }
    catch {
        Write-Output "Failed to stop Remote Desktop Services: $_"
        exit 1
    }

    Write-Output "Deleting the RDP self-signed certificate..."

    try {
        # Define the certificate thumbprint location for RDP
        $RdpCertificatePath = "HKLM:\SOFTWARE\Microsoft\SystemCertificates\Remote Desktop\Certificates"

        # Remove the RDP self-signed certificate
        Remove-Item -Path "$RdpCertificatePath\*" -Recurse -Force -ErrorAction Stop
        Write-Output "RDP self-signed certificate deleted successfully."
    }
    catch {
        Write-Output "Failed to delete the RDP self-signed certificate: $_"
        exit 1
    }

    Write-Output "Restarting Remote Desktop Services (TermService)..."

    try {
        # Start the Remote Desktop Services
        Start-Service -Name "TermService" -ErrorAction Stop
        Write-Output "Remote Desktop Services restarted successfully."
    }
    catch {
        Write-Output "Failed to restart Remote Desktop Services: $_"
        exit 1
    }

    Write-Output "Operation completed successfully on $ComputerName."
}

# Execute the script block on the remote computer
try {
    Invoke-Command -ComputerName $TargetComputer -Credential $Credential -ArgumentList $TargetComputer -ScriptBlock $ScriptBlock -ErrorAction Stop
    Write-Output "Script executed successfully on $TargetComputer."
}
catch {
    Write-Output "Script execution failed on ${TargetComputer}: $_"
}
