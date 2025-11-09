# PowerShell script to fix common issues in all screens

Write-Host "Fixing screen files..." -ForegroundColor Green

# Fix 1: Replace updateOnboardingData({ with updateOnboardingSection({
Get-ChildItem -Path "lib\presentation\screens\onboarding" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match "updateOnboardingData\(\{") {
        $content = $content -replace "updateOnboardingData\(\{", "updateOnboardingSection({"
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Fixed $($_.Name)" -ForegroundColor Yellow
    }
}

# Fix 2: Add itemLabel to CustomDropdown calls
$files = @(
    "lib\presentation\screens\onboarding\business_info_screen.dart",
    "lib\presentation\screens\onboarding\owner_info_screen.dart",
    "lib\presentation\screens\onboarding\bank_account_screen.dart",
    "lib\presentation\screens\payments\create_payment_screen.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Fix businessTypes dropdown
        $content = $content -replace "CustomDropdown\(\s*label: 'Business Type',\s*hint: 'Select business type',\s*value: _businessType,\s*items: AppConstants\.businessTypes,", "CustomDropdown(label: 'Business Type', hint: 'Select business type', value: _businessType, items: AppConstants.businessTypes, itemLabel: (item) => item,"
        
        # Fix industries dropdown
        $content = $content -replace "CustomDropdown\(\s*label: 'Industry',\s*hint: 'Select industry',\s*value: _industry,\s*items: AppConstants\.industries,", "CustomDropdown(label: 'Industry', hint: 'Select industry', value: _industry, items: AppConstants.industries, itemLabel: (item) => item,"
        
        # Fix states dropdown
        $content = $content -replace "CustomDropdown<String>\(\s*label: 'State',\s*hint: 'Select state',\s*value: _state,\s*items: AppConstants\.nigerianStates,", "CustomDropdown<String>(label: 'State', hint: 'Select state', value: _state, items: AppConstants.nigerianStates, itemLabel: (item) => item,"
        
        # Fix banks dropdown
        $content = $content -replace "CustomDropdown<String>\(\s*label: 'Bank Name',\s*hint: 'Select bank',\s*value: _bankName,\s*items: AppConstants\.nigerianBanks,", "CustomDropdown<String>(label: 'Bank Name', hint: 'Select bank', value: _bankName, items: AppConstants.nigerianBanks, itemLabel: (item) => item,"
        
        # Fix crypto types dropdown
        $content = $content -replace "CustomDropdown<String>\(\s*label: 'Cryptocurrency',\s*hint: 'Select crypto',\s*value: _selectedCrypto,\s*items: AppConstants\.cryptoTypes,", "CustomDropdown<String>(label: 'Cryptocurrency', hint: 'Select crypto', value: _selectedCrypto, items: AppConstants.cryptoTypes, itemLabel: (item) => item,"
        
        Set-Content -Path $file -Value $content -NoNewline
        Write-Host "Fixed dropdowns in $file" -ForegroundColor Yellow
    }
}

# Fix 3: Remove prefixIcon from CustomDropdown calls (not supported)
Get-ChildItem -Path "lib\presentation\screens" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match "prefixIcon:") {
        # Remove prefixIcon lines from CustomDropdown
        $content = $content -replace "\s*prefixIcon:\s*[^,]+,\s*", ""
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Removed prefixIcon from $($_.Name)" -ForegroundColor Yellow
    }
}

# Fix 4: Change type parameter to variant for CustomButton
Get-ChildItem -Path "lib\presentation\screens" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match "type:\s*ButtonType\.") {
        $content = $content -replace "type:\s*ButtonType\.", "variant: ButtonType."
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Fixed ButtonType in $($_.Name)" -ForegroundColor Yellow
    }
}

Write-Host "`nAll fixes applied!" -ForegroundColor Green
Write-Host "Run 'flutter analyze' to check for remaining issues." -ForegroundColor Cyan
