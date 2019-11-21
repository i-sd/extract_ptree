#!/bin/bash
#=============================================================================
#
# Extracts the specified process and its descendant processes from the
# "ps -efHj" command results.
#
# Usage:
#   $(basename $0) [option] pid
#
#   -p  displays a list of process IDs only
#   -h  display this help and exit
#
#=============================================================================
set -u;

function extract_ptree()
{
    local root_pid="$1";
    local -a pid_list=($1);
    local is_root_found="false";

    while read line;
      do
        # cehck end condition
        if [[ ${#pid_list[@]} == 0 ]]; then
            break;
        fi

        # show header [UID PID PPID ...]
        if [[ $line =~ ^UID[\ ]+PID ]]; then
            echo "$line";
            continue;
        fi

        local pid ppid;
        if [[ $line =~ ^[^\ ]+[\ ]+([^\ ]+)[\ ]+([^\ ]+).*$ ]]; then
            pid=${BASH_REMATCH[1]};
            ppid=${BASH_REMATCH[2]};

            if [[ $is_root_found != "true" ]]; then
                if [[ $pid == $root_pid ]]; then
                    is_root_found="true";
                    echo "$line";
                fi
                continue;
            fi

            while ((${#pid_list[@]} > 0));
              do
                local last_index=$((${#pid_list[@]}-1));
                local target_pid="${pid_list[$last_index]}";

                if [[ $ppid == $target_pid ]]; then
                    # push back
                    pid_list=("${pid_list[@]}" "$pid");
                    echo "$line";
                    break;
                else
                    # pop back
                    pid_list=("${pid_list[@]:0:$last_index}");
                fi
            done;
        fi
    done < <(cat -);

    if [[ $is_root_found == "true" ]]; then
        return 0;
    else
        echo "specified PID($root_pid) was not found." >&2;
        return 1;
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    function usage()
    {
        echo "";
        echo 'Extracts the specified process and its descendant processes from the "ps -efHj" command results.';
        echo "";
        echo "Usage:";
        echo "  $(basename $0) [option] pid";
        echo "";
        echo "  -p  displays a list of process IDs only";
        echo "  -h  display this help and exit";
        echo "";
        exit 1;
    }

    # perse options
    declare pid_only=0;
    while getopts ":ph" OPT;
    do
        case $OPT in
            p) pid_only=1;;
            h|*) usage;;
        esac;
    done;
    shift $((OPTIND-1));

    declare pid="${1:-}";
    if [[ $pid == "" ]]; then
        usage;
    fi

    declare status;
    if ((pid_only == 1)); then
        ps -efHj --no-headers | extract_ptree "$pid" | awk '{print $2}' | tr '\n' ' ';
        status=${PIPESTATUS[1]};
        echo "";
    else
        ps -efHj | extract_ptree "$pid";
        status=${PIPESTATUS[1]};
    fi
    exit $status;
fi



