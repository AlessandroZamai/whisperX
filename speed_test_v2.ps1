# WhisperX Speed Test: CPU vs GPU (Fixed Version)
# This script tests the same audio file with both CPU and GPU to compare speeds

$testFile = "C:\Users\T888918\Downloads\drive-download-20251008T175910Z-1-001\Consolidated Call Recordings\20250911_1853_2066945490024.mp3"
$outputFolder = "C:\Users\T888918\Downloads\drive-download-20251008T175910Z-1-001\Consolidated Call Recordings\Transcripts"
$hfToken = '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'
$model = 'turbo'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WhisperX Speed Test: CPU vs GPU" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test file: 20250911_1853_2066945490024.mp3" -ForegroundColor Yellow
Write-Host "File size: 0.12 MB" -ForegroundColor Yellow
Write-Host ""

# Test 1: CPU Processing
Write-Host "TEST 1: CPU Processing (compute_type int8)" -ForegroundColor Green
Write-Host "-------------------------------------------" -ForegroundColor Green
$cpuStart = Get-Date

$cpuCommand = "whisperx `"$testFile`" --compute_type int8 --output_format txt --output_dir `"$outputFolder\cpu_test`" --model $model"

try {
    Invoke-Expression $cpuCommand 2>&1 | Out-Null
    $cpuEnd = Get-Date
    $cpuDuration = ($cpuEnd - $cpuStart).TotalSeconds
    Write-Host "✓ CPU Processing Time: $([math]::Round($cpuDuration, 2)) seconds" -ForegroundColor Green
} catch {
    Write-Host "✗ CPU test failed: $($_.Exception.Message)" -ForegroundColor Red
    $cpuDuration = $null
}

Write-Host ""
Write-Host ""

# Test 2: GPU Processing (if available)
Write-Host "TEST 2: GPU Processing (compute_type float16)" -ForegroundColor Green
Write-Host "----------------------------------------------" -ForegroundColor Green
$gpuStart = Get-Date

$gpuCommand = "whisperx `"$testFile`" --output_format txt --output_dir `"$outputFolder\gpu_test`" --model $model"

try {
    Invoke-Expression $gpuCommand 2>&1 | Out-Null
    $gpuEnd = Get-Date
    $gpuDuration = ($gpuEnd - $gpuStart).TotalSeconds
    Write-Host "✓ GPU Processing Time: $([math]::Round($gpuDuration, 2)) seconds" -ForegroundColor Green
} catch {
    Write-Host "✗ GPU test failed (GPU may not be available)" -ForegroundColor Yellow
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    $gpuDuration = $null
}

Write-Host ""
Write-Host ""

# Results Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SPEED TEST RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($cpuDuration) {
    Write-Host "CPU Time:  $([math]::Round($cpuDuration, 2)) seconds" -ForegroundColor White
}

if ($gpuDuration) {
    Write-Host "GPU Time:  $([math]::Round($gpuDuration, 2)) seconds" -ForegroundColor White
    
    if ($cpuDuration -and $gpuDuration) {
        Write-Host ""
        if ($gpuDuration -lt $cpuDuration) {
            $speedup = $cpuDuration / $gpuDuration
            Write-Host "WINNER: GPU is $([math]::Round($speedup, 2))x FASTER than CPU" -ForegroundColor Green
            Write-Host ""
            Write-Host "Recommendation: Use GPU mode for batch processing" -ForegroundColor Yellow
            Write-Host "Command: --compute_type float16 --device cuda" -ForegroundColor Cyan
        } else {
            $speedup = $gpuDuration / $cpuDuration
            Write-Host "WINNER: CPU is $([math]::Round($speedup, 2))x FASTER than GPU" -ForegroundColor Green
            Write-Host ""
            Write-Host "Recommendation: Use CPU mode for batch processing" -ForegroundColor Yellow
            Write-Host "Command: --compute_type int8" -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "GPU:       Not available or failed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Recommendation: Use CPU mode" -ForegroundColor Yellow
    Write-Host "Command: --compute_type int8" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Note: For 3,999 files, the time difference will be:" -ForegroundColor Gray
if ($cpuDuration -and $gpuDuration) {
    $totalCpuTime = $cpuDuration * 3999 / 3600
    $totalGpuTime = $gpuDuration * 3999 / 3600
    Write-Host "  CPU: ~$([math]::Round($totalCpuTime, 1)) hours" -ForegroundColor Gray
    Write-Host "  GPU: ~$([math]::Round($totalGpuTime, 1)) hours" -ForegroundColor Gray
    $timeSaved = [math]::Abs($totalCpuTime - $totalGpuTime)
    Write-Host "  Time saved: ~$([math]::Round($timeSaved, 1)) hours" -ForegroundColor Gray
} elseif ($cpuDuration) {
    $totalCpuTime = $cpuDuration * 3999 / 3600
    Write-Host "  CPU: ~$([math]::Round($totalCpuTime, 1)) hours" -ForegroundColor Gray
}

Write-Host ""
pause
