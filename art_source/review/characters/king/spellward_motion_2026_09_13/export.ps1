param([string]$Ffmpeg = 'C:/Users/Administrator/.codex/tmp/examiner_ffmpeg/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe')
$ErrorActionPreference = 'Stop'
$proofRoot = $PSScriptRoot
$frameRoot = Join-Path $proofRoot 'frames'
New-Item -ItemType Directory -Force -Path $frameRoot | Out-Null
# Source registration only: preserve one scale per family, full blade bounds and a shared ground anchor.
$clips = @(
    @{name='idle'; scale=56.0/472; fps=3; frames=@(0..3 | ForEach-Object { @{x=($_*543+65);y=118;w=440;h=510;ax=($_*543+285);ay=610} })},
    @{name='walk'; scale=56.0/360; fps=10; frames=@(0..7 | ForEach-Object { $col=$_%4; $row=[math]::Floor($_/4); $sx=[int][math]::Round($col*443.5); $sy=[int][math]::Round($row*443.5); @{x=($sx+40);y=($sy+38);w=400;h=395;ax=($sx+239);ay=($sy+415)} })},
    @{name='swing'; scale=56.0/300; fps=18; frames=@(
        @{x=12;y=15;w=293;h=395;ax=156;ay=395}, @{x=335;y=15;w=280;h=395;ax=478;ay=395},
        @{x=638;y=15;w=290;h=395;ax=791;ay=395}, @{x=985;y=15;w=269;h=395;ax=1122;ay=395},
        @{x=12;y=445;w=291;h=355;ax=145;ay=790}, @{x=318;y=445;w=354;h=355;ax=440;ay=790},
        @{x=692;y=445;w=287;h=355;ax=778;ay=790}, @{x=985;y=445;w=269;h=355;ax=1118;ay=790},
        @{x=12;y=840;w=296;h=380;ax=147;ay=1205}, @{x=340;y=840;w=280;h=380;ax=463;ay=1205},
        @{x=643;y=840;w=290;h=380;ax=796;ay=1205}, @{x=962;y=840;w=285;h=380;ax=1103;ay=1205}
    )}
)
foreach ($clip in $clips) {
    $i=0
    foreach ($frame in $clip.frames) {
        $w=[int][math]::Round($frame.w*$clip.scale); $h=[int][math]::Round($frame.h*$clip.scale)
        $x=[int][math]::Round(80-($frame.ax-$frame.x)*$clip.scale); $y=[int][math]::Round(82-($frame.ay-$frame.y)*$clip.scale)
        $filter="crop=$($frame.w):$($frame.h):$($frame.x):$($frame.y),scale=${w}:${h}:flags=area,pad=160:104:${x}:${y}:color=0x202c34"
        $target=Join-Path $frameRoot ('{0}_{1:D2}.png' -f $clip.name,$i)
        & $Ffmpeg -y -v error -i (Join-Path $proofRoot ($clip.name+'_source.png')) -vf $filter -frames:v 1 $target
        if ($LASTEXITCODE -ne 0) { throw "Frame export failed: $target" }
        $i++
    }
    $sequence=Join-Path $frameRoot ($clip.name+'_%02d.png')
    $native=Join-Path $proofRoot ($clip.name+'_size.gif')
    & $Ffmpeg -y -v error -framerate $clip.fps -i $sequence -filter_complex 'split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=none' -loop 0 $native
    if ($LASTEXITCODE -ne 0) { throw "GIF export failed: $native" }
    $large=Join-Path $proofRoot ($clip.name+'_review.gif')
    & $Ffmpeg -y -v error -i $native -vf 'scale=480:312:flags=neighbor' -loop 0 $large
    if ($LASTEXITCODE -ne 0) { throw "Large GIF export failed: $large" }
    & $Ffmpeg -v error -i $large -f null -
    if ($LASTEXITCODE -ne 0) { throw "GIF decode failed: $large" }
    Write-Output "$($clip.name): $i source frames; both review sizes exported."
}
$clips | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 (Join-Path $proofRoot 'registration.json')
