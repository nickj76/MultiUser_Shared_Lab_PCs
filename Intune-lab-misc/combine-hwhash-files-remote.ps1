$computers = @(
    "UWS60715"
    "UWS62627"
    "UWS65069"
    "UWS63987"
    "UWS61599"
    "UWS61688"
    "UWS60935"
    "UWS65445"
)

$folder_path = "C:\temp\autopilot\results"
$output_file = "$folder_path\collected_list.csv"

If (!(Test-Path -Path "$folder_path")) {
    New-item -Path "$folder_path" -ItemType Directory
}


foreach ($computer in $computers) {
    if (test-connection $computer -count 1 -quiet) {
        if (test-path -path "\\$computer\c`$\temp\autopilot-hash\$computer-hash.csv") {
            write-host $computer "hash file found"
            Copy-Item -Path "\\$computer\c`$\temp\autopilot-hash\$computer-hash.csv" -Destination "$folder_path"
        } else {
            write-host $computer "hash file not found"
        }
    } else {
        write-host $computer "not contactable"
    }
}

$files = Get-ChildItem -Path "$folder_path\*" -File -Exclude "$output_file"


"Device Serial Number,Windows Product ID,Hardware Hash,Group Tag" | Add-Content $output_file

foreach ($file in $files) {
#    Write-Host $file.fullname

    Get-Content $file.fullname | Add-Content $output_file
}


