declare-option str kak_log_log_fn

define-command kak-log -docstring "log current selection" %{
    execute-keys "o%opt{kak_log_log_fn}(%sh{ printf %s $kak_selection })<esc>"
    try %{ format }
}

declare-option str kak_log_execute_command
declare-option str kak_log_execute_options
declare-option str kak_log_file_path

define-command kak-execute-file -docstring "run command and output stdout to new buffer" %{
    set-option global kak_log_file_path %val{buffile}
    edit -scratch 'kak-log'

    nop %sh{ {
        echo "eval -client '$kak_client' \"execute-keys i%sh{$kak_opt_kak_log_execute_command $kak_opt_kak_log_file_path $kak_opt_kak_log_execute_options | tr '\n' ' '}<esc>\"" | kak -p ${kak_session}
        echo "eval -client '$kak_client' 'echo %sh{echo $kak_opt_kak_log_execute_command $kak_opt_kak_log_file_path $kak_opt_kak_log_execute_options}'" | kak -p ${kak_session}
    } > /dev/null 2>&1 < /dev/null & }
}
