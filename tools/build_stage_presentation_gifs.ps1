param([switch]$PortalStability, [switch]$QuietUiStability, [switch]$CampfireTitle)

function Get-GifSubBlocksEnd([byte[]]$Bytes, [int]$Start) {
    $cursor = $Start
    while ($cursor -lt $Bytes.Length) {
        $length = [int]$Bytes[$cursor]
        $cursor++
        if ($length -eq 0) { return $cursor }
        $cursor += $length
    }
    throw 'Truncated GIF sub-blocks.'
}

Add-Type -AssemblyName PresentationCore
if (([int]$PortalStability.IsPresent + [int]$QuietUiStability.IsPresent + [int]$CampfireTitle.IsPresent) -gt 1) { throw 'Choose one review set.' }
$reviewFolder = if ($CampfireTitle) { 'campfire_title_2026_10_03' } elseif ($QuietUiStability) { 'quiet_ui_stability_2026_10_03' } elseif ($PortalStability) { 'portal_stability_2026_10_03' } else { 'stage_presentation_2026_10_03' }
$reviewDirectory = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ("..\art_source\review\ui\" + $reviewFolder)))
$modes = if ($CampfireTitle) { @('campfire') } elseif ($QuietUiStability) { @('title','loading') } elseif ($PortalStability) { @('comparison') } else { @('grasp','maw','loading') }
foreach ($mode in $modes) {
    $encoder = [System.Windows.Media.Imaging.GifBitmapEncoder]::new()
    $frames = @(Get-ChildItem -LiteralPath (Join-Path $reviewDirectory ($mode+'_frames')) -Filter 'frame_*.png' | Sort-Object Name)
    if ($frames.Count -eq 0) { throw "No captured frames for $mode" }
    foreach ($frame in $frames) {
        $stream = [IO.File]::OpenRead($frame.FullName)
        try {
            $bitmap = [System.Windows.Media.Imaging.BitmapImage]::new()
            $bitmap.BeginInit()
            $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $bitmap.StreamSource = $stream
            $bitmap.EndInit()
            $metadata = [System.Windows.Media.Imaging.BitmapMetadata]::new('gif')
            $metadata.SetQuery('/grctlext/Delay',[UInt16]10)
            $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($bitmap,$null,$metadata,$null))
        } finally { $stream.Dispose() }
    }
    $outputPath = Join-Path $reviewDirectory ($mode+'_native.gif')
    $output = [IO.File]::Create($outputPath)
    try { $encoder.Save($output) } finally { $output.Dispose() }
    # Normalize encoded delays and add the standard GIF infinite-loop extension.
    $bytes = [IO.File]::ReadAllBytes($outputPath)
    $paletteBytes = 0
    if (($bytes[10] -band 0x80) -ne 0) { $paletteBytes = 3*[int][Math]::Pow(2,(($bytes[10] -band 0x07)+1)) }
    $insertAt = 13+$paletteBytes
    # Parse actual blocks. Searching all bytes for GCE signatures can match
    # compressed pixel data, corrupt frames and report phantom delays.
    $count = 0
    $cursor = $insertAt
    while ($cursor -lt $bytes.Length) {
        $marker = $bytes[$cursor]
        if ($marker -eq 0x3B) { break }
        if ($marker -eq 0x21) {
            if ($bytes[$cursor+1] -eq 0xF9) {
                if ($bytes[$cursor+2] -ne 4) { throw 'Invalid GIF control block.' }
                $bytes[$cursor+4] = 10
                $bytes[$cursor+5] = 0
                $count++
            }
            $cursor = Get-GifSubBlocksEnd $bytes ($cursor+2)
        } elseif ($marker -eq 0x2C) {
            $localPaletteBytes = 0
            if (($bytes[$cursor+9] -band 0x80) -ne 0) {
                $localPaletteBytes = 3*[int][Math]::Pow(2,(($bytes[$cursor+9] -band 0x07)+1))
            }
            $cursor = Get-GifSubBlocksEnd $bytes ($cursor+11+$localPaletteBytes)
        } else { throw "Unexpected GIF block at byte $cursor" }
    }
    if ($count -ne $frames.Count) { throw "Unexpected GIF frame count for $mode : $count" }
    $loop = [byte[]]@(0x21,0xFF,0x0B,0x4E,0x45,0x54,0x53,0x43,0x41,0x50,0x45,0x32,0x2E,0x30,0x03,0x01,0x00,0x00,0x00)
    $result = [IO.MemoryStream]::new()
    try {
        $result.Write($bytes,0,$insertAt)
        $result.Write($loop,0,$loop.Length)
        $result.Write($bytes,$insertAt,$bytes.Length-$insertAt)
        [IO.File]::WriteAllBytes($outputPath,$result.ToArray())
    } finally { $result.Dispose() }
    "Built $outputPath ($count frames)"
}
