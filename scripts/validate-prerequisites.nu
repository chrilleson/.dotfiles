#!/usr/bin/env nu

def main [] {
    print $"(ansi cyan_bold)=== Validating Prerequisites ===(ansi reset)\n"

    mut all_checks_passed = true

    # Git
    if (which git | is-not-empty) {
        print $"(ansi green)✓ Git is installed(ansi reset)"
    } else {
        print $"(ansi red_bold)✗ Git is not installed(ansi reset)"
        print $"  Install from: (ansi cyan)https://git-scm.com/(ansi reset)\n"
        $all_checks_passed = false
    }

    # Python (required by dotbot)
    if ((which python | is-not-empty) or (which python3 | is-not-empty)) {
        print $"(ansi green)✓ Python is installed(ansi reset)"
    } else {
        print $"(ansi red_bold)✗ Python is not installed(ansi reset)"
        print $"  Install from: (ansi cyan)https://www.python.org/(ansi reset)\n"
        $all_checks_passed = false
    }

    # Scoop
    if (which scoop | is-not-empty) {
        print $"(ansi green)✓ Scoop is installed(ansi reset)"
    } else {
        print $"(ansi red_bold)✗ Scoop is not installed(ansi reset)"
        print $"  Install with PowerShell:"
        print $"  (ansi cyan)Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser(ansi reset)"
        print $"  (ansi cyan)Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression(ansi reset)\n"
        $all_checks_passed = false
    }

    # Symlink permissions (Developer Mode or admin)
    let is_admin = ((^net session | complete).exit_code == 0)
    let dev_mode = (
        let r = (^reg query "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense | complete)
        $r.exit_code == 0 and ($r.stdout | str contains "0x1")
    )

    if $is_admin {
        print $"(ansi green)✓ Symlink permissions available (running as Administrator)(ansi reset)"
    } else if $dev_mode {
        print $"(ansi green)✓ Symlink permissions available (Developer Mode enabled)(ansi reset)"
    } else {
        print $"(ansi yellow)⚠ Symlink permissions may be limited(ansi reset)"
        print $"  Enable Developer Mode: Settings → Privacy & Security → For developers → Developer Mode\n"
    }

    print ""

    if $all_checks_passed {
        print $"(ansi green_bold)✓ All prerequisites met(ansi reset)\n"
    } else {
        print $"(ansi red_bold)✗ Some prerequisites are missing. Please install them and try again.(ansi reset)\n"
        exit 1
    }
}
