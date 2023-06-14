
$folder_path = "C:\temp\autopilot"
$output_file = "$folder_path\collected_list.csv"

$files = Get-ChildItem -Path "$folder_path\*" -File -Include UWSA-*

foreach ($file in $files) {
    Write-Host $file.fullname

    Get-Content $file.fullname | Add-Content $output_file
}



