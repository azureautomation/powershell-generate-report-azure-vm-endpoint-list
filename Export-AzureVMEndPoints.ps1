function Export-AzureVMEndPoints
{ 
[cmdletbinding()] 
param( 
[switch]$CSVReport,
[switch]$HTMLReport
) 
BEGIN{   
      try 
      { 
        Write-Host "Importing Azure PowerShell Module." -ForegroundColor Magenta
        Import-Module -Name 'Azure' -ErrorAction Stop 
        Write-Host "Getting the list of all Azure VM" -ForegroundColor Magenta
        $VmList = Get-AzureVM -ErrorAction Stop
        #Select Default AzureSubscription
        $subs = Get-AzureSubscription | Where-Object IsDefault -eq $true 

      } 
      catch 
      { 
        Write-Host  "Exception Occured : $_.Exception" 
      }   
    }
PROCESS{ 

        if ( $CSVReport.IsPresent -eq $true ) 
        { 
            Write-Output "Exporting to CSV" 
            $body1= "Name,DNSName,InstanceSize,PowerState,LocalPort,PortName,Protocol,PublicPort,VIP" 
            #New Line
            $body1 += "`n" 
           Write-Output "Processing the downloaded data." 
           foreach ( $item in $VmList  ) 
                    {   
                        $EndPoint = $item | Get-AzureEndpoint 
                        foreach($point in $EndPoint)
                        {
                            $body1 +=  $item.Name + "," + $item.DNSName  `
                                   + "," + $item.InstanceStatus  `
                                   + "," + $item.PowerState + "," + $point.LocalPort `
                                   + "," + $point.Name + "," + $point.Protocol `
                                   + "," + $point.Port + "," + $point.Vip + "`n" 
                        }
                
                   } 
         
            Write-Output "Exporting file to : $env:temp\AzureVmList.csv" 
            $body1 > "$env:temp\AzureVmList.csv" 
            #if you don't want automatic open close this lines > (50 - 51 )
            Write-Output "Opening the Exported CSV file." 
            Invoke-Expression "$env:temp\AzureVmList.csv" 

            } 
       elseif ( $HTMLReport.IsPresent -eq $true ) 
        {       
                $body1 = @()
                $i = 1

                Write-Output "Processing the downloaded data."
                foreach ( $item in $VmList  )
	            {
                    $EndPoint = $item | Get-AzureEndpoint
                    foreach($point in $EndPoint)
                    {
            
                    $counter = $i++
                    $body1 += "<tr>"
                    $body1 += "<td >" + $counter + "</td>"
                    $body1 += "<td >" +"<font color=blue face=Tohoma>" + $item.Name + "</font>" + "</td>"
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + "<a herf=" + $item.DNSName + ">" + $($item.DNSName) + "</a>" + "</font>" + "</td>"
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + $item.InstanceSize + "</font>" + "</td>"
                    if($item.PowerState -eq "Started")
                    {
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + $item.PowerState + "</font>" + "</td>"
                    }
                    else {
                    $body1 += "<td BGCOLOR='#FF6699' >" + "<font color=black face=Tohoma>" + $item.PowerState + "</font>" + "</td>"
                    }
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + $point.LocalPort + "</font>" + "</td>"
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + $point.Name + "</font>" + "</td>"
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + $point.Protocol.ToUpper() + "</font>" + "</td>"
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + $point.Port + "</font>" + "</td>"
                    $body1 += "<td >" + "<font color=black face=Tohoma>" + $point.Vip + "</font>" + "</td>"
                    $body1 += "</tr>"
                    }               

               }
	                $body2 += "<h2 style='color:#6699FF'>List of Azure VM EndPoints</h2>"
	                $body2 += "<br>"
                    $body2 += "<h2 style='color:#6699FF'>SubscriptionName : $($subs.SubscriptionName)</h2>"
                    $body2 += "<br>"
	                $body2 += "<h2 style='color:#DB4D4D'> Page generated at $(get-date) on machine $env:computername .</h2>"
	                $body2 += "<table border=1px black dotted >"
	                $body2 += "<tr>"
	                $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>SerialNumber</font></th>"
	                $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>Name</font></th>"
                    $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>DNS Name</font></th>"
	                $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>Instance Size</font></th>"
                    $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>PowerState</font></th>"
                    $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>Local Port</font></th>"
                    $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>Port Name</font></th>"
                    $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>Protocol</font></th>"
                    $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>Public Port</font></th>"
                    $body2 += "<th bgcolor='#5D7B9D' color='#FFFFFF'><font color='#FFFFFF'>VIP</font></th>"	
	                $body2 += "</tr>"
	                $body2 += $body1
	                $body2 += "</table>"
	
	                Write-Host "Generating HTML file." -ForegroundColor Magenta
	                $body2  > "$env:TEMP\AzureList.html"
                    #if you don't want automatic open close this lines > (113 - 114 )
                    Write-Host "Opening the generated HTML file to : $env:TEMP\AzureList.html ." -ForegroundColor Magenta
	                Invoke-Expression "$env:TEMP\AzureList.html"
              }
        else {
                $i = 1
                $array= @()
                Write-Host "Exporting to Powershell Console" -ForegroundColor Magenta
                foreach ( $item in $VmList  )
	            {
                    $EndPoint = $item | Get-AzureEndpoint
                    foreach($point in $EndPoint)
                    {   
                        $counter = $i++
                        $obj=New-Object PSObject 
                        $obj |Add-Member -MemberType NoteProperty -Name "SerialNumber" $counter
                        $obj |Add-Member -MemberType NoteProperty -Name "Name" $item.Name
                        $obj |Add-Member -MemberType NoteProperty -Name "DNS Name"  $item.DNSName 
                        $obj |Add-Member -MemberType NoteProperty -Name "Instance Size" $item.InstanceSize 
                        $obj |Add-Member -MemberType NoteProperty -Name "Local Port" $point.LocalPort
                        $obj |Add-Member -MemberType NoteProperty -Name "Port Name" $point.Name
                        $obj |Add-Member -MemberType NoteProperty -Name "Protocol" $point.Protocol 
                        $obj |Add-Member -MemberType NoteProperty -Name "Public Port" $point.Port
                        $obj |Add-Member -MemberType NoteProperty -Name "VIP"  $point.Vip
                        $array += $obj
                    }
                }
                    $array | Select-Object SerialNumber,Name,"DNS Name","Instance Size", `
                             "Local Port","Port Name",Protocol,"Public Port",VIP | Ft -AutoSize

           }

     }
END{
    
    Write-Host "Script run finishes at : $(get-date)"
    }

}

