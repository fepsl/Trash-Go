$input_json = $input | Out-String | ConvertFrom-Json
$cmd = $input_json.tool_input.command

$dangerous = @(
    "git push --force",
    "git push -f ",
    "git push -f$",
    "git reset --hard",
    "git clean -f",
    "git branch -D",
    "git checkout --",
    "git restore"
)

foreach ($pattern in $dangerous) {
    if ($cmd -match [regex]::Escape($pattern) -or $cmd -match $pattern) {
        Write-Host "BLOCKED by git-guardrails: '$cmd' e um comando destrutivo e foi bloqueado. Execute manualmente no terminal se tiver certeza."
        exit 2
    }
}
exit 0
