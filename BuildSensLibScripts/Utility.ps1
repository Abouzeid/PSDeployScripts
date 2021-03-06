. .\Config.ps1

function Build-Solution()
{

#1.1- Build the Solution
Write-Host "Solution Location"
    Write-Host $seslink3Sln
    &$nuget restore $seslink3Sln
    &$msbuild_2019 $seslink3Sln  /t:Rebuild /p:Configuration=debug /p:Platform="Any CPU"  

#1.2 Build with release    
Write-Host "Solution Location"
    Write-Host $seslink3Sln
    &$nuget restore $seslink3Sln
    &$msbuild_2019 $seslink3Sln  /t:Rebuild /p:Configuration=Release /p:Platform="Any CPU"
}

function Update-Vesions($fileVersion)
{   
    $assemblyFiles = dir -Path $senslinkRoot -Filter AssemblyInfo.cs -Recurse | %{$_.FullName}
    $len=$assemblyFiles.length
    Write-Host "Total of  files $len"
    Write-Host "---------------------------------------------"
    foreach ($file in $assemblyFiles.GetEnumerator())
    {
        Write-host $file
        
        $path = $file   
        $replace = '[assembly: AssemblyVersion("'+$fileVersion+'.0")]'
        $replaceFileAssembly = '[assembly: AssemblyFileVersion("'+$fileVersion+'.0")]'

        $lines = Get-Content -Path $path -Encoding Unicode  | Select-String AssemblyVersion | Select-Object -ExpandProperty Line 
        $newContent = @()    

        foreach($line in Get-Content $path) {
            if($line -Like "*AssemblyVersion*" -and $line -notlike "//*") {
                $line=$replace
             }

              if($line -Like "*AssemblyFileVersion*" -and $line -notlike "//*") {
                $line=$replaceFileAssembly
             }

         $newContent+=($line)
        }

        Set-Content -Path $path -Value $newContent -Encoding Unicode
         Write-Host "---------------------------------------------"
    }
    
    Write-Host "Finished Updating"
    $verTxtPath = -join($senslinkRoot,"\version.txt");
    Set-Content -Path $verTxtPath -Value $fileVersion
   
}


function Read-Versions()
{
        $versionFile = dir -Path $senslinkRoot -Filter version.txt  | %{$_.FullName}
        Write-host "Version.txt file value:"
        Write-host $versionFile

        $content = [IO.File]::ReadAllText($versionFile)
        Write-Host "Current version in tfs:  $content"
        $content =$content.Trim()
        return $content
}


function VersionGreaterOrEqual($major1, $minor1, $build1, $revision1, $major2, $minor2, $build2, $revision2)
{
    return ($major1 -gt $major2 -or ($major1 -eq $major2 -and ($minor1 -gt $minor2 -or ($minor1 -eq $minor2 -and ($build1 -gt $build2 -or ($build1 -eq $build2 -and $revision1 -ge $revision2))))))
}

function VersionGreaterOrEqual([Version] $firstVer , [Version] $secondVr)
{
    $isValid = ($firstVer.Major -gt $secondVr.Major -or ($firstVer.Major -eq $secondVr.Major -and ($firstVer.Minor -gt $secondVr.Minor -or ($firstVer.Minor -eq $secondVr.Minor -and ($firstVer.Build -gt $secondVr.Build -or ($firstVer.Build -eq $secondVr.Build -and $firstVer.Revision -ge $secondVr.Revision))))))
     if($isValid)
            {
            
                Write-Host "$secondVr is a Valid version "
            }
            else
            {
                Write-Error "Invalid version number $firstVer must be > $secondVr"   
                $Error = New-Object System.FormatException "Invalid Argument"
                throw $Error
                 Write-Error "Prgram will stop!" -ErrorAction Stop   
            }
}

function Validate-UserInputVersion($inputVersion, $current)
{
        #remove white spaces
        $inputVersion=$inputVersion.trim()

        $currentNum = $current.split(".")
        $inputNum = $inputVersion.split(".")

        if ($inputNum.length -ne 3)
        {
         $Error = New-Object System.FormatException "$inputVersion invalid Version format should be x.x.x"
         Write-Error $Error -ErrorAction Stop
         throw $Error
        }


        [bool] $isValid= $false

        if(($currentNum[0] -lt $inputNum[0]))
        {
          $isValid=$true
        }
         else
           {
             if(([int]$currentNum[0] -eq [int]$inputNum[0]) -And ([int]$currentNum[1] -lt [int]$inputNum[1]))
                {
                    $isValid=$true
                }
                else
                {
                   if(([int]$currentNum[1] -eq [int]$inputNum[1]) -And ([int]$currentNum[2] -lt [int]$inputNum[2]))
                    {
                        $isValid=$true
                    }else
                    {
                    $isValid= $false
                    }
                }
          }

            if($isValid)
            {
            
                Write-Host "[Check Result]$inputVersion is a Valid version "
            }
            else
            {
                Write-Error "Invalid version number $inputVersion must be > $current" -ErrorAction Stop   
                $Error = New-Object System.FormatException "Invalid Argument"
                throw $Error
            }

}


function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}