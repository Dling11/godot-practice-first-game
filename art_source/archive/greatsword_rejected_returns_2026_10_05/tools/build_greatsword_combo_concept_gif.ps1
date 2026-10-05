param([ValidateSet('a','b','c')][string]$Choice)
Add-Type -AssemblyName PresentationCore
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$reviewPath = Join-Path $projectPath ('art_source/review/combat/greatsword_combo_choices_2026_10_04/' + $Choice)

$timeline = @(Get-Content -LiteralPath (Join-Path $reviewPath 'motion_timeline.json') -Raw | ConvertFrom-Json)
$encoder = [System.Windows.Media.Imaging.GifBitmapEncoder]::new()
$delays = @()
for ($index = 0; $index -lt $timeline.Count; $index++) {
    $delay = if ($index + 1 -lt $timeline.Count) { [Math]::Max(1,[Math]::Round(($timeline[$index+1].elapsed_ms-$timeline[$index].elapsed_ms)/10)) } else { 85 }
    $delays += [UInt16]$delay
    $stream = [IO.File]::OpenRead((Join-Path $reviewPath $timeline[$index].file))
    try {
        $bitmap = [System.Windows.Media.Imaging.BitmapImage]::new()
        $bitmap.BeginInit()
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.StreamSource = $stream
        $bitmap.EndInit()
        $metadata = [System.Windows.Media.Imaging.BitmapMetadata]::new('gif')
        $metadata.SetQuery('/grctlext/Delay',$delays[$index])
        $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($bitmap,$null,$metadata,$null))
    } finally { $stream.Dispose() }
}
$outputPath = Join-Path $reviewPath 'motion.gif'
$output = [IO.File]::Create($outputPath)
try { $encoder.Save($output) } finally { $output.Dispose() }
$bytes = [IO.File]::ReadAllBytes($outputPath)
$paletteBytes = if (($bytes[10] -band 0x80) -ne 0) { 3*[int][Math]::Pow(2,(($bytes[10] -band 7)+1)) } else { 0 }
$insertAt = 13+$paletteBytes
$cursor = $insertAt
$count = 0
function Skip-SubBlocks([int]$Start) {
    $position = $Start
    while ($position -lt $bytes.Length) {
        $size = [int]$bytes[$position]
        $position++
        if ($size -eq 0) { return $position }
        $position += $size
    }
    throw 'Truncated GIF.'
}
while ($cursor -lt $bytes.Length) {
    $marker = $bytes[$cursor]
    if ($marker -eq 0x3B) { break }
    if ($marker -eq 0x21) {
        if ($bytes[$cursor+1] -eq 0xF9) {
            if ($count -ge $delays.Count -or $bytes[$cursor+2] -ne 4) { throw 'Unexpected GIF control block.' }
            $bytes[$cursor+4] = [byte]($delays[$count] -band 0xFF)
            $bytes[$cursor+5] = [byte](($delays[$count] -shr 8) -band 0xFF)
            $count++
        }
        $cursor = Skip-SubBlocks ($cursor+2)
    } elseif ($marker -eq 0x2C) {
        $localPalette = if (($bytes[$cursor+9] -band 0x80) -ne 0) { 3*[int][Math]::Pow(2,(($bytes[$cursor+9] -band 7)+1)) } else { 0 }
        $cursor = Skip-SubBlocks ($cursor+11+$localPalette)
    } else { throw "Unexpected GIF block at $cursor" }
}
if ($count -ne $timeline.Count) { throw "GIF frames differ: $count" }
$loop = [byte[]]@(0x21,0xFF,0x0B,0x4E,0x45,0x54,0x53,0x43,0x41,0x50,0x45,0x32,0x2E,0x30,0x03,0x01,0x00,0x00,0x00)
$result = [IO.MemoryStream]::new()
try {
    $result.Write($bytes,0,$insertAt)
    $result.Write($loop,0,$loop.Length)
    $result.Write($bytes,$insertAt,$bytes.Length-$insertAt)
    [IO.File]::WriteAllBytes($outputPath,$result.ToArray())
} finally { $result.Dispose() }
$decodeStream = [IO.File]::OpenRead($outputPath)
try {
    $decoder = [System.Windows.Media.Imaging.GifBitmapDecoder]::new($decodeStream,[System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
    if ($decoder.Frames.Count -ne $timeline.Count) { throw 'GIF decode verification failed.' }
} finally { $decodeStream.Dispose() }
"GREATSWORD_CONCEPT_GIF verified $count frames: $outputPath"
