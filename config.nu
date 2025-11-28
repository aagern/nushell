$env.PATH = (
    $env.PATH
    | split row (char esep)
    | append [
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
        "/Users/alex/.cargo/bin"
        # ... your paths here
    ]
    | str trim
    | where {|i| $i | path exists }
    | uniq
)

$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 5_000_000
$env.config.show_banner = false

# ALT+SHIFT+R to see all history commands
$env.config.menus ++= [
    {
        # List all unique successful commands
        name: working_dirs_cd_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 23
        }
        style: {
            text: green
            selected_text: green_reverse
        }
        source: {|buffer, position|
            open $nu.history-path
            | query db "SELECT DISTINCT(cwd) FROM history ORDER BY id DESC"
            | get CWD
            | into string
            | where $it =~ $buffer
            | compact --empty
            | each {
                if ($in has ' ') { $'"($in)"' } else {}
                | {value: $in}
            }
        }
    }
]
$env.config.keybindings ++= [
    {
        name: "working_dirs_cd_menu"
        modifier: alt_shift
        keycode: char_r
        mode: emacs
        event: { send: menu name: working_dirs_cd_menu}
    }
]

# переключение между папками по частям их названий в стиле zsh
$env.config.completions.algorithm = "Fuzzy" 

# FZF
$env.config.keybindings ++= [
    {
        name: fzf_files
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
            send: executehostcommand
            cmd: "
              let fzf_ctrl_t_command = \"fd --type=file | fzf --preview 'bat --color=always --style=full --line-range=:500 {}'\";
              let result = nu -c $fzf_ctrl_t_command;
              commandline edit --append $result;
              commandline set-cursor --end
            "
          }
        ]
    }
]

# для Quick Selection с CTRL+SHIFT+SPACE:
$env.config.table.header_on_separator = true
$env.config.footer_mode = "always"

# config.nu
#
# Installed by:
# version = "0.108.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R
