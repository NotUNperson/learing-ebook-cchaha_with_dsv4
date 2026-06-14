$events = Get-WinEvent -LogName Application -MaxEvents 200 | Where-Object { $_.Id -eq 1026 -and $_.Message -like '*HyPlayer*' }
$events | Select-Object -First 2 | ForEach-Object { $_.Message }
