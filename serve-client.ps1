# Driver AI - Client Mobile Web App Preview Server (PowerShell)
param(
    [string]$RootPath = "C:\Users\vv925\.gemini\antigravity\scratch\driver-ai\client-preview",
    [int]$Port = 8091
)

# Load assembly if needed
Add-Type -AssemblyName System.Web

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")

try {
    $listener.Start()
    Write-Host "🚀 Driver AI Client App running at http://localhost:$Port/"
    Write-Host "Press Ctrl+C to stop the server."

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $url = $request.RawUrl
        # Default document
        if ($url -eq "/" -or $url -eq "") {
            $url = "/index.html"
        }

        # Remove query string
        $qIdx = $url.IndexOf('?')
        if ($qIdx -ge 0) { $url = $url.Substring(0, $qIdx) }

        # Unescape/Decode URL path
        $decodedUrl = [System.Uri]::UnescapeDataString($url)
        $filePath = $decodedUrl.Replace('/', [System.IO.Path]::DirectorySeparatorChar).TrimStart([System.IO.Path]::DirectorySeparatorChar)
        
        $fullPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($RootPath, $filePath))

        # Security check: Ensure requested path starts with RootPath
        if (-not $fullPath.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $response.StatusCode = 403
            $response.Close()
            continue
        }

        if (Test-Path $fullPath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
            $contentType = switch ($ext) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript; charset=utf-8" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".svg"  { "image/svg+xml" }
                default { "application/octet-stream" }
            }

            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            $response.ContentType = $contentType
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("File Not Found")
            $response.ContentType = "text/plain"
            $response.ContentLength64 = $errBytes.Length
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    }
} catch {
    Write-Error $_
} finally {
    if ($null -ne $listener) {
        $listener.Stop()
    }
}
