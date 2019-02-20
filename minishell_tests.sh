#!/usr/bin/env bash

### STATS DECLARATION ###

TOTAL_TESTS=0
SUCCESS_TESTS=0

### CHECK FUNCTION ###

compare ()
{
    if [ "$1" = "$2" ] && [ "$3" = "$4" ]; then
        printf "\033[1;32mSuccess test %d (%s)\n\033[0m" $TOTAL_TESTS "$5"
        SUCCESS_TESTS=$((SUCCESS_TESTS+1))
    else
        printf "\033[1;31mFail test %d (%s)\n\033[0m" $TOTAL_TESTS "$5"
        printf "\033[1;29mMysh output: \n\033[0m"
        printf "\033[1;29m================\n\033[0m"
        printf "\033[1;29m%s\n\033[0m" "$1"
        printf "\033[1;29m================\n\033[0m"
        printf "\033[1;29mMysh return value %s\n\n\033[0m" "$3"
        printf "\033[1;29mTcsh output:\n\033[0m"
        printf "\033[1;29m================\n\033[0m"
        printf "\033[1;29m%s\n\033[0m" "$2"
        printf "\033[1;29m================\n\033[0m"
        printf "\033[1;29mTcsh return value %s \n\n\033[0m" "$4"
    fi
    TOTAL_TESTS=$((TOTAL_TESTS+1))
}

execute ()
{
    MYSH=$(echo "$1"| ./mysh 2>&1)
    RET_MYSH=$(echo $?)
    if [ "$2" = "1" ]; then
        TCSH=$(echo "$1" | env -i tcsh 2>&1)
    else
        TCSH=$(echo "$1" | tcsh 2>&1)
    fi
    RET_TCSH=$(echo $?)

    compare "$MYSH" "$TCSH" "$RET_MYSH" "$RET_TCSH" "$1"
}

printf "\033[1;36m=== MINISHELL FUNCTIONAL TESTS ===\033[0m\n\n"

### BASICS TESTS ###

printf "\n\033[1;33m=== MINISHELL BASICS TESTS ===\033[0m\n\n"

execute "" "0"
execute "a" "0"
execute "ls -l" "0"
execute "exit" "0"
execute "cd ; pwd" "0"
execute "cat toto" "0"
execute "exitt" "0"

### SPACES AND TABS TESTS ###

printf "\n\033[1;33m=== MINISHELL SPACES AND TABS TESTS ===\033[0m\n\n"

#only spaces
execute "    " "0"
execute "     ls             -l      -all     " "0"
#only tabs
execute "\tls\t-l\t-all\t" "0"
#tabs and spaces
execute "\tls      \t   -l  \t-all      \t   " "0"

### CD TESTS ###

printf "\n\033[1;33m=== MINISHELL CD TESTS ===\033[0m\n\n"

execute "cd / ; pwd" "0"
execute "cd toto tata" "0"
execute "cd fail_dir" "0"
execute "unsetenv HOME ; cd" "1"
execute "unsetenv OLDPWD ; cd -" "1"

### ENV TESTS ###

printf "\n\033[1;33m=== MINISHELL ENV TESTS ===\033[0m\n\n"

execute "setenv _toto tata" "0"
execute "setenv 8toto tata" "0"
execute "setenv toto tata titi" "0"
execute "setenv toto= tata" "0"
execute "setenv toto9 tata" "0"
execute "setenv Toto9" "0"
execute "setenv Toto" "0"
execute "setenv Abc Abc" "0"
execute "setenv Zbc Zbc" "0"
execute "setenv abc abc" "0"
execute "setenv zbc Zbc" "0"
execute "unsetenv" "0"
execute "unsetenv tototototototo" "0"
execute "unsetenv PATH" "0"
execute "unsetenv PATH HOME OLDPWD PWD LESS" "0"

### EXIT TESTS ###

printf "\n\033[1;33m=== MINISHELL EXIT TESTS ===\033[0m\n\n"

#basics
execute "exit 0" "0"
execute "exit 1" "0"
execute "exit -1" "0"
execute "exit 999999" "0"
execute "exit -999999" "0"
execute "exit -abc" "0"
execute "exit abc" "0"
execute "exit -18abc" "0"

#advance
execute "exit 12; ls" "0"
execute "exit 12; exit 123" "0"
execute "exit 12; exit -a123" "0"
execute "exit -" "0"

### WITHOUT PATH TESTS ###

printf "\n\033[1;33m=== MINISHELL WITHOUT PATH TESTS ===\033[0m\n\n"

execute "unsetenv PATH ; /bin/ls /" "1"

### PIPE TESTS ###

printf "\n\033[1;33m=== MINISHELL PIPE TESTS ===\033[0m\n\n"

execute "ls / | wc -l | cat -e" "0"
execute "ls / | cat -e | cat -e | cat -e | cat -e | cat -e" "0"
execute "ls / | cat -e | cat -e" "0"
execute "ls /|cat -e|cat -e" "0"

### PERMISSIONS AND EXECUTION TESTS ###

printf "\n\033[1;33m=== MINISHELL PERMISSIONS AND EXECUTION TESTS ===\033[0m\n\n"

execute "mysh" "0"
execute "../bin/ls" "0"
execute "./bin/ls" "0"
execute "/bin/ls" "0"
execute "./lib" "0"

### SEMICOLON TESTS ###

printf "\n\033[1;33m=== MINISHELL SEMICOLON TESTS ===\033[0m\n\n"

execute "ls ; ls ; ls ; ls ; ls ; ls ; ls" "0"
execute "ls;ls;ls;ls;ls;ls;ls" "0"
execute "ls;exit 34;ls" "0"

### OTHER TESTS ###

printf "\n\033[1;33m=== OTHER TESTS ===\033[0m\n\n"

execute "\0" "0"
execute "unsetenv PATH; setenv PATH /bin/ ; ls /" "0"
execute "./ls" "0"

### RESULT TESTS ###

printf "\n\033[1;34m=== MINISHELL RESULT TESTS ===\033[0m\n"

printf "\n\033[1;34mSuccess: %d/%d\n\033[0m" $SUCCESS_TESTS $TOTAL_TESTS
printf "\033[1;34mFailed: %d/%d\033[0m\n\n" $((TOTAL_TESTS-SUCCESS_TESTS)) $TOTAL_TESTS

printf "\033[1;36m=== MINISHELL FUNCTIONAL TESTS ===\033[0m\n\n"
