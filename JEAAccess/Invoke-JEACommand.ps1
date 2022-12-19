function Invoke-JEACommand { 
  param (

    # Which JEA endpoint to use
    [string]
    $ConfigurationName,

    # Scriptblock to be run on JEA endpoint
    [scriptblock]
    $Scriptblock,

    # Arguments to pass on
    [Array]
    $ArgumentList,

    # JEA server/computer
    [string]
    $ComputerName = '<servername>',

    # Expect Result Status
    [switch] $SkipResultStatus
  )

  process {

  #region Open session
    $ParamSession = @{
      Computername      = $ComputerName
      ConfigurationName = $ConfigurationName
    }
    $Session = New-PSSession @ParamSession
  #endregion

  #region Run the command in the EndPoint
    $paramCommand = @{
      Session      = $Session
      Scriptblock  = $Scriptblock
      ArgumentList = $ArgumentList
    }

    try {
      if ( $SkipResultStatus ) {
        [array] $ReturnObject = Invoke-Command @paramCommand
        $Result = 'Skipped'
      }
      else {
        ($Result, $ReturnObject ) = Invoke-Command @paramCommand
      }
    }
    catch {
      $Result = 'Error, failed to run JEA command.'
    }
  #endregion

  #region close session
    Remove-PSSession -Session $Session
  #endregion
  
  }

  end { 
    Return $Result, $ReturnObject
  }
}