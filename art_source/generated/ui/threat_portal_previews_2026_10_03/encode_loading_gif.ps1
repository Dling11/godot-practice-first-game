Add-Type -AssemblyName PresentationCore,WindowsBase
$gifEncoder = [System.Windows.Media.Imaging.GifBitmapEncoder]::new()
foreach ($pngFrame in (Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'loading_frames') -Filter 'frame_*.png' | Sort-Object Name)) {
    $pngStream = [IO.File]::OpenRead($pngFrame.FullName)
    try {
        $pngDecoder = [System.Windows.Media.Imaging.PngBitmapDecoder]::new($pngStream,[System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
        $metadata = [System.Windows.Media.Imaging.BitmapMetadata]::new('gif')
        $metadata.SetQuery('/grctlext/Delay',[uint16]7)
        $gifEncoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($pngDecoder.Frames[0],$null,$metadata,$null))
    } finally { $pngStream.Dispose() }
}
if ($gifEncoder.Frames.Count -ne 40) { throw 'Expected forty captured frames' }
$gifFile = Join-Path $PSScriptRoot 'loading_king_motion.gif'
$gifStream = [IO.File]::Create($gifFile)
try { $gifEncoder.Save($gifStream) } finally { $gifStream.Dispose() }
$bytes = [IO.File]::ReadAllBytes($gifFile)
$paletteBytes = if (($bytes[10] -band 128) -ne 0) { 3*[int][Math]::Pow(2,1+($bytes[10] -band 7)) } else { 0 }
$insertion = 13+$paletteBytes
# WPF drops requested delays in this environment. Fix timing at actual GIF blocks,
# never by searching compressed data; this changes packaging only, not pixels.
$cursor = $insertion
$timedFrames = 0
while ($cursor -lt $bytes.Length) {
    $marker = $bytes[$cursor]
    if ($marker -eq 59) { break }
    if ($marker -eq 33) {
        if ($bytes[$cursor+1] -eq 249) {
            if ($bytes[$cursor+2] -ne 4) { throw 'Invalid graphics control block' }
            $bytes[$cursor+3] = 4
            $bytes[$cursor+4] = 7
            $bytes[$cursor+5] = 0
            $timedFrames++
        }
        $cursor += 2
    } elseif ($marker -eq 44) {
        $localPalette = if (($bytes[$cursor+9] -band 128) -ne 0) { 3*[int][Math]::Pow(2,1+($bytes[$cursor+9] -band 7)) } else { 0 }
        $cursor += 10+$localPalette+1
    } else { throw "Unexpected GIF block at $cursor" }
    while ($bytes[$cursor] -ne 0) { $cursor += 1+$bytes[$cursor] }
    $cursor++
}
if ($timedFrames -ne 40) { throw "Expected forty timing blocks, found $timedFrames" }
[byte[]]$loopExtension = @(33,255,11,78,69,84,83,67,65,80,69,50,46,48,3,1,0,0,0)
$looped = [byte[]]::new($bytes.Length+$loopExtension.Length)
[Array]::Copy($bytes,0,$looped,0,$insertion)
[Array]::Copy($loopExtension,0,$looped,$insertion,$loopExtension.Length)
[Array]::Copy($bytes,$insertion,$looped,$insertion+$loopExtension.Length,$bytes.Length-$insertion)
[IO.File]::WriteAllBytes($gifFile,$looped)
$verification = [IO.File]::OpenRead($gifFile)
try {
    $decoded = [System.Windows.Media.Imaging.GifBitmapDecoder]::new($verification,[System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
    $delay = $decoded.Frames[0].Metadata.GetQuery('/grctlext/Delay')
    if ($decoded.Frames.Count -ne 40 -or $delay -ne 7) { throw 'Encoded GIF timing verification failed' }
    [pscustomobject]@{Frames=$decoded.Frames.Count; Width=$decoded.Frames[0].PixelWidth; Height=$decoded.Frames[0].PixelHeight; DelayCentiseconds=$delay; Seconds=40*0.07; InfiniteLoop=[Text.Encoding]::ASCII.GetString($looped).Contains('NETSCAPE2.0'); Bytes=$looped.Length} | ConvertTo-Json -Compress
} finally { $verification.Dispose() }
