Add-Type -AssemblyName PresentationCore
$reviewDirectory = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\art_source\review\ui\stage_presentation_2026_10_03'))
foreach ($mode in @('grasp','maw','loading')) {
    $encoder = [System.Windows.Media.Imaging.GifBitmapEncoder]::new()
    $frames = @(Get-ChildItem -LiteralPath (Join-Path $reviewDirectory ($mode+'_frames')) -Filter 'frame_*.png' | Sort-Object Name)
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
    $count = 0
    for ($index=0; $index -lt $bytes.Length-8; $index++) {
        if ($bytes[$index] -eq 0x21 -and $bytes[$index+1] -eq 0xF9 -and $bytes[$index+2] -eq 0x04) {
            $bytes[$index+4] = 10
            $bytes[$index+5] = 0
            $count++
        }
    }
    if ($count -ne $frames.Count) { throw "Unexpected GIF frame count for $mode : $count" }
    $paletteBytes = 0
    if (($bytes[10] -band 0x80) -ne 0) { $paletteBytes = 3*[int][Math]::Pow(2,(($bytes[10] -band 0x07)+1)) }
    $insertAt = 13+$paletteBytes
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
