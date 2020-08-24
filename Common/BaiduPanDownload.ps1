
function Get-ShareUrl {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [String]$Input
    )
    $Link = $Input
    # if ([String]::IsNullOrEmpty($Link)){
    #     Write-Host "输入为空 初始化"
    #     $Link = "链接：               https://pan.baidu.com/s/1_iTCrR6QdjnCRsSjDBKh7w 提取码1234 2"
    # https://pan.baidu.com/s/1_iTCrR6QdjnCRsSjDBKh7w 2046
    # }
    $Link = "https://pan.baidu.com/s/1_iTCrR6QdjnCRsSjDBKh7w 2046"
    $pattern = "(?:\w+\s*[：\:]?\s*)?(?:https://)?(?:pan.baidu.com/s/)?\b(?<Flag>[a-zA-Z0-9_\-]+)\b\s+(?:\w+\s*[：\:]?\s*)?(?<Pwd>[a-zA-Z0-9]{4})\b\s*\w*$"
    if ($Link -match $pattern -and ![String]::IsNullOrEmpty($matches.Flag)) {
        $Script:PanShareString = "https://pan.baidu.com/s/$($matches.Flag) 提取码: $($matches.Pwd)"
        return $true
    }
    else {
        $Script:PanShareString = ""
        return $false
    }
}

function Get-DownloadUrl {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [String]$ShareUrl
    )
    #$Forms = @{ link = "" }
    #$Forms.link = $Script:PanShareString
    # $response = Invoke-RestMethod -URI "https://pan.naifei.cc/new/panshare.php" -Body $Forms -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $postData = "link=$($Script:PanShareString)"
    Get-PostResponse -url "https://pan.naifei.cc/new/panshare.php" -data $postData
    #$res = [object[]]$Script:response | Out-String
    Write-Host "========================"
    Write-Host $Script:response
    Write-Host "========================"
    pause
    exit
    if ($response.code -eq 200) {
        Write-Host $response.datas
    }
    else {
        Write-Host "获取下载链接失败，请检查输入的百度云链接是否可用。"
        Write-Host $response
    }
}

function Get-PostResponse {
    param(
        [string]$url = $null,
        [string]$data = $null,
        [System.Net.NetworkCredential]$credentials = $null,
        [string]$contentType = "application/x-www-form-urlencoded",
        [string]$codePageName = "UTF-8",
        [string]$userAgent = $null
    );

    if ( $url -and $data ) {
        [System.Net.WebRequest]$webRequest = [System.Net.WebRequest]::Create($url);
        $webRequest.ServicePoint.Expect100Continue = $false;
        if ( $credentials ) {
            $webRequest.Credentials = $credentials;
            $webRequest.PreAuthenticate = $true;
        }
        $webRequest.ContentType = $contentType;
        $webRequest.Method = "POST";
        if ( $userAgent ) {
            $webRequest.UserAgent = $userAgent;
        }

        $enc = [System.Text.Encoding]::GetEncoding($codePageName);
        [byte[]]$bytes = $enc.GetBytes($data);
        $webRequest.ContentLength = $bytes.Length;
        [System.IO.Stream]$reqStream = $webRequest.GetRequestStream();
        $reqStream.Write($bytes, 0, $bytes.Length);
        $reqStream.Flush();

        Write-Host "============================================================================================================"

        $resp = $webRequest.GetResponse();
        $rs = $resp.GetResponseStream();
        [System.IO.StreamReader]$sr = New-Object System.IO.StreamReader -argumentList $rs;
        Write-Host $sr
        $sr.ReadToEnd();

        Write-Host "lailallllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll"
        Write-Output $sr
        Read-Host "=="
        exit
        $Script:response = $dongxi
    }
}

$clipboard = Get-Clipboard
if ($clipboard | Get-ShareUrl) {
    Write-Host "从剪切板读取到百度盘下载链接 $($Script:PanShareString)"
    Get-DownloadUrl $Script:PanShareString
}
else {
    do {
        try {
            [ValidatePattern('(?:\w+\s*[：\:]?\s*)?(?:https://)?(?:pan.baidu.com/s/)?\b(?<Flag>[a-zA-Z0-9_\-]+)\b\s+(?:\w+\s*[：\:]?\s*)?(?<Pwd>[a-zA-Z0-9]{4})\b\s*\w*$')]$Script:Input = Read-Host "请输入链接"
            if (Get-ShareUrl $Script:Input) {
                Get-DownloadUrl $Script:PanShareString
            }
        }
        catch { }
    } until ($?)
}
