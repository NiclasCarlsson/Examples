function Get-EdgeCard {
<#
  Note: This is a helper function.
        Avoid to make it directly available over the JEA endpoint.
#>
  param ( 

    # Look up ID
    [string] $EdgeID,

    # Efecte Edge server
    [string] $EdgeServer = '<default server removed>',

    # Credentials to access API
    [System.Management.Automation.PSCredential] $Credential = $KTHEdgeCredential,

    # Developer
    [switch] $developer
   
  )

  begin {

    # Set security to TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

  }

  process {
    #region Validate EdgeID
    if ( $EdgeID -match '^KTH-INC-\d{7,8}$|^KTH-SR-\d{7,8}$|^SR-\d{7,8}$' ) {

      # Build Edge Query (note: single quote inside doublequotes is needed for the Efecte query syntax)
      Switch -Regex ($EdgeID) {
        # Incidents
        '^KTH-' { 
          $TemplateCode = "'incident'" 
        }
        # Service Requests
        '^KTH-SR-|^SR-'  { 
          $TemplateCode = "'ServiceRequest'" 
        }
      }
      $Query = 'select entity from entity where template.code={0} and $efecte_id$={1}' -f $TemplateCode, "'$EdgeID'"

      # Build URI
      $GetEdgeEntity = '{0}/api/itsm/search.ws?query={1}' -f $EdgeServer, $Query

      $param = @{
        Uri             = $GetEdgeEntity 
        Credential      = $Credential
        Method          = 'GET'
        ContentType     = 'application/xml; charset=utf-8'
        UseBasicParsing = $true
      }
      $Result = [xml] ( Invoke-WebRequest @param ).Content
    }
    else {
      $Result = 'Error, ID ({0}) does not match an Incident or Service Request.' -f $EdgeID
    }
  }
  end {
    return $Result
  }
}