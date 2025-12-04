# Copyright (c) Files Community
# Licensed under the MIT License.
# Abstract:
#  This script generates a self-signed certificate for the temporary packaging as a pfx file.

param(
    # 仅保留必要参数：输出路径、有效期（有效期仍可通过CI传递，不影响）
    [Parameter(Mandatory=$true)]
    [string]$Destination = "",
    [int]$ValidityDays = 365
)

# 完整正确的证书生成逻辑
$CertFriendlyName = "FilesApp_SelfSigned"
$CertStoreLocation = "Cert:\CurrentUser\My"
$DnsName = "Files.Sideload"

$cert = New-SelfSignedCertificate `
    -Type Custom `
    -DnsName $DnsName `
    -KeyUsage DigitalSignature `
    -FriendlyName $CertFriendlyName `
    -CertStoreLocation $CertStoreLocation `
    -NotAfter (Get-Date).AddDays($ValidityDays) `
    -TextExtension @(
        "2.5.29.37={text}1.3.6.1.5.5.7.3.3"
    )

# 步骤3：保留原有的证书导出逻辑（无需修改）
# 获取证书的字节流（PKCS12 格式，即 PFX 格式）
$certificateBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12)
# 将字节流写入目标路径（$Destination 为 CI 传入的证书输出路径）
[System.IO.File]::WriteAllBytes($Destination, $certificateBytes)

# 可选：添加成功日志，便于 CI 调试
Write-Host "Self-signed certificate generated successfully! "
Write-Host "Path: $Destination "
Write-Host "Subject: $DnsName "
Write-Host "Validity: $ValidityDays days (from current date)"
