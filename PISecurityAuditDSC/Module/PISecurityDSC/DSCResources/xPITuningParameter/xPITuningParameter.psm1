function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $PIDataArchive
    )

    Write-Verbose "Connecting to: $($PIDataArchive)"
    $Connection = Connect-PIDataArchive -PIDataArchiveMachineName $PIDataArchive
	Write-Verbose "Getting tuning parameter: $($Name)"
    $TuningParameter = Get-PITuningParameter -Connection $Connection -Name $Name
    if($null -eq $TuningParameter)
    { $Ensure = 'Absent' }
    else
    { Write-Verbose -Message "Name: $($TuningParameter.Name). Value: $($TuningParameter.Value). Default: $($TuningParameter.Default)." }
    return @{
				    Name = $TuningParameter.Name;
                    Default = $TuningParameter.Default;
                    Ensure = $Ensure;
                    Value = $TuningParameter.Value;
                    PIDataArchive = $PIDataArchive;
            }
<# return @{
               Name = [System.String]
               Default = [System.String]
               Ensure = [System.String]
               Value = [System.String]
               PIDataArchive = [System.String]
           } #>
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $Value,

        [parameter(Mandatory = $true)]
        [System.String]
        $PIDataArchive
    )
    
    $Connection = Connect-PIDataArchive -PIDataArchiveMachineName $PIDataArchive
    $TuningParameter = Get-TargetResource -Name $Name -PIDataArchive $PIDataArchive
    $IsDesired = Test-TargetResource -Ensure $Ensure -Name $Name -Value $Value -PIDataArchive $PIDataArchive
    if(!$IsDesired)
    {
        if($Ensure -eq 'Absent')
        { Set-PITuningParameter -Connection $Connection -Name $Name -Value $null }
        else
        { Set-PITuningParameter -Connection $Connection -Name $Name -Value $Value }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $Value,

        [parameter(Mandatory = $true)]
        [System.String]
        $PIDataArchive
    )

    $Result = $false
    $TuningParameter = Get-TargetResource -Name $Name -PIDataArchive $PIDataArchive
    if($TuningParameter.Ensure -eq 'Absent')
    {
        Write-Verbose "$($Name) is null"
        if($Ensure -eq 'Absent')
        { $Result = $true }
        else
        { $Result = $false }
    }
    else
    {
        if($Ensure -eq 'Absent')
        { $Result = $false }
        else
        {
            if($TuningParameter.Value -eq $Value -or ($null -eq $TuningParameter.Value -and $TuningParameter.Default -eq $Value))
            { $Result = $true }
            else 
            { $Result = $false }
        }
    }
    return $Result
}

Export-ModuleMember -Function *-TargetResource