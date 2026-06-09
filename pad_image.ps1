Add-Type -AssemblyName System.Drawing
$srcPath = "$PWD\assets\icon\app_icon.png"
$destPath = "$PWD\assets\icon\splash_icon.png"
$srcImg = [System.Drawing.Image]::FromFile($srcPath)
$newWidth = [int]($srcImg.Width * 1.6)
$newHeight = [int]($srcImg.Height * 1.6)
$bmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$x = [int](($newWidth - $srcImg.Width) / 2)
$y = [int](($newHeight - $srcImg.Height) / 2)
$g.DrawImage($srcImg, $x, $y, $srcImg.Width, $srcImg.Height)
$bmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$srcImg.Dispose()
Write-Host "Image padded successfully!"
