# WhisperX Speed Test: CPU vs GPU
# This script tests the same audio file with both CPU and GPU to compare speeds

$testFile = "C:\Users\T888918\Downloads\drive-download-20251008T175910Z-1-001\Consolidated Call Recordings\20250911_1853_2066945490024.mp3"
$outputFolder = "C:\Users\T888918\Downloads\drive-download-20251008T175910Z-1-001\Consolidated Call Recordings\Transcripts"
$hfToken = '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'
$model = 'turbo'

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WhisperX Speed Test: CPU vs GPU" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test file: $testFile" -ForegroundColor Yellow
Write-Host ""

# Test 1: CPU Processing
Write-Host "TEST 1: CPU Processing (compute_type int8)" -ForegroundColor Green
Write-Host "-------------------------------------------" -ForegroundColor Green
$cpuStart = Get-Date

$cpuCommand = "whisperx `"$testFile`" --compute_type int8 --output_format txt --output_dir `"$outputFolder`" --model $model --output_file cpu_test"

try {
    Invoke-Expression $cpuCommand
    $cpuEnd = Get-Date
    $cpuDuration = ($cpuEnd - $cpuStart).TotalSeconds
    Write-Host "CPU Processing Time: $([math]::Round($cpuDuration, 2)) seconds" -ForegroundColor Green
} catch {
    Write-Host "CPU test failed: $($_.Exception.Message)" -ForegroundColor Red
    $cpuDuration = $null
}

Write-Host ""
Write-Host ""

# Test 2: GPU Processing (if available)
Write-Host "TEST 2: GPU Processing (compute_type float16)" -ForegroundColor Green
Write-Host "----------------------------------------------" -ForegroundColor Green
$gpuStart = Get-Date

$gpuCommand = "whisperx `"$testFile`" --compute_type float16 --device cuda --output_format txt --output_dir `"$outputFolder`" --model $model --output_file gpu_test"

try {
    Invoke-Expression $gpuCommand
    $gpuEnd = Get-Date
    $gpuDuration = ($gpuEnd - $gpuStart).TotalSeconds
    Write-Host "GPU Processing Time: $([math]::Round($gpuDuration, 2)) seconds" -ForegroundColor Green
} catch {
    Write-Host "GPU test failed (GPU may not be available): $($_.Exception.Message)" -ForegroundColor Yellow
    $gpuDuration = $null
}

Write-Host ""
Write-Host ""

# Results Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SPEED TEST RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($cpuDuration) {
    Write-Host "CPU Time: $([math]::Round($cpuDuration, 2)) seconds" -ForegroundColor White
}

if ($gpuDuration) {
    Write-Host "GPU Time: $([math]::Round($gpuDuration, 2)) seconds" -ForegroundColor White
    
    if ($cpuDuration -and $gpuDuration) {
        $speedup = $cpuDuration / $gpuDuration
        Write-Host ""
        if ($gpuDuration -lt $cpuDuration) {
            Write-Host "GPU is $([math]::Round($speedup, 2))x FASTER than CPU" -ForegroundColor Green
        } else {
            Write-Host "CPU is $([math]::Round(1/$speedup, 2))x FASTER than GPU" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "GPU: Not available or failed" -ForegroundColor Yellow
}

Write-Host ""
pause
