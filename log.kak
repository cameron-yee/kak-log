declare-option str kak_log_log_fn

define-command kak-log -docstring "log current selection" %{
    execute-keys "yo%opt{kak_log_log_fn}(<esc>Pa)<esc>"
    try %{ format }
}

declare-option str kak_log_execute_command
declare-option str kak_log_execute_options
declare-option str kak_log_file_path

define-command kak-execute-file -params .. -docstring "run command and output stdout to new buffer" %{
    set-option global kak_log_file_path %val{buffile}

    # :doc buffers fifo-buffers
    # see rc/grep.kak
    evaluate-commands %sh{
        output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-log.XXXXXXXX)/fifo
        mkfifo ${output}
        ( { trap - INT QUIT; eval "$kak_opt_kak_log_execute_command $kak_opt_kak_log_file_path $@" 2>&1 | tr -d '\r'; } > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null

        printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
            edit! -fifo ${output} *kak-log*
            set-option buffer jump_current_line 0
            hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname ${output}) }}
        }"
    }
}

complete-command kak-execute-file command
