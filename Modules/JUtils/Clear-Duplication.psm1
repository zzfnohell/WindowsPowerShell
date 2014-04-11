
function Clear-Duplication()
{
    [CmdletBinding()] 
    param ( 
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$Path)
    
    process
    {
        if($Path -eq $null -or $Path -eq '' )
        {
            $Path = '.'
        }

        $Path = Resolve-Path -Path $Path
        Write-Host $Path
        $FileDict = @{}

        function AddToDict ()
        {
            begin
            {
            }
            process
            {
                Write-Host $_.Path
                $HashString = $_.HashString
                $Value = $FileDict[$HashString];
                $Value += @($_.Path)
                $FileDict[$HashString] = $Value
            }
            end
            {
            }
        }

        Get-ChildItem -Path $Path -Recurse -File `
            | ForEach-Object { Get-Hash $_ | AddToDict }

        function Remove()
        {
            param($HashKVP )

            Add-Type -AssemblyName Microsoft.VisualBasic

            Write-Host $HashKVP .Key
            $Files = $HashKVP. Value
            foreach($path in $Files)
            {
                Write-Host $path
            }
   
            # Remove Duplicate files
            foreach($path in $Files[1..$Files.Length])
            {
                Write-Host "Remove $path..." -ForegroundColor Cyan
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
                    $path,
                    'OnlyErrorDialogs',
                    'SendToRecycleBin')
                Write-Host "Remove $path done." -ForegroundColor Cyan
            }
        }

        $FileDict.GetEnumerator() `
            | Where-Object { $_.Value.Count -gt 1 } `
            | ForEach-Object { Remove $_ } 
    }
}