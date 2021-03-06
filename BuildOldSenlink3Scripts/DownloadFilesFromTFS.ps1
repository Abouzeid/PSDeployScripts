. .\Variables.ps1

function Get-Senslink3 ( [Parameter(Mandatory=$true)] [String] $Version)
{
Write-Host $Version
Write-Host "Current Workspaces"

$OutputVariable = (& $tfs vc workspaces /collection:http://tfs2015:8080/tfs/AnaSystemRD/) | Out-String
Write-Host  $OutputVariable

if ($OutputVariable -like '*Deployment*')
    {
        Write-Host  "The used workspace is Deployment."
    }
    else
    {
            Write-Host  "Creating a new workspace named Deployment ...."
            #1- Create a seperate workspace
            &$tfs vc workspace -new Deployment /comment:"used for Deploying Applications" -collection:http://tfs2015:8080/tfs/AnaSystemRD
    }
    
#2- Create a mapping    
    & $tfs vc workfold "$/Developing/Senslink 3.0" "$thisPath\Senslink 3.0" /collection:http://tfs2015:8080/tfs/AnaSystemRD/ /workspace:"Deployment"
    
#3- Get specifc label code
    if ($Version -eq "latest")
    { 
        #& $tfs get -recursive "$thisPath\Senslink 3.0" /v:WDeployment
        & $tfs get /recursive "$thisPath\Senslink 3.0"
    }
    else
    {
        & $tfs get -recursive /v:"L$Version"
    }
    
#Useful Commands
    #&$tfs vc workspace -delete Deployment
}