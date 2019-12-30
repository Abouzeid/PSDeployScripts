# Read the existing file
$filePathToTask = "D:\Deployment\Debug\TsrService.exe.config"
$xml = New-Object XML
$xml.Load($filePathToTask)

$element =  $xml.SelectSingleNode("//configuration/appSettings/add")
$nodes = $xml.SelectNodes("//configuration/appSettings/add");

foreach($node in $nodes)
 {
   $key  = $node.Key
        
   if($key -eq "IsQA")
      {$node.SetAttribute("value", "test");}
      
   if($key -eq "DbServerName")
      {$node.SetAttribute("value", "WRATest");}
      
    if($key -eq "Port")
      {$node.SetAttribute("value", "8090");}
 }

$xml.Save($filePathToTask)