#----------------------------------------------------------------------------#
# Program Copyright    : Mike Wilcock.
# Program Name         : printer_driver_install.ps1.
#----------------------------------------------------------------------------#
# Program Created      : 19th July 2021.
# Program Code Type    : PowerShell Script (version 5.1.19041.1023).
# Program Author       : Michael Wilcock.
# Program Version      : 1.00
#----------------------------------------------------------------------------#
# Printer Driver       : HP Universal Printing PCL 6.
#----------------------------------------------------------------------------#
# Purpose              : Automated printer driver installation.
#----------------------------------------------------------------------------#

# Define printer name, port and ip/hostname strings as memvars.
$cPrn_driver_name = "HP Universal Printing PCL 6"
$cHost_or_ip = "HP Universal Printing PCL 6"
$cPort_name = ("auto_" + $cHost_or_ip)
$cDriver_path_local = ("C:\HP Universal Print Driver\pcl6-x64-7.0.1.24923\")
$cInf_file = ("C:\Windows\System32\DriverStore\FileRepository\" + "hpcu255u.inf_amd64_883dd40f467c5d42\hpcu255u.inf")

clear screen

write-host "Printer Name             : " $cPrn_driver_name
write-host "Port Name                : " $cPort_name
write-host "Hostname / IP Address    : " $cHost_or_ip
write-host "Driver Path (Local)      : " $cDriver_path_local
write-host "Printer Driver .inf File : " $cInf_file
write-host ""

# Promt user?
$user_conf = read-host ("Install Printer Driver For Printer: " + $cHost_or_ip + " To: " + $env:computername + " - [Y/N]")

# User bailed! :-(
if($user_conf -ne "Y")
{
    clear screen
    Write-Host "Printer driver installation cancelled by user."
    break
}

clear screen

# Query printer.
Get-Printer -Name $cHost_or_ip -erroraction 'silentlycontinue' | Out-Null

# Printer exists on this machine so remove it.
if($?)
{
    # Delete the printer.
    write-host "Deleting Printer       :" $cHost_or_ip 
    Remove-Printer -Name $cHost_or_ip #-ErrorAction:SilentlyContinue
}

# Query printer port.
Get-PrinterPort -Name $cPort_name -erroraction 'silentlycontinue' | Out-Null

# Printer port exists on this machine so remove it.
if($?)
{
    # Delete the printer port.
    write-host "Deleting Printer Port  :" $cPort_name
    Remove-PrinterPort -Name $cPort_name #-ErrorAction:SilentlyContinue
}

# Query printer driver.
Get-PrinterDriver -Name $cPrn_driver_name -erroraction 'silentlycontinue' | Out-Null

# Printer driver exists on this machine so remove it.
if($?)
{
    # Delete the printer driver.
    write-host "Deleting Printer Driver:" $cPrn_driver_name 
    Remove-PrinterDriver -Name $cPrn_driver_name #-ErrorAction:SilentlyContinue
}

# Copy drivers to the Windows driver store.
write-host ""
write-host "Copying Drivers To The Windows Driver Store - Please Wait."
write-host ""
pnputil.exe /a ($cDriver_path_local + "hpcu255u.inf") | Out-Null

# There was a problem so terminate the script.
if($lastExitCode -ne 0)
{
    Write-Host "There was a problem copying the driver files to the Windows driver store."
    
    # Gracefully exit. :-)
    Break
}

# Add printer driver.
write-host "Adding Printer Driver - Please Wait." 

Add-PrinterDriver -Name $cPrn_driver_name -InfPath $cInf_file

if($?)
{
    write-host "Printer Driver Added Successfully."
    write-host ""
}

# Add printer port.
write-host "Adding Printer Port - Please Wait." 

Add-PrinterPort -Name $cPort_name -PrinterHostAddress $cHost_or_ip

if($?)
{
    write-host "Printer Port Added Successfully."
    write-host ""
}

# Add printer.
write-host "Adding Printer - Please Wait."

Add-Printer -DriverName $cPrn_driver_name -Name $cPrn_driver_name -PortName $cPort_name

if($?)
{
    write-host "Printer Added Successfully."
    write-host ""
}

# Rename printer.
Rename-Printer -Name $cPrn_driver_name -NewName $cHost_or_ip

# Test page promt.
$user_conf = read-host ("Print Test Page To : " + $cHost_or_ip + " - [Y/N]")

# Print test page.
if($user_conf -eq "Y")
{
    Get-CimInstance Win32_Printer -Filter "name LIKE '$cHost_or_ip'" | Invoke-CimMethod -MethodName PrintTestPage | Out-Null
    
    write-host ""
    write-host "Test Page Sent To Printer."
}

# Foshizzle! :-)
write-host ""
write-host "Script Completed Successfully."