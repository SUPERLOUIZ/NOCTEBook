$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:3000/')
$listener.Start()
Write-Output "Servidor en http://localhost:3000"
while ($listener.IsListening) {
    $context = $listener.GetContext()
    $path = $context.Request.Url.LocalPath
    if ($path -eq '/') { $path = '/index.html' }
    $filePath = 'C:\Users\SuperLouiz\Documents\REPO\PROJECT' + $path.Replace('/', '\')
    if (Test-Path $filePath) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $contentType = switch ($ext) {
            '.html' { 'text/html; charset=utf-8' }
            '.js'   { 'application/javascript; charset=utf-8' }
            '.css'  { 'text/css; charset=utf-8' }
            '.json' { 'application/json; charset=utf-8' }
            '.svg'  { 'image/svg+xml' }
            '.png'  { 'image/png' }
            '.webmanifest' { 'application/manifest+json' }
            default { 'application/octet-stream' }
        }
        $context.Response.ContentType = $contentType
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $context.Response.StatusCode = 404
    }
    $context.Response.Close()
}
