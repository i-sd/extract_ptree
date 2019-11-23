# extract_ptree
Extracts the specified process and its descendant processes from the "ps -efHj" command results.
This script is made with bash and developed on Ubuntu 18.04.

## Usege

```bash
extract_ptree.sh [option] pid

  -p  displays a list of process IDs only
  -h  display this help and exit
```

## Example
The following process is started for explanation.

```bash
$ (sleep 600& (sleep 500& wait)& sleep 300 & wait)&
[1] 12706
```

Displays the process tree.

```bash
$ extract_ptree.sh -p 12706
UID        PID  PPID  PGID   SID  C STIME TTY          TIME CMD
ishijima 12706 20413 12706 20413  0 00:12 pts/1    00:00:00           -bash
ishijima 12707 12706 12706 20413  0 00:12 pts/1    00:00:00             sleep 600
ishijima 12708 12706 12706 20413  0 00:12 pts/1    00:00:00             -bash
ishijima 12710 12708 12706 20413  0 00:12 pts/1    00:00:00               sleep 500
ishijima 12709 12706 12706 20413  0 00:12 pts/1    00:00:00             sleep 300
```

Displays only processes.
```bash
$ extract_ptree.sh -p 12706
12706 12707 12708 12710 12709
```

## License
This script is under the MIT Licence.
