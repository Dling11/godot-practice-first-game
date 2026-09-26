param([switch]$ShieldV2, [switch]$Activation, [switch]$Slow, [switch]$Native)
# Review-only GIF from the six unchanged-King/native-aura PNG captures.
Add-Type -AssemblyName PresentationCore

$reviewDirectory = Join-Path $PSScriptRoot '..\art_source\review\characters\king\unbroken_vow_2026_09_27'
$reviewDirectory = [System.IO.Path]::GetFullPath($reviewDirectory)
if ($ShieldV2) { $reviewDirectory = $reviewDirectory.Replace('unbroken_vow_', 'unbroken_vow_v2_') }
if ($Activation) { $reviewDirectory = $reviewDirectory.Replace('unbroken_vow_', 'unbroken_vow_activation_') }
$outputPath = Join-Path $reviewDirectory 'unbroken_vow_activation.gif'
$encoder = [System.Windows.Media.Imaging.GifBitmapEncoder]::new()
$delays = @(12, 10, 8, 9, 15, 35)
$frameOrder = @(1, 2, 3, 4, 5, 6)
if ($ShieldV2) {
    $frameOrder = @(1, 2, 3, 4, 5, 6, 5, 4, 5, 6, 5, 4)
    $delays = @(8, 8, 9, 18, 18, 18, 18, 18, 18, 18, 18, 38)
}
$frameNames = @($frameOrder | ForEach-Object { 'preview_frame_{0:D2}.png' -f $_ })
if ($Activation) {
    $timeline = Get-Content -Raw (Join-Path $reviewDirectory 'timeline.json') | ConvertFrom-Json
    $suffix = if ($Native) { '_native' } else { '_large' }
    $frameNames = @($timeline | ForEach-Object { $_.file + $suffix + '.png' })
    $frameOrder = @(1..$frameNames.Length)
    $delays = @($timeline | ForEach-Object { if ($Slow) { $_.slow_delay } else { $_.delay } })
    $outputName = if ($Native) { 'activation_native.gif' } elseif ($Slow) { 'activation_slow.gif' } else { 'activation.gif' }
    $outputPath = Join-Path $reviewDirectory $outputName
}

for ($index = 1; $index -le $frameOrder.Length; $index++) {
    $framePath = Join-Path $reviewDirectory $frameNames[$index - 1]
    $stream = [System.IO.File]::OpenRead($framePath)
    try {
        $bitmap = [System.Windows.Media.Imaging.BitmapImage]::new()
        $bitmap.BeginInit()
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.StreamSource = $stream
        $bitmap.EndInit()
        $metadata = [System.Windows.Media.Imaging.BitmapMetadata]::new('gif')
        $metadata.SetQuery('/grctlext/Delay', [UInt16]$delays[$index - 1])
        $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($bitmap, $null, $metadata, $null))
    }
    finally {
        $stream.Dispose()
    }
}

$output = [System.IO.File]::Create($outputPath)
try {
    $encoder.Save($output)
}
finally {
    $output.Dispose()
}
$bytes = [System.IO.File]::ReadAllBytes($outputPath)
$frameIndex = 0
for ($offset = 0; $offset -lt $bytes.Length - 8; $offset++) {
    if ($bytes[$offset] -eq 0x21 -and $bytes[$offset + 1] -eq 0xF9 -and $bytes[$offset + 2] -eq 0x04) {
        if ($frameIndex -ge $delays.Length) { break }
        $delay = [UInt16]$delays[$frameIndex]
        $bytes[$offset + 4] = [byte]($delay -band 0xFF)
        $bytes[$offset + 5] = [byte](($delay -shr 8) -band 0xFF)
        $frameIndex++
    }
}
if ($frameIndex -ne $frameOrder.Length) { throw "Unexpected GIF control block count: $frameIndex" }
$paletteBytes = 0
if (($bytes[10] -band 0x80) -ne 0) {
    $paletteBytes = 3 * [int][Math]::Pow(2, (($bytes[10] -band 0x07) + 1))
}
$insertAt = 13 + $paletteBytes
$loopExtension = [byte[]]@(0x21,0xFF,0x0B,0x4E,0x45,0x54,0x53,0x43,0x41,0x50,0x45,0x32,0x2E,0x30,0x03,0x01,0x00,0x00,0x00)
$looped = [System.IO.MemoryStream]::new()
try {
    $looped.Write($bytes, 0, $insertAt)
    $looped.Write($loopExtension, 0, $loopExtension.Length)
    $looped.Write($bytes, $insertAt, $bytes.Length - $insertAt)
    [System.IO.File]::WriteAllBytes($outputPath, $looped.ToArray())
}
finally {
    $looped.Dispose()
}
Write-Output "Built $outputPath"
