#$Session = New-PSSession -ComputerName "TFSAgent" -Credential "anasystem\m.abouzeid"
#Copy-Item "D:\Deployment\2.0.9\*" -Destination "C:\TsrService\" 


# Copy directory to another PC
$date = (Get-Date).ToString("_MMddyyyy")


#Defining Source and Destination path
$DestPath =  "\\Embedded\c\TsrLatest-2"
$SourcePath = "D:\SourceControl_2019\Senslink 3.0\Applications\SenslinkTsrManager\TsrService"

#Creating new folder for storing backup
#New-Item -Path $DestPath -ItemType directory

#Copying folder
Copy-Item -Recurse -Path $SourcePath -destination $DestPath 
