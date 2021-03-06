. .\Config.ps1


function Create-NugetPkg ($nugetLibVersion)
 {
    $spec =  &$nuget spec -Force
    
    foreach ($lib in $lib_packages.GetEnumerator())
     {                     
        $libName =($lib.Name)
        $libPath =($lib.Value)
        
      Update-Lib-Spec -fileName "Package.nuspec" -id $libName -version $nugetLibVersion -dest $libPath
      
      Write-host "Successfully added nuget spec for $libName"
    }
    
     foreach ($lib in $lib_packages.GetEnumerator())
     {                     
        $libName =($lib.Name)
        $libPath =($lib.Value)
        
     $packResult =  &$nuget pack "$libPath\$libName.csproj" -IncludeReferencedProjects -OutputDirectory $pkgsLoc
      
      $expectedPkgName = "$libName.$nugetLibVersion.nupkg"
        
      Write-host "Created nuget package for $libName"
       
       if($nugetServer -like "*anasystem*")
       {
        &$nuget push "$pkgsLoc\$expectedPkgName" nuget@anasystem -Source $nugetServer
       }
       else
       {
        &$nuget push "$pkgsLoc\$expectedPkgName" -Source $nugetServer
       }
       
       Write-host "Published $expectedPkgName to $nugetServer"
     }
 }
 
 
 function Update-Lib-Spec($fileName,$id,$version,$dest)
 {
        $xml = New-Object XML
        $specPath = "$thisPath\$fileName";
        $xml.Load($specPath)
     
        $idNode = $xml.SelectSingleNode("//package/metadata/id");       
        $idNode.InnerText = $id
        
        $versionNode = $xml.SelectSingleNode("//package/metadata/version");       
        $versionNode.InnerText = $version
        
        $description = $xml.SelectSingleNode("//package/metadata/description");       
        $description.InnerText = $id
        
           
        $releaseNotes = $xml.SelectSingleNode("//package/metadata/releaseNotes");       
        $releaseNotes.InnerText = "Changes made in this nuget pkg release for $id, please refer to issue #1627 "
        
        
        $parent_xpath = '/package /metadata'
        
        $nodes = $xml.SelectNodes($parent_xpath)
        $nodes | % {
            $child_node = $_.SelectSingleNode('projectUrl')
            $_.RemoveChild($child_node) | Out-Null
            
            $child_node = $_.SelectSingleNode('licenseUrl')
            $_.RemoveChild($child_node) | Out-Null
         
          
             $child_node = $_.SelectSingleNode('dependencies')
            $_.RemoveChild($child_node) | Out-Null
              
             $child_node = $_.SelectSingleNode('iconUrl')
            $_.RemoveChild($child_node) | Out-Null
            
                $child_node = $_.SelectSingleNode('tags')
            $_.RemoveChild($child_node) | Out-Null
        }
          
        $xml.Save("$dest\$id.nuspec")
 }
 
 
 
 function Publish-Pkg ()
 {
 foreach ($lib in $lib_packages.GetEnumerator())
     {                
        $libName =($lib.Name)
        $libPath =($lib.Value)
        
        $nugetServer = "http://issue.anasystem.com.tw:5555/"
        $account = "nuget@anasystem"
        $packageName = ($lib.Name)
         
        $latestRelease = nuget list $packageName
        $version = $latestRelease.split(" ")[1];
         
        $versionTokens = $version.split(".")
        $buildNumber = [System.Double]::Parse($versionTokens[$versionTokens.Count -1])
        $versionTokens[$versionTokens.Count -1] = $buildNumber +1
        $newVersion = [string]::join('.', $versionTokens)
        echo $newVersion
         
        get-childitem | where {$_.extension -eq ".nupkg"} | foreach ($_) {remove-item $_.fullname}
        nuget pack -Version $newVersion
        $package = get-childitem | where {$_.extension -eq ".nupkg"}
        &$nuget push -Source $nugetServer $package $apiKey
               
    }
 }