<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $WorkSpaceID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $Provider,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $Token

    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Credentials = Get-ChildItem -Path "env:bamboo_$Provider*"

    }
    Process
    {
        New-Item ./TFE_VAR.txt -ItemType file
        ForEach($Credential in $Credentials)
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Pushing $($Credential.Key) variable to Terraform Enterprise Workspace (ID:$WorkSpaceID)"

            try
            {
                $Credential | % {if (($_.key -match "secret") -or ($_.key -match "access")) { $sensitive,$hcl,$keyname = $true,$false,$($_.key.remove(0,7))}else{$sensitive,$hcl,$keyname =  $false,$false,$($_.key.remove(0, 7+$($Provider.length + 1)))}}
		        $Json = @{
                  "data"= @{
                    "type"="vars"
                    "attributes"= @{
                      "key"=$keyname
                      "value"=$Credential.value
                      "category"="terraform"
                      "hcl"=$hcl
                      "sensitive"=$sensitive
                    }
                    "relationships"= @{
                      "workspace"= @{
                        "data"= @{
                          "id"="$WorkSpaceID"
                          "type"="workspaces"
                        }
                      }
                    }
                  }
                } | ConvertTo-Json -Depth 5

                $Post = @{

                    Uri         = "https://app.terraform.io/api/v2/vars"
                    Headers     = @{"Authorization" = "Bearer $Token" } 
                    ContentType = 'application/vnd.api+json'
                    Method      = 'Post'
                    Body        = $Json
                    ErrorAction = 'stop'

                }

                $Result = (Invoke-RestMethod @Post).data
		        Write-Host $Result.id
		        Write-host $Result
		        Write-Output "$keyname=$($Result.id)" |out-file -Append ./TFE_VAR.txt

            }
            catch
            {

                $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
                $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
                $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title

                Write-Host "$($MyInvocation.MyCommand.Name): $Message"

            }
            finally
            {
            
                Write-Host "$($MyInvocation.MyCommand.Name): Variable push complete"

            }

        }

    }
    End
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

    }
