###################################################################################################################
#                                                                                                                 #
#                                                  filelist.ps1                                                   #
#                                                                                                                 #
###################################################################################################################
#                                                                                                                 #
#   Summary:        search inside a directory for all files of a specified type                                   #
#                   and export them to a .csv file (for later usage in e.g. excel)                                #
#                                                                                                                 #
#   Usage:          ./filelist -fileext *.ext [-basepath path] [-outfile output.csv] [-columns col1, col2]        #
#                                                                                                                 #
#   Parameters:     fileext:    the target file extension in the format asterisk dot extension                    #
#                   basepath:   the directory wich contains files to list                                         #
#                   outfile:    the resulting .csv file                                                           #
#                   columns:    additional collumns to add to the csv                                             #
#                                                                                                                 #
###################################################################################################################


param ($basepath = $PSScriptRoot, $outfile='result.csv', $fileext, [String[]] $columns)

# if $outfile not contains .csv, add it as file extension
if ($outfile -notmatch '.csv')
{
    $outfile = $outfile + '.csv'
}

# check if $fileext has a valid format
if ($fileext -cmatch '^\*\.[^.]+$')
{   
    # check if the $basepath directory exists
    if(Test-Path($basepath))
    {

        # fetch the directory and full name of all $fileext files inside of $basepath and its subdirectories into an object
        $files = Get-ChildItem -Path $basepath -Filter $fileext -Recurse | Select-Object DirectoryName, Name

        # check if there are any files of the specified type
        if($files.Count -gt 0)
        {
            # remove $basepath part from DirectoryName to show only subdirectories
            foreach ($pathname in $files)
            {
                $pathname.DirectoryName = $pathname.DirectoryName.Replace($basepath,'')
            }

            if($columns)
            {
                foreach($column in $columns)
                {
                    $files | Add-Member -NotePropertyName $column -NotePropertyValue ''
                }
            }

            # export our object to a semicolon delimited csv file at former specified $outfile
            $files | Export-Csv -Delimiter ';' -Path $outfile -Encoding utf8 -NoTypeInformation
            Write-Host "Success: data was exported to $outfile" -ForegroundColor Green
        }
        else
        {
            write-host "Warning: No files found! No export file '$outfile' created." -ForegroundColor Yellow
        }
    }
    else
    {
        Write-Host "Error: The path '$basepath' doesn't exist!" -ForegroundColor Red
    }
}
else
{
    Write-Host "Error: The Extension '$fileext' is invalid! You have to write it in the format asterisk dot extension e.g. '*.ext'" -ForegroundColor Red
}
