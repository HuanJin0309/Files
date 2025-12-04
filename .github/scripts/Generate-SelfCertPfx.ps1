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

# 步骤2：调整证书生成逻辑，引用新增的 -Subject 和 -ValidityDays 参数
$CertFriendlyName = "FilesApp_SelfSigned"  # 证书友好名（保持不变）
$CertStoreLocation = "Cert:\CurrentUser\My"  # 证书存储位置（保持不变）

# 生成自签名证书：
# 1. 用 $Subject 替换原固定的 $CertPublisher（接收 CI 传入的主题）
# 2. 新增 -NotAfter 参数，用 $ValidityDays 控制有效期（从当前时间往后推 $ValidityDays 天）
$cert = New-SelfSignedCertificate `
    -Type Custom `
    -Subject $Subject `  # 关键：引用新增的 -Subject 参数
    -KeyUsage DigitalSignature `
    -FriendlyName $CertFriendlyName `
    -CertStoreLocation $CertStoreLocation `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") `
    -NotAfter (Get-Date).AddDays($ValidityDays)  # 关键：引用新增的 -ValidityDays 参数

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