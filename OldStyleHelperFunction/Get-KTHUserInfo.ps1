function Get-KTHUserInfo {
  <#
    .SYNOPSIS
        Get all users properties from Active Directory.
        Using Directory searcher.
        This to avoid having to install any modules on client.
    .DESCRIPTION
        .
    .PARAMETER SamAccountName
        The users samaccount name.
    .PARAMETER UserPrincipalName
        The users UserPrincipalName name, allows with or without domainpart.
    .PARAMETER EmailAddress
        The users EmailAddress.
    .EXAMPLE
        get-KTHuserinfo -samaccountname adam
    .EXAMPLE
        get-KTHuserinfo -UserPrincipalName adam@domain.se
    .FUNCTIONALITY
        .
    .LINK
        
    .LINK
        
  #>
  [cmdletbinding()]
  param (
    
    # The SamaccountName to look for
    [Parameter(ParameterSetName='SamAccountName')]
    [string] $SamAccountName,

    # The UserPrincipalName to look for
    # Added option for userobjects other then normal users that can have names longer then 16 chars
    [Parameter(ParameterSetName='UserPrincipalName')]
    [string] $UserPrincipalName,

    # The EmailAddress to look for
    [Parameter(ParameterSetName='EmailAddress')]
    [string] $EmailAddress,

    # Expected domain if using UserPrincipalName
    [Parameter(ParameterSetName='UserPrincipalName')]
    [string] $Domain = 'domain.se'
    
  )

  process {

  #region Building Filter based on parameterset

    # If Username used
    if ( $SamAccountName ) {
      $Filter = "(&(objectCategory=User)(samAccountName=$SamAccountName))"
    }
    elseif ( $UserPrincipalName ) {
      if ( $UserPrincipalName -notlike "*@$Domain" ) {
        $UserPrincipalName = "$UserPrincipalName@$Domain"
      }
      $Filter = "(&(objectCategory=User)(UserPrincipalName=$UserPrincipalName))"
    }
    elseif( $EmailAddress ) {

      <#   
        Email addresses can be found in four attributes depending of type
        - ugaliasusername, aliases in UG
        - proxyaddresses	, addresses present in Exchange (note name start with smtp:) 
        - ugusername, the username
        - ugkthidsearch, all KTH-ID:s

        In all ug-attributes @kth.se if present is omitted, i.e. username means username@kth.se
      #>

      #region  build a Searcher filter depending on given value
      if ( $EmailAddress -match '^([^@]+)@domain\.se$' ) {
        $KTHAddress = $matches[1]
        $Filter = '(&(objectCategory=User)(|(ugaliasusername={0})(ugusername={0})(ugkthidsearch={0})))' -f $KTHAddress
      }
      elseif ( $EmailAddress -match '^[^@]+@[^@]+$' ) {
        $Filter = '(&(objectCategory=User)(|(ugaliasusername={0})(proxyaddresses=smtp:{0})))' -f $EmailAddress
      } 
      else { 
        $Filter = ''
      }
      #endregion

    }

  #endregion Building Filter based on parameterset

    $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
    $Searcher.Filter = $Filter

    $User = ( $Searcher.FindOne() ).Properties
  
  }
  
  end {
    return $User
  }
}
