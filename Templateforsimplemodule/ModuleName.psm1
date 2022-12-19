#Get public and private function definition files.
  $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1  -ErrorAction SilentlyContinue )
  $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the FUNCTION files
  Foreach( $import in @($Public + $Private ) ) {
    Try {
        . $import.fullname
    }
    Catch {
      Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
  }

#Get public and private variable definition files.
  $PrivateVariable = @( Get-ChildItem -Path $PSScriptRoot\Private\*.* -Exclude *.ps1 -ErrorAction SilentlyContinue )
  $PublicVariable  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.*  -Exclude *.ps1 -ErrorAction SilentlyContinue )

#Parse the variable files (using Encoding utf7 due to Swedish regionales)
  Foreach( $import in @($PublicVariable + $PrivateVariable ) ) {

    switch ( $import.extension ) {

      '.csv' {
        
        try {
          # Get value from CSV
          $ParamCSV = @{
            Path      = $import.FullName
            Delimiter = ';'
            Encoding  = 'UTF7'
          }
          $Value = Import-Csv @ParamCSV

          New-Variable -Name $Import.BaseName -Value $Value
        }
        catch {
          Write-Error -Message "Failed to import variable from $($import.fullname): $_"
        }
        break
 
      }

      '.txt' {

        try {
          $ParamVar = @{
            Path     = $import.FullName 
            Encoding = 'UTF8'
          }
          $Value = Get-Content @ParamVar

          New-Variable -Name $Import.BaseName -Value $Value
        }
        catch {
          Write-Error -Message "Failed to import variable from $($import.fullname): $_"
        }
        break

      }

      '.json' {
        
        try {
          $ParamVar = @{
            Path     = $import.FullName 
            Encoding = 'UTF8'
          }
          $Value = $( [string] ( get-content @ParamVar ) | ConvertFrom-Json )

          New-Variable -Name $Import.BaseName -Value $Value
        }
        catch {
          Write-Error -Message "Failed to import variable from $($import.fullname): $_"
        }
        break

      }

      default { 
        Write-Warning -Message "Did not find an import instruction for file extension: $($import.extension) ($($import.fullname))."
      }

    }

  }

#Prepare "calculated" variables specific for Module
  #$VariableName = function
  
  #Create an object with only the needed property for the export 
  #$PublicVariable += New-Object -TypeName psobject -Property @{ BaseName = '' } 

#region Export Module members 

  # Verify module contains at least one function
  if ( $Public.Basename.count -gt 0 ) 
  { 
    $param += @{ Function = $Public.Basename } 
  }

  # Verify module contains at least one variable
  if ( $PublicVariable.Basename.count -gt 0 ) 
  { 
    $param += @{ Variable = $PublicVariable.Basename } 
  }

  Export-ModuleMember @param

#endregion Export Module members 
