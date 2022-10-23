# Rest API to CipherTrust Manager using Powershell

$ciphertrustManagerIp = "https://127.0.0.1"

$UrlToken = $ciphertrustManagerIp + "/api/v1/auth/tokens"
$UrlEncrypt = $ciphertrustManagerIp + "/api/v1/crypto/encrypt"
$UrlDecrypt = $ciphertrustManagerIp + "/api/v1/crypto/decrypt"

# Authenticate to CM
$username = "administrator"
$password = "password"
$Body = @{
    grant_type = "password"
    username = $username
    password = $password
}
$response = Invoke-RestMethod -Method 'Post' -Uri $UrlToken -Body $body
$jwt = $response.jwt

$basicAuth = "Bearer " + $jwt
$Headers = @{
	Authorization = $basicAuth
	Accept = 'application/json'
	'Content-Type' = 'application/json'
}

# Request Encrypt
$keyname = "aeskey"
$plaintext = "Hello World"
$plaintextB64 =[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($plaintext))
$aad = "YXV0aGVudGljYXRl"
$Body = @{
	id = $keyname
	plaintext = $plaintextB64
	aad = $aad
} | ConvertTo-Json
$response = Invoke-RestMethod -Uri $UrlEncrypt -Method POST -Headers $headers -Body $body
Write-Host "Plaintext: " $plaintext
Write-Output "v1/crypto/encrypt"
Write-Output "Request:"
Write-Output $Body
Write-Output "Response:"
Write-Output $response | ConvertTo-Json
Write-Host "Ciphertext: " $response.ciphertext

# Request Decrypt
$Body = @{
	id = $keyname
	ciphertext = $response.ciphertext
	aad = $aad
	mode = "gcm"
	iv = $response.iv
	tag = $response.tag
	version = $response.version
} | ConvertTo-Json
$response = Invoke-RestMethod -Uri $UrlDecrypt -Method POST -Headers $headers -Body $body
Write-Output "v1/crypto/decrypt"
Write-Output "Request:"
Write-Output $Body
Write-Output "Response:"
Write-Output $response | ConvertTo-Json
$decryptPlaintext = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($response.plaintext))
Write-Host "Plaintext: " $decryptPlaintext