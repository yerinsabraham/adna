# Final fixes for remaining dropdown issues

$fixes = @{
    "lib\presentation\screens\onboarding\owner_info_screen.dart" = @(
        @{
            Old = "            CustomDropdown<String>(`r`n              label: 'State',`r`n              hint: 'Select state',`r`n              value: _selectedState,`r`n              items: AppConstants.nigerianStates,"
            New = "            CustomDropdown<String>(`r`n              label: 'State',`r`n              hint: 'Select state',`r`n              value: _selectedState,`r`n              items: AppConstants.nigerianStates,`r`n              itemLabel: (item) => item,"
        }
    )
    "lib\presentation\screens\onboarding\bank_account_screen.dart" = @(
        @{
            Old = "            CustomDropdown<String>(`r`n              label: 'Bank Name',`r`n              hint: 'Select bank',`r`n              value: _selectedBank,`r`n              items: AppConstants.nigerianBanks,"
            New = "            CustomDropdown<String>(`r`n              label: 'Bank Name',`r`n              hint: 'Select bank',`r`n              value: _selectedBank,`r`n              items: AppConstants.nigerianBanks,`r`n              itemLabel: (item) => item,"
        }
    )
    "lib\presentation\screens\payments\create_payment_screen.dart" = @(
        @{
            Old = "              CustomDropdown<String>(`r`n                label: 'Cryptocurrency',`r`n                hint: 'Select crypto',`r`n                value: _selectedCryptoType,`r`n                items: AppConstants.cryptoTypes,"
            New = "              CustomDropdown<String>(`r`n                label: 'Cryptocurrency',`r`n                hint: 'Select crypto',`r`n                value: _selectedCryptoType,`r`n                items: AppConstants.cryptoTypes,`r`n                itemLabel: (item) => item,"
        }
    )
}

foreach ($file in $fixes.Keys) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        foreach ($fix in $fixes[$file]) {
            # Simpler approach: just add itemLabel after items line
            $content = $content -replace "items: AppConstants\.nigerianStates,", "items: AppConstants.nigerianStates,`n              itemLabel: (item) => item,"
            $content = $content -replace "items: AppConstants\.nigerianBanks,", "items: AppConstants.nigerianBanks,`n              itemLabel: (item) => item,"
            $content = $content -replace "items: AppConstants\.cryptoTypes,", "items: AppConstants.cryptoTypes,`n                itemLabel: (item) => item,"
        }
        Set-Content -Path $file -Value $content -NoNewline
        Write-Host "Fixed $file" -ForegroundColor Green
    }
}

Write-Host "Done!" -ForegroundColor Cyan
