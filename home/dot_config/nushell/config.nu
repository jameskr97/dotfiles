$env.config.show_banner = false

# Abbreviate path (e.g., ~/.local/share/chezmoi -> ~/.l/s/chezmoi)
def abbrev_path [] {
    let home = $env.HOME
    let pwd = ($env.PWD | str replace $home "~")
    let parts = ($pwd | split row "/")
    let len = ($parts | length)

    if $len <= 1 {
        $pwd
    } else {
        let abbreviated = ($parts | slice 0..($len - 2) | each { |part|
            if ($part | str starts-with ".") {
                $part | str substring 0..<2  # .l (dot + first char)
            } else if ($part | is-empty) {
                ""
            } else {
                $part | str substring 0..<1  # first char only
            }
        })
        let last = ($parts | last)
        ($abbreviated | append $last | str join "/")
    }
}

# Get git branch
def git_branch [] {
    do { git branch --show-current } | complete | if $in.exit_code == 0 { $in.stdout | str trim } else { "" }
}

# Prompt command
$env.PROMPT_COMMAND = {||
    let user = (whoami | str trim)
    let host = (hostname | str trim)
    let path = (abbrev_path)
    let branch = (git_branch)
    let branch_str = if ($branch | is-empty) { "" } else { $" (ansi grey)($branch)(ansi reset)" }

    $"(ansi green)[($user)@($host)](ansi reset) (ansi blue)($path)(ansi reset)($branch_str) "
}

# Right prompt for command duration
$env.PROMPT_COMMAND_RIGHT = {||
    let duration = $env.CMD_DURATION_MS | into int
    if $duration > 2000 {
        $"(ansi red)($duration / 1000 | math round)s(ansi reset)"
    } else {
        ""
    }
}

# Prompt indicator
$env.PROMPT_INDICATOR = {|| $"(ansi magenta)❯(ansi reset) " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| $"(ansi magenta)❯(ansi reset) " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi green)❮(ansi reset) " }

# Aliases (similar to zsh)
alias ll = ls -l
alias la = ls -la
