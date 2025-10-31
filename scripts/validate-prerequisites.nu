#!/usr/bin/env nu

def main [] {
    print $"(ansi cyan_bold)=== Validating Prerequisites ===(ansi reset)\n"
    
    mut all_checks_passed = true
    
    if (check_git) {
        print $"(ansi green)✓ Git is installed(ansi reset)"
    } else {
        print $"(ansi red_bold)✗ Git is not installed(ansi reset)"
        print $"  Install from: (ansi cyan)https://git-scm.com/(ansi reset)\n"
        $all_checks_passed = false
    }
    
    if (check_python) {
        print $"(ansi green)✓ Python is installed(ansi reset)"
    } else {
        print $"(ansi red_bold)✗ Python is not installed(ansi reset)"
        print $"  Install from: (ansi cyan)https://www.python.org/(ansi reset)\n"
        $all_checks_passed = false
    }
    
    if (check_scoop) {
        print $"(ansi green)✓ Scoop is installed(ansi reset)"
    } else {
        print $"(ansi red_bold)✗ Scoop is not installed(ansi reset)"
        print $"  Install with PowerShell:"
        print $"  (ansi cyan)Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser(ansi reset)"
        print $"  (ansi cyan)Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression(ansi reset)\n"
        $all_checks_passed = false
    }
    
    let symlink_check = check_symlink_permission
    if $symlink_check.can_create {
        print $"(ansi green)✓ Symlink permissions available(ansi reset)"
    } else {
        print $"(ansi yellow)⚠ Symlink permissions may be limited(ansi reset)"
        if $symlink_check.is_admin {
            print $"  Running as Administrator - symlinks will work(ansi reset)"
        } else if $symlink_check.dev_mode {
            print $"  Developer Mode is enabled - symlinks will work(ansi reset)"
        } else {
            print $"  (ansi yellow_bold)Warning: You may need to enable Developer Mode or run as Administrator(ansi reset)"
            print $"  Enable Developer Mode: Settings → Privacy & Security → For developers → Developer Mode\n"
        }
    }
    
    print ""
    
    if $all_checks_passed {
        print $"(ansi green_bold)✓ All prerequisites are installed!(ansi reset)\n"
        exit 0
    } else {
        print $"(ansi red_bold)✗ Some prerequisites are missing. Please install them and try again.(ansi reset)\n"
        exit 1
    }
}

def check_git []: nothing -> bool {
    (which git | is-not-empty)
}

def check_python []: nothing -> bool {
    let has_python = (which python | is-not-empty)
    let has_python3 = (which python3 | is-not-empty)
    $has_python or $has_python3
}

def check_scoop []: nothing -> bool {
    (which scoop | is-not-empty)
}

def check_symlink_permission []: nothing -> record {
    let is_admin = (check_is_admin)
    let dev_mode = (check_developer_mode)
    
    {
        can_create: ($is_admin or $dev_mode),
        is_admin: $is_admin,
        dev_mode: $dev_mode
    }
}

def check_is_admin []: nothing -> bool {
    let result = (^net session | complete)
    $result.exit_code == 0
}

def check_developer_mode []: nothing -> bool {
    let reg_path = "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock"
    let reg_key = "AllowDevelopmentWithoutDevLicense"
    
    let result = (^reg query $reg_path /v $reg_key | complete)
    
    if $result.exit_code == 0 {
        ($result.stdout | str contains "0x1")
    } else {
        false
    }
}
