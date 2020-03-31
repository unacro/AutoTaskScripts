<##
 # Author: Cyanashi(imwhtl@gmail.com)
 # Version: 1.0.0
 # Last_Updated: 2020-03-31
 # Description: GetAVUPData A站VTB数据统计 AcFun Vtuber Idol Statistics
 #>

$Script:listFile = "list.json"
$current = Get-Date -Format 'yyyyMMdd_HHmmss'
$filename = "AcFun_Vtuber_Data_$($current).csv"

Split-Path -Parent $MyInvocation.MyCommand.Definition | Set-Location
function Get-VtuberInfo {
    [CmdletBinding()]
    param (
        $uid
    )
    $URI = "https://www.acfun.cn/u/$($uid).aspx"
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36"
    $response = Invoke-WebRequest -URI $URI -UseBasicParsing -UserAgent $UserAgent | Select-Object -ExpandProperty Content
    $userInfo = (($response -split "UPUser")[1] -split "var ")[0].Trim(' =') | ConvertFrom-Json
    return $userInfo
}
function Get-VtuberList {
    $VtuberArray = @()
    Get-Content $Script:listFile -Encoding UTF8 | ConvertFrom-Json | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
        $VtuberArray += Get-VtuberInfo $_
    }
    return $VtuberArray
}

$count = 0
Get-VtuberList | Sort-Object followedCount -Descending | ForEach-Object {
    $count++
    $uid = $_.userId
    $username = $_.username
    $follower_count = $_.followedCount
    $bio = $_.signature.Replace("`n", " ")
    $avatar = $_.userImg
    $username | Select-Object `
    @{n = "排名"; e = { $count } }, `
    @{n = "uid"; e = { $uid } }, `
    @{n = "用户名"; e = { $username } }, `
    @{n = "粉丝数"; e = { $follower_count } }, `
    @{n = "简介"; e = { $bio } }, `
    @{n = "头像"; e = { $avatar } } `
} | Export-Csv $filename -Encoding UTF8 -NoTypeInformation
