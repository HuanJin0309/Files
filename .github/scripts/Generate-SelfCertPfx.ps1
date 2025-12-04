# Copyright (c) Files Community
# Licensed under the MIT License.
# Abstract:
#  This script generates a self-signed certificate for the temporary packaging as a pfx file.

# 步骤1：修改 param() 块，补充 CI 调用时用到的 -Subject 和 -ValidityDays 参数
param(
    # 原有必选参数：证书输出路径（CI 中通过 -Destination 传入）
    [Parameter(Mandatory=$true)]  # 标记为必选，避免未传路径导致报错
    [string]$Destination = "",

    # 新增参数1：证书主题（CI 中通过 -Subject "CN=Files Sideload Test" 传入）
    # 默认值设为原脚本的 "CN=Files"，保持兼容性
    [string]$Subject = "CN=Files",

    # 新增参数2：证书有效期（天数，CI 中通过 -ValidityDays 365 传入）
    # 默认值设为 30 天（测试用推荐短期，避免长期风险）
    [int]$ValidityDays = 30
)

# 完整正确的证书生成逻辑
$CertFriendlyName = "FilesApp_SelfSigned"
$CertStoreLocation = "Cert:\CurrentUser\My"

$cert = New-SelfSignedCertificate `
    -Type CodeSigningCert `  # 推荐用 CodeSigningCert，兼容性更好
    -Subject $Subject `
    -KeyUsage DigitalSignature `  # 格式正确，反引号衔接
    -FriendlyName $CertFriendlyName `
    -CertStoreLocation $CertStoreLocation `
    -NotAfter (Get-Date).AddDays($ValidityDays)

# 步骤3：保留原有的证书导出逻辑（无需修改）
# 获取证书的字节流（PKCS12 格式，即 PFX 格式）
$certificateBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12)
# 将字节流写入目标路径（$Destination 为 CI 传入的证书输出路径）
[System.IO.File]::WriteAllBytes($Destination, $certificateBytes)

# 可选：添加成功日志，便于 CI 调试
Write-Host "Self-signed certificate generated successfully! "
Write-Host "Path: $Destination "
Write-Host "Subject: $Subject "
Write-Host "Validity: $ValidityDays days (from current date)"
