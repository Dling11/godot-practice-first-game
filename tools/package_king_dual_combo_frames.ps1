param([string]$ReviewFolder = 'king_dual_combo_drawing_2026_10_06')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$reviewRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\art_source\review\combat'))
$packRoot = [IO.Path]::GetFullPath((Join-Path $reviewRoot $ReviewFolder))
if (-not $packRoot.StartsWith($reviewRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) {
    throw 'ReviewFolder must stay inside combat review artifacts.'
}
$manifest = Get-Content -LiteralPath (Join-Path $packRoot 'manifest.json') -Raw | ConvertFrom-Json
if ($manifest.frame_count -ne 260 -or $manifest.frames.Count -ne 260) { throw 'Expected all 260 authored poses.' }
$utf8 = [Text.UTF8Encoding]::new($false)
$sheetRoot = Join-Path $packRoot 'sheets'
New-Item -ItemType Directory -Force -Path $sheetRoot | Out-Null
$frameWidth = [int]$manifest.export_size[0]
$frameHeight = [int]$manifest.export_size[1]
$cellWidth = $frameWidth+16
$cellHeight = $frameHeight+46
$headerHeight = 110
$phaseRows = @(@(1,2,3,4),@(5,6,7),@(8,9,10),@(11,12,13))
$phaseNames = @('WIND-UP','STRIKE','STOP / release attack','CONTINUE / next combo hit')
$titleFont = [Drawing.Font]::new('Segoe UI',22,[Drawing.FontStyle]::Bold)
$labelFont = [Drawing.Font]::new('Segoe UI',13,[Drawing.FontStyle]::Bold)
$noteFont = [Drawing.Font]::new('Segoe UI',12)
$white = [Drawing.Brushes]::White
$muted = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(166,188,196))
$line = [Drawing.Pen]::new([Drawing.Color]::FromArgb(66,83,93),1)
$embedded = @()
$ids = @{}
foreach ($record in $manifest.frames) {
    if ($ids.ContainsKey($record.id)) { throw "Duplicate frame ID $($record.id)" }
    $ids[$record.id] = $true
    $imagePath = Join-Path $packRoot $record.file
    $decoded = [Drawing.Bitmap]::new($imagePath)
    try {
        if ($decoded.Width -ne $frameWidth -or $decoded.Height -ne $frameHeight) { throw "Unexpected image size: $($record.id)" }
    } finally { $decoded.Dispose() }
    $embedded += [ordered]@{
        id=$record.id; facing=$record.facing; attack=$record.attack_number
        name=$record.attack_name; frame=$record.frame_number; phase=$record.phase
        image='data:image/png;base64,'+[Convert]::ToBase64String([IO.File]::ReadAllBytes($imagePath))
    }
}
$sheetPaths = @()
try {
    foreach ($facing in @('right','left','up','down')) {
        for ($cut=1;$cut -le 5;$cut++) {
            $frames = @($manifest.frames | Where-Object { $_.facing -eq $facing -and $_.attack_number -eq $cut } | Sort-Object frame_number)
            if ($frames.Count -ne 13) { throw "Incomplete attack $facing/$cut" }
            $name = $frames[0].attack_name.Replace('_',' ')
            $sheet = [Drawing.Bitmap]::new($cellWidth*4,$headerHeight+$cellHeight*4)
            $graphics = [Drawing.Graphics]::FromImage($sheet)
            try {
                $graphics.Clear([Drawing.Color]::FromArgb(38,51,57))
                $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
                $graphics.DrawString("TWINSTEEL / $($facing.ToUpper()) / ATTACK $cut - $name",$titleFont,$white,16,12)
                $graphics.DrawString('Draw over these installed poses. Use the frame ID when sending a correction.',$noteFont,$muted,16,52)
                $graphics.DrawString('After STRIKE, choose STOP or CONTINUE. These are separate endings.',$noteFont,$muted,16,76)
                for ($row=0;$row -lt 4;$row++) {
                    for ($column=0;$column -lt $phaseRows[$row].Count;$column++) {
                        $number = $phaseRows[$row][$column]
                        $record = $frames[$number-1]
                        $x = $column*$cellWidth
                        $y = $headerHeight+$row*$cellHeight
                        $graphics.DrawRectangle($line,$x+4,$y+4,$cellWidth-8,$cellHeight-8)
                        $graphics.DrawString("$($record.id) / $($phaseNames[$row])",$labelFont,$white,$x+12,$y+10)
                        $frame = [Drawing.Bitmap]::new((Join-Path $packRoot $record.file))
                        try { $graphics.DrawImageUnscaled($frame,$x+8,$y+38) } finally { $frame.Dispose() }
                    }
                    if ($row -gt 0) {
                        $x = 3*$cellWidth+20
                        $y = $headerHeight+$row*$cellHeight+80
                        $hint = @('','Then choose one ending.','F08-F10 settle to idle.','F11-F13 link to the next hit.')[$row]
                        $graphics.DrawString($hint,$noteFont,$muted,$x,$y)
                    }
                }
                $relative = "sheets/$facing-attack-{0:D2}.png" -f $cut
                $sheet.Save((Join-Path $packRoot $relative),[Drawing.Imaging.ImageFormat]::Png)
                $sheetPaths += $relative
            } finally { $graphics.Dispose(); $sheet.Dispose() }
        }
    }
} finally {
    $titleFont.Dispose(); $labelFont.Dispose(); $noteFont.Dispose()
    $muted.Dispose(); $line.Dispose()
}
$json = ConvertTo-Json -InputObject $embedded -Depth 5 -Compress
$html = @'
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Twinsteel - draw a frame correction</title>
<style>
*{box-sizing:border-box}body{margin:0;background:#162127;color:#edf4f6;font:15px system-ui,sans-serif}
main{max-width:1080px;margin:auto;padding:24px}h1{font-size:24px;margin:0 0 8px}
p{color:#b7cbd3;line-height:1.55}button,select,input{font:inherit;border:1px solid #546b78;border-radius:6px;background:#26363f;color:#edf4f6;padding:8px;cursor:pointer}
button:hover,button.selected{background:#39535f;border-color:#b3ced9}.tools{display:flex;flex-wrap:wrap;align-items:center;gap:10px;margin:14px 0}
.frames{display:grid;grid-template-columns:repeat(13,minmax(44px,1fr));gap:5px;margin:12px 0}
.frames button{padding:8px 0;font-size:13px}.phase{font-weight:600;color:#dceef4}
canvas{display:block;max-width:100%;height:auto;margin:auto;border:1px solid #546b78;touch-action:none;cursor:crosshair}
.stage{background:#202e35;padding:12px;border-radius:8px}a{color:#bce4f4}small{color:#b7cbd3}
input[type=color]{width:42px;padding:2px;height:35px}input[type=range]{width:110px}
@media(max-width:650px){main{padding:12px}.frames{grid-template-columns:repeat(7,1fr)}}
</style></head><body><main>
<h1>Twinsteel / sketch a correction</h1>
<p>260 installed pose frames: five attacks, thirteen frames each, four facings. Choose a frame, draw over it, then save the sketch and attach it in our chat. Its frame ID is printed in the image.</p>
<div class="tools"><label>Facing <select id="facing"><option value="right">Right / D</option><option value="left">Left / A</option><option value="up">Up / W</option><option value="down">Down / S</option></select></label>
<label>Attack <select id="attack"><option value="1">1 - Double thrust</option><option value="2">2 - Crosscut</option><option value="3">3 - Return cut</option><option value="4">4 - Hopping spin</option><option value="5">5 - Springing X</option></select></label>
<a id="sheet" href="">Open all 13 frames of this attack</a></div>
<div class="frames" id="frames"></div><p class="phase" id="phase"></p>
<div class="tools"><label>Pen <input id="color" type="color" value="#a8ed3b"></label>
<label>Width <input id="width" type="range" min="1" max="12" value="3"></label>
<button id="undo">Undo stroke</button><button id="clear">Clear this frame</button><button id="save">Save sketch PNG</button></div>
<div class="stage"><canvas id="canvas"></canvas></div>
<p>F01-F04 wind up, F05-F07 strike. Then <strong>F08-F10 stop</strong> OR <strong>F11-F13 continue the combo</strong>. The two endings are alternatives, not thirteen consecutive playback steps.</p>
<small>The clean frames show the body, both swords and real finger depth without swing effects. They are authored pose keys, not every interpolated image. F01 is the resource opening; the game's standalone entry can inherit the preceding idle/run pose. <a href="animations/combo_all_facings.gif">Animated in-engine reference with effects</a>. Drawings stay in this tab until you download them; the game's artwork is never changed here.</small>
</main><script>
const records=__FRAMES__;
const phaseNames={wind_up:"Wind-up",strike:"Strike",stop_recovery:"Stop / release attack",combo_link:"Continue / next combo hit"};
const facing=document.getElementById("facing"), attack=document.getElementById("attack");
const canvas=document.getElementById("canvas"),ctx=canvas.getContext("2d");
const histories=new Map(); let selected=5, current=null, image=null, activeStroke=null, loadVersion=0;
const buttons=[];
for(let number=1;number<=13;number++){
 const button=document.createElement("button");button.textContent="F"+String(number).padStart(2,"0");
 button.onclick=()=>{selected=number;loadFrame()};document.getElementById("frames").append(button);buttons.push(button);
}
function redraw(){
 if(!image||!current)return;
 ctx.fillStyle="#263339";ctx.fillRect(0,0,canvas.width,canvas.height);
 ctx.imageSmoothingEnabled=false;ctx.drawImage(image,24,64);
 ctx.fillStyle="#edf4f6";ctx.font="bold 16px system-ui";ctx.fillText(current.id+" / "+current.name.replaceAll("_"," "),16,25);
 ctx.fillStyle="#b7cbd3";ctx.font="13px system-ui";ctx.fillText(phaseNames[current.phase],16,46);
 for(const stroke of histories.get(current.id)||[]){
  ctx.strokeStyle=stroke.color;ctx.lineWidth=stroke.width;ctx.lineCap="round";ctx.lineJoin="round";ctx.beginPath();
  stroke.points.forEach((p,i)=>{if(i===0)ctx.moveTo(p.x,p.y);else ctx.lineTo(p.x,p.y)});
  if(stroke.points.length===1){const p=stroke.points[0];ctx.lineTo(p.x+.01,p.y+.01)}ctx.stroke();
 }
}
function loadFrame(){
 activeStroke=null;image=null;
 current=records.find(r=>r.facing===facing.value&&r.attack===Number(attack.value)&&r.frame===selected);
 const version=++loadVersion,next=new Image();
 document.getElementById("phase").textContent=current.id+" - "+phaseNames[current.phase];
 document.getElementById("sheet").href="sheets/"+current.facing+"-attack-"+String(current.attack).padStart(2,"0")+".png";
 buttons.forEach((b,i)=>b.classList.toggle("selected",i+1===selected));
 next.onload=()=>{if(version!==loadVersion)return;image=next;canvas.width=image.width+48;canvas.height=image.height+88;redraw()};
 next.src=current.image;
}
function point(event){
 const box=canvas.getBoundingClientRect();
 return {x:(event.clientX-box.left)*canvas.width/box.width,y:(event.clientY-box.top)*canvas.height/box.height};
}
canvas.addEventListener("pointerdown",event=>{
 if(!image||event.button!==0)return;event.preventDefault();canvas.setPointerCapture(event.pointerId);
 activeStroke={color:document.getElementById("color").value,width:Number(document.getElementById("width").value),points:[point(event)]};
 if(!histories.has(current.id))histories.set(current.id,[]);histories.get(current.id).push(activeStroke);redraw();
});
canvas.addEventListener("pointermove",event=>{if(activeStroke){activeStroke.points.push(point(event));redraw()}});
for(const name of ["pointerup","pointercancel","lostpointercapture"])canvas.addEventListener(name,()=>{activeStroke=null});
document.getElementById("undo").onclick=()=>{activeStroke=null;(histories.get(current.id)||[]).pop();redraw()};
document.getElementById("clear").onclick=()=>{activeStroke=null;histories.delete(current.id);redraw()};
document.getElementById("save").onclick=()=>{
 if(!image)return;const link=document.createElement("a");link.download=current.id+"_sketch.png";
 link.href=canvas.toDataURL("image/png");link.click();
};
facing.onchange=loadFrame;attack.onchange=loadFrame;loadFrame();
</script></body></html>
'@
[IO.File]::WriteAllText((Join-Path $packRoot 'index.html'),$html.Replace('__FRAMES__',$json),$utf8)
$result = [ordered]@{frame_count=$ids.Count;sheet_count=$sheetPaths.Count;frame_size=@($frameWidth,$frameHeight);offline_drawing_page='index.html';runtime_modified=$false}
[IO.File]::WriteAllText((Join-Path $packRoot 'pack_validation.json'),($result|ConvertTo-Json -Depth 5),$utf8)
if ($sheetPaths.Count -ne 20) { throw 'Missing drawing sheets.' }
'TWINSTEEL_DRAWING_PACK: 260 decoded PNGs, 20 labelled sheets and one self-contained drawing page.'
