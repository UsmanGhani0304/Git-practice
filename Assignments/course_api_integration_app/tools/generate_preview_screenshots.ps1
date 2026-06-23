Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = Join-Path $root 'screenshots'
New-Item -ItemType Directory -Force -Path $out | Out-Null

function New-Canvas($name) {
    $bmp = New-Object System.Drawing.Bitmap 390, 844
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::FromArgb(247, 250, 252))
    return @{ Bitmap = $bmp; Graphics = $g; Name = $name }
}

function Draw-Text($g, $text, $x, $y, $size, $color, $style = 'Regular') {
    $font = New-Object System.Drawing.Font 'Segoe UI', $size, ([System.Drawing.FontStyle]::$style)
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($color))
    $g.DrawString($text, $font, $brush, $x, $y)
    $font.Dispose()
    $brush.Dispose()
}

function Fill-RoundRect($g, $x, $y, $w, $h, $r, $color) {
    if ($r -le 0) {
        $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($color))
        $g.FillRectangle($brush, $x, $y, $w, $h)
        $brush.Dispose()
        return
    }

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($color))
    $g.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Stroke-RoundRect($g, $x, $y, $w, $h, $r, $color) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $pen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($color), 1)
    $g.DrawPath($pen, $path)
    $pen.Dispose()
    $path.Dispose()
}

function Draw-Input($g, $label, $x, $y, $value = '') {
    Fill-RoundRect $g $x $y 326 56 6 '#FFFFFF'
    Stroke-RoundRect $g $x $y 326 56 6 '#CBD5E1'
    Draw-Text $g $label ($x + 14) ($y + 8) 8 '#64748B'
    if ($value -ne '') {
        Draw-Text $g $value ($x + 14) ($y + 25) 10 '#0F172A'
    }
}

function Draw-Button($g, $label, $x, $y, $w = 326) {
    Fill-RoundRect $g $x $y $w 48 24 '#2563EB'
    Draw-Text $g $label ($x + 105) ($y + 13) 10 '#FFFFFF' 'Bold'
}

function Save-Canvas($canvas) {
    $path = Join-Path $out $canvas.Name
    $canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Graphics.Dispose()
    $canvas.Bitmap.Dispose()
}

$c = New-Canvas 'login.png'
$g = $c.Graphics
Draw-Text $g 'Course Portal' 104 196 20 '#0F172A' 'Bold'
Draw-Text $g 'Usman Ghani | SE-221043' 104 232 11 '#334155'
Draw-Input $g 'Email' 32 300 'usman@example.com'
Draw-Input $g 'Password' 32 372 '••••••••'
Draw-Button $g 'Login' 32 460
Draw-Text $g 'Create an account' 133 522 10 '#2563EB'
Save-Canvas $c

$c = New-Canvas 'course-list.png'
$g = $c.Graphics
Fill-RoundRect $g 0 0 390 84 0 '#FFFFFF'
Draw-Text $g 'Courses' 20 44 17 '#0F172A' 'Bold'
Draw-Text $g 'Refresh' 246 49 9 '#2563EB'
Draw-Text $g 'Logout' 318 49 9 '#2563EB'
$courses = @(
    @('ID: 1', 'Software Engineering Fundamentals', 'Introduction to software requirements, design, testing, and maintenance.'),
    @('ID: 2', 'Mobile Application Development', 'Build responsive mobile interfaces and connect apps with REST APIs.'),
    @('ID: 3', 'Database Systems', 'Practice relational data modeling, SQL queries, and application persistence.')
)
$y = 108
foreach ($course in $courses) {
    Fill-RoundRect $g 18 $y 354 142 8 '#FFFFFF'
    Stroke-RoundRect $g 18 $y 354 142 8 '#E2E8F0'
    Draw-Text $g $course[1] 34 ($y + 18) 12 '#0F172A' 'Bold'
    Draw-Text $g $course[0] 34 ($y + 48) 9 '#475569'
    Draw-Text $g $course[2] 34 ($y + 72) 9 '#475569'
    Draw-Text $g 'Edit   Delete' 276 ($y + 104) 9 '#2563EB'
    $y += 158
}
Fill-RoundRect $g 206 754 156 52 26 '#2563EB'
Draw-Text $g '+ Add Course' 232 768 11 '#FFFFFF' 'Bold'
Save-Canvas $c

$c = New-Canvas 'add-course.png'
$g = $c.Graphics
Fill-RoundRect $g 0 0 390 84 0 '#FFFFFF'
Draw-Text $g 'Add Course' 20 44 17 '#0F172A' 'Bold'
Draw-Input $g 'Course Title' 32 124 'Cloud Computing'
Fill-RoundRect $g 32 204 326 148 6 '#FFFFFF'
Stroke-RoundRect $g 32 204 326 148 6 '#CBD5E1'
Draw-Text $g 'Description' 46 214 8 '#64748B'
Draw-Text $g 'Learn cloud service models, deployment' 46 240 10 '#0F172A'
Draw-Text $g 'models, and API-based integration.' 46 262 10 '#0F172A'
Draw-Button $g 'Add Course' 32 388
Save-Canvas $c

$c = New-Canvas 'edit-course.png'
$g = $c.Graphics
Fill-RoundRect $g 0 0 390 84 0 '#FFFFFF'
Draw-Text $g 'Edit Course' 20 44 17 '#0F172A' 'Bold'
Draw-Input $g 'Course Title' 32 124 'Mobile Application Development'
Fill-RoundRect $g 32 204 326 148 6 '#FFFFFF'
Stroke-RoundRect $g 32 204 326 148 6 '#CBD5E1'
Draw-Text $g 'Description' 46 214 8 '#64748B'
Draw-Text $g 'Build Flutter screens, validate forms,' 46 240 10 '#0F172A'
Draw-Text $g 'and integrate REST APIs for CRUD.' 46 262 10 '#0F172A'
Draw-Button $g 'Save Changes' 32 388
Save-Canvas $c

$c = New-Canvas 'delete-confirmation.png'
$g = $c.Graphics
Fill-RoundRect $g 0 0 390 844 0 '#E2E8F0'
Fill-RoundRect $g 18 110 354 142 8 '#FFFFFF'
Draw-Text $g 'Mobile Application Development' 34 130 12 '#0F172A' 'Bold'
Draw-Text $g 'ID: 2' 34 160 9 '#475569'
Draw-Text $g 'Build responsive mobile interfaces and connect apps with REST APIs.' 34 184 9 '#475569'
Fill-RoundRect $g 36 288 318 190 16 '#FFFFFF'
Draw-Text $g 'Delete Course' 60 318 15 '#0F172A' 'Bold'
Draw-Text $g 'Are you sure you want to delete' 60 362 10 '#334155'
Draw-Text $g '"Mobile Application Development"?' 60 384 10 '#334155'
Draw-Text $g 'Cancel' 190 432 10 '#2563EB' 'Bold'
Fill-RoundRect $g 260 418 72 38 19 '#2563EB'
Draw-Text $g 'Delete' 278 427 9 '#FFFFFF' 'Bold'
Save-Canvas $c
