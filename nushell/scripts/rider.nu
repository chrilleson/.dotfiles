#! /usr/bin/env nu

export def main [solution?: string] {
  let rider_path = 'C:\Users\ChristofferLjungqvis\AppData\Local\Programs\Rider\bin\rider64.exe'

  if not ($rider_path | path exists) {
    print $"(ansi red_bold)ERROR: Rider not found at ($rider_path)(ansi reset)"
    exit 1
  }

  let sln_file = if ($solution == null) {
    let sln_files = (ls *.sln | get name)

    if ($sln_files | is-empty) {
      print $"(ansi red_bold)ERROR: No .sln file found in current directory(ansi reset)"
      exit 1
    } else if ($sln_files | length) == 1 {
      $sln_files.0
    } else {
      print $"(ansi yellow)Multiple .sln files found:(ansi reset)"
      $sln_files | each { |file| print $"  - ($file)" }
      print $"\n(ansi yellow)Please specify which solution to open(ansi reset)"
      exit 1
    }
  } else {
    if not ($solution | path exists) {
      print $"(ansi red_bold)ERROR: Solution file not found: ($solution)(ansi reset)"
      exit 1
    }
      $solution
  }

  print $"(ansi cyan)Opening ($sln_file) in Rider...(ansi reset)"

  if $nu.os-info.name == "windows" {
    ^powershell -NoProfile -Command $"Start-Process -FilePath '($rider_path)' -ArgumentList '($sln_file)'"
  } else {
    ^$rider_path $sln_file &
  }
}
