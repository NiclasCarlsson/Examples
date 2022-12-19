
function New-FormObject {
  <#
    .SYNOPSIS
    Function to create the Controls for a Windows Form.

    .DESCRIPTION
    Function to create the Controls for a Windows Form.
    
    Note: This function is intended to be a work in progress,
          depending of controls and settings needed.

    .PARAMETER InputObject
    InputObject describes the control to be created by the following attributes:
      name, type, xpos, ypos, width, height, text, TabIndex, default, adaption 

    .PARAMETER FormObject
    FormObject is the variable containing the Windows Form under constructions.

    .EXAMPLE
    New-FormObject -InputObject $DefinitionItem -Formobject $objForm
    Describe what this call does

    .NOTES
    System.Windows.Forms Namespace
    https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms?view=netframework-4.8

    .OUTPUTS
    A Windows Form Control.
    
  #>

  param (
    # InputObject
    [PSCustomObject] 
    $InputObject,

    # FormObject 
    [Parameter(Mandatory=$true)]
    $FormObject

  )
        
  begin {
    # Load the assembly for Windows Forms
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing


    # Handle if True or False in Default attribute
    if ( $InputObject.default -eq 'False' ) {
      $InputObject.default = $False
    }
    elseif ( $InputObject.default -eq 'True' ) {
      $InputObject.default = $True
    }
       
  }

  process {
    
  #region Control Basics

    # Create the current Control accordning to Type
    $fObject = New-Object -TypeName $( 'System.Windows.Forms.{0}' -f $InputObject.type )

    # Set Name of control
    $fObject.Name = $InputObject.name

    # Set Location 
    $Location = @{
      X = $InputObject.xpos
      Y = $InputObject.ypos
    }
    $fObject.Location = New-Object -TypeName System.Drawing.Point -Property $Location

    # Set Size
    $Size = @{
      Height = $InputObject.height
      Width  = $InputObject.width
    }
    $fObject.Size = New-Object -TypeName System.Drawing.Size -Property $Size

    # Set Text 
    $fObject.Text = $InputObject.text

    # Set TabIndex
    $fObject.TabIndex = $InputObject.tabindex

    # Not sure if needed
    $fObject.DataBindings.DefaultDataSourceUpdateMode = [System.Windows.Forms.DataSourceUpdateMode]::OnValidation 
  

  #endregion

  #region Settings base on Control Type
    
    Switch ( $InputObject.Type ) { 

      'TabControl' {

        # Handle size for Control
        $Size = @{
          Width  = $FormObject.ClientSize.width
          Height = $FormObject.ClientSize.Height
        }
        $fObject.Size = New-Object -TypeName System.Drawing.Size -Property $Size

        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {
          'bottom' {
              $fObject.Alignment = 'bottom'
          }
          'hidden' {
              $fObject.Visible = $false
          }
        }

      }

      'TabPage' { <# Nothing yet #> }

      'GroupBox' {
        $fObject.Visible = $InputObject.Default
      }

      'Panel' {
        $fObject.Visible = $InputObject.Default
      }

      'Label' {
        # Selected MiddleLeft as default instead of normal TopLeft
        $fObject.TextAlign = 'MiddleLeft'

        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {

          'MultiLine' {
            $fObject.TextAlign = 'TopLeft'
          }

          'SmallText' {
            $fObject.Font =  New-Object System.Drawing.Font('Times New Roman',8,[System.Drawing.FontStyle]::Regular)
          }

          'Bold' {
            $fObject.Font =  New-Object System.Drawing.Font('Times New Roman',10,[System.Drawing.FontStyle]::Bold)
          }

          'Italic' {
            $fObject.Font =  New-Object System.Drawing.Font('Times New Roman',10,[System.Drawing.FontStyle]::Italic)
          }
          
          'Hidden' {
            $fObject.Visible = $False
          }

        }

      }

      'TextBox' {
        
        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {
        
          'Grey' {
            $fObject.BackColor = $FormObject.BackColor
            $fObject.ReadOnly  = $True
          }

          'Hidden' {
            $fObject.Visible = $False
          }

          'LogStyle' {
            $fObject.Multiline = $True
            $fObject.Wordwrap  = $False
            $fObject.BackColor = $FormObject.BackColor
            $fObject.ReadOnly  = $True
            $fObject.Font      = New-Object System.Drawing.Font('Courier New',8,[System.Drawing.FontStyle]::Regular)
          }
  
          'MailStyle' {
            $fObject.Multiline  = $True
            $fObject.Wordwrap   = $False
            $fObject.scrollbars = 'both'
            $fObject.Font       = New-Object System.Drawing.Font('Courier New',8,[System.Drawing.FontStyle]::Regular)
          }

          'MultiLine' {
            $fObject.Multiline     = $True
            $fObject.Wordwrap      = $True
            $fObject.AcceptsReturn = $True
          }
    
          'SmallText' {
            $fObject.Font =  New-Object System.Drawing.Font('Times New Roman',8,[System.Drawing.FontStyle]::Regular)
          }

          'Vertical' {
            $fObject.scrollbars = 'vertical'
          }

          'Autoselect' {
            $fObject.add_GotFocus({ $this.SelectAll() })
            $fObject.add_MouseClick({ $this.SelectAll() })
          }

        }
    
      }

      'ListBox' {
        
        # Add if a default value is specified
        if ( $InputObject.Default.length -gt 0 ) {
          $null = $fObject.Items.Add($InputObject.Default)
        }
        
        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {

          'Grey' {
            $fObject.BackColor = $FormObject.BackColor
          }

          'Hidden' {
            $fObject.Visible = $False
          }

          'Horizontal' { 
            $fObject.HorizontalScrollbar = $true
            $fObject.HorizontalExtent = 1000
          }

          'LogStyle' {
            $fObject.BackColor = $FormObject.BackColor
            $fObject.Font =  New-Object System.Drawing.Font('Courier New',8,[System.Drawing.FontStyle]::Regular)
          }

          'SelectOne' {
            $fObject.SelectionMode = 'One'
          
          }
          
          'SmallText' {
            $fObject.Font =  New-Object System.Drawing.Font('Times New Roman',8,[System.Drawing.FontStyle]::Regular)
          }

          'Retain' {
            # Used by function Set-FormDefaults
          }

        }

      }

      'ListView' {

        # Default setting
        $fObject.View = 'Details' 
        $null = $fObject.AutoResizeColumns('HeaderSize')

        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {
          
          'Hidden' {
            $fObject.Visible = $False
          }

        }
      
      }
    
      'CheckBox' {
        
        if ( $InputObject.Default -eq $True ) {
          $fObject.CheckState = 'Checked'
        }
        else {
          $fObject.CheckState = 'Unchecked'
        }

        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {
          
          'Hidden' {
            $fObject.Visible = $False
          }

          'ResetOnCheckChanged' {
            # Resets the backcolor of the controls parent
            $fObject.add_CheckedChanged( { ($this.Parent).ResetBackColor() } )
          }

        }

      }

      'RadioButton' {
        $fObject.TabStop = $True
        $fObject.UseVisualStyleBackColor = $True
        $fObject.Checked = $InputObject.default 

        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {

          'TopCenter' {
            $fObject.CheckAlign = 'TopCenter'
          }

          'TopLeft' {
            $fObject.CheckAlign = 'TopLeft'
          }

          'ResetOnCheckChanged' {
            # Resets the backcolor of the controls parent
            $fObject.add_CheckedChanged( { ($this.Parent).ResetBackColor() } )
          }

          'hidden' {
            $fObject.Visible = $false
          }
        
        }

      }

      'ComboBox' {

        # Text is used to point to the Array with Items
        # if its not a list in a string, i.e. containing ','
        if ( $InputObject.Text -match '^[^,]+$' ) {
          $fItemArray = ( Get-Variable -Name $InputObject.Text ).Value
        }

        # At count greater then 1 $text is the array
        elseif ( $InputObject.Text -match '.+' ) {
          $fItemArray = $InputObject.Text -split ','
        }

        # Otherwise we consider it false
        else {
          $fItemArray = @()
        }

        # if the array does not contain default value add it.
        # value of type [int] is presumed to be selected index.
        if ( $InputObject.default -notmatch '^[-0-9]+$' -and $fItemArray -notcontains $InputObject.default ) {
          $fItemArray += $InputObject.default
        }

        # in this we set text to null due to the defaults later on
        $fObject.Text = $Null

        # Adding the items to list
        if ( $fItemArray ) {
          ForEach ($Item in $fItemArray ) {
            [void] $fObject.Items.Add($Item)
          }
        }

        # Set Default as the preselected item
        if ( $InputObject.Default -match '^[-0-9]+$' ) {
          $fObject.SelectedIndex = $InputObject.default
        }
        elseif ( $InputObject.default.length -gt 0 ) {
          $fObject.SelectedIndex = $fItemArray.IndexOf($InputObject.Default)
        }

        $fObject.AutoCompleteMode = 'SuggestAppend'
        $fObject.AutoCompleteSource = 'ListItems'

        # Handle type specific adaptions
        switch -Regex ( $InputObject.Adaption ) {
          
          'Hidden' {
            $fObject.Visible = $False
          }

          'Autoselect' {
            $fObject.add_GotFocus({ $this.SelectAll() })
            $fObject.add_MouseClick({ $this.SelectAll() })
          }

          'ReadOnly' {
            $fObject.DropDownStyle = 'DropDownList'
          }

          'Sorted' {
            $fObject.Sorted = $true
          }

        }

      }

      'Button' {

        # The Default value for a Button is the action it takes on clicked.
        $default = $InputObject.default
        $fAction = [Scriptblock]::Create("&$default")
        $fObject.Add_Click($fAction)

        switch -Regex ( $InputObject.Adaption ) {
          
          # for this object SystemColours are allowed in the format '<lightgreen>'
          '<(.+)>' {
            $fObject.BackColor = [System.Drawing.Color]::$($Matches[1])
          }

          'Hidden' {
            $fObject.Visible = $False
          }

          'Flat' {
            $fObject.flatstyle = 'Flat'
          }

        }

      }

      'Trackbar' {
        if ( $InputObject.default -match '^Min([0-9]+)Max([0-9]+)$' ) {
          $fObject.Minimum = $Matches[1]
          $fObject.Maximum = $Matches[2]
        }
      }

      'DateTimePicker' {
        switch -Regex ( $InputObject.Adaption ) {

          'Short' {
            # https://msdn.microsoft.com/en-us/library/system.windows.forms.datetimepickerformat%28v=vs.110%29.aspx
            $fObject.Format = 'short' 
          }

        }

      }

      'ProgressBar' {
        
        switch -Regex ( $InputObject.Adaption ) {
        
          'Solid' {
            $fObject.Style = 'Continuous' 
          }

          'Hidden'{
            $fObject.Visible = $False
          }

        }
      }

      'DataGridView' {
        $fObject.Visible = $InputObject.Default
      }
    
    }

  #endregion                
        
  }

  end {
    Return $fObject
  }

}
