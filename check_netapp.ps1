# Parameters
Param(
  [string]$server,
  [string]$user,
  [string]$password,
  [string]$type
)

# Exit codes
$OK = 0
$WARNING = 1
$CRITICAL = 2
$UNKNOWN = 3

# Create credential object
$secure_pass = $password | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user,$secure_pass)

# Connect function
function connect {
    # Connect to 7-Mode
    if ($type -eq '7-mode') {
        if (!(Connect-NaController -Name $server -HTTP -Debug -Verbose -Credential $credential -ErrorAction SilentlyContinue)) { 
            Write-Host "Unable to connect Data OnTab server $server"
            exit $CRITICAL
        }
    }
    #Connect to CDOT
    elseif ($type -eq 'cdot') {
        if (!(Connect-NcController -Name $server -HTTP -Debug -Verbose -Credential $credential -ErrorAction SilentlyContinue)) { 
            Write-Host "Unable to connect Clustered Data OnTab server $server"
            exit $CRITICAL
        }
    }
}

function check_aggr {
    connect
    # Check 7-mode aggregate
    if ($type -eq '7-mode') {
        $aggregates = Get-NaAggrSpace
        foreach($aggr in $aggregates){
            $aggr_name = $aggr.AggregateName
            $aggr_used = $([math]::round((($aggr.SizeUsed/$aggr.SizeNominal)*100),2))
            Write-Host $aggr_name" is at "$aggr_used"%"
        }
    }
    elseif ($type -eq 'cdot') {
        $aggregates = Get-NcAggrSpace
        foreach($aggr in $aggregates){
            $aggr_name = $aggr.Aggregate
            $aggr_used = $([math]::round((($aggr.UsedIncludingSnapshotReserve/$aggr.AggregateSize)*100),2))
            #$aggr_used = $aggr.PhysicalUsedPercent
            Write-Host $aggr_name" is at "$aggr_used"%"
        }
    }
}

check_aggr

exit $OK