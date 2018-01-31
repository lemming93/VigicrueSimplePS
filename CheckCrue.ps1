# Quick and dirty script to monitor French Vigicrue site. Done for my needs, shared if it can help.
# fell free to contribute and enhance it

function wait4IE($ie=$global:ie){
    while ($ie.busy -or $ie.readystate -lt 4)
    {
      start-sleep -milliseconds 600
    }
}

# URL from Vigicrue web site , get a station that report water level, then get the URL of "Observation tab" and copyu it below
$url = "https://www.vigicrues.gouv.fr/niv3-station.php?CdStationHydro=F622000402&CdEntVigiCru=7&GrdSerie=H&ZoomInitial=3&CdStationsSecondaires=#tabs-observations"

# Replace sound file name by any convenient sound for you
$SoundFile=".\0830.wav"
$sound = new-Object System.Media.SoundPlayer;
# Set the water level according to your need. Ensure that with this level, you can still be served by electrical company, otherwise you'll never receive any alert...
$Hauteur_Alert = 5.45

while ($true) {

    $global:ie=new-object -com "internetexplorer.application"
    $ie.visible=$true
    $ie.navigate($url)
    wait4IE($ie)

    $body=$ie.document.body.innerText.Split([Environment]::NewLine)
    $StringsToParse = $body | Select-String -Pattern "\d{2}/\d{2}/\d{4}" -AllMatches

    $HString = $StringsToParse[3].ToString().Substring(16,$StringsToParse[3].ToString().Length-16)
    $HDate = $StringsToParse[3].ToString().Substring(0,16)
    $Hauteur = [decimal]$HString

	
    If ($Hauteur -gt $Hauteur_Alert)
    {
        Write-Host "Date = $HDate - Hauteur = $Hauteur " -ForegroundColor Magenta
        $sound.SoundLocation=$SoundFile;
		# Play sound. Ensure to set the sound level strong enough to be waked up
        $sound.Play();
    }
    else
    {
        Write-Host "Date = $HDate - Hauteur = $Hauteur "  -ForegroundColor Green
        $sound.Stop();
    }
    Start-Sleep -Seconds 10
    $ie.quit()
	# Monitor every 10 minutes, but Vigicrue website may takes 2 hours before refreshing sometimes...
    Start-Sleep -Seconds 600
}