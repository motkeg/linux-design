# Assignment 1

Deadline: **03/03/2016** (last updated on 25/02/2016), submission is in pairs.

Details of submitter 1: **John Doe <johndoe@dotcom.com>, ID 123456789**

Details of submitter 2: **Jane Doe <janedoe@dotcom.com>, ID 987654321**

---

Solutions to all tasks below should be `bash` **one-liners**, to be executed under regular user.
Remember to use `man tool` for detailed information about `tool`.


## Task 1

Print elements of PATH search variable on separate lines.

Example output:
```
/usr/local/bin
/usr/bin
/usr/local/sbin
/usr/sbin
```

Suggested tools: `echo`, `tr` (or `sed`).

Solution:
```bash
YOUR SOLUTION HERE
```


## Task 2

Use `/etc/passwd` file to list home directories of users in the system, sorted and without
repetitions. Nonexisting directories should not be printed.

Example output line:
```
dr-xr-x---.  2 root   root           4096 Feb 24 09:31 /root
```

Suggested tools: `ls`, `cut`, `sort`.

Solution:
```bash
YOUR SOLUTION HERE
```


## Task 3

Find all symbolic links under `/etc`, get their targets, strip leading path and longest extension,
and print sorted results without repetition. Permission errors should not be printed.

Example:
```
test@centos ~$ ls -l /etc/alternatives/mta-newaliasesman 
lrwxrwxrwx. 1 root root 43 Feb 22 21:03 /etc/alternatives/mta-newaliasesman -> /usr/share/man/man1/newaliases.postfix.1.gz
```

The corresponding output line is `newaliases`.

Suggested tools: `find`, `sed`, `sort`.

Solution:
```bash
YOUR SOLUTION HERE
```


## Task 4

Current directory contains a copy of the SSH service configuration file `sshd_config`,
with the commented line
```
# PasswordAuthentication ...
```

Edit the file in-place to change the line above to:
```
PasswordAuthentication no
```

Note that the number of spaces after `#` can be arbitrary (even no spaces).
Try to make the command as short as possible.

Solution:
```bash
YOUR SOLUTION HERE
```


## Task 5

Find out the external IP of your home Wi-Fi router via its web interface.
Note that you may need to supply cookies. You should take router's address
from the default IPv4 route.

Example: `ip route ...` shows that the default route goes via `192.168.1.1`,
so it must be the router's internal IP. The page at `http://192.168.1.1/system_status.asp`
defines a Javascript variable `wanIP = xxx.xxx.xxx.xxx`, but only if the cookie
`admin:language=en; path=/` is provided, otherwise the page will redirect to welcome screen.
We can now extract the IP from the page, but note that the router may be unreachable for
some reason, in which case `curl` must fail after a few seconds instead of waiting indefinitely.

Suggested tools: `curl`, `ip route`, `grep`, `cut`, `tr`, `sed` (depends on your router).

Solution:
```bash
YOUR SOLUTION HERE
```


## Task 6

Mirror (copy) current directory to `backup` folder in current directory using `rsync`.
Note that:

* There should be some output wrt. which files are copied or removed.
* All permissions and timestamps must be the same in the mirror.
* Directory timestamps should be ignored, since they rarely matter.
* Hard-links, ACLs and extended attributes must be copied correctly.
* Sparse files should be kept sparse (e.g., `truncate -s 1G x && du x`).
* `backup` directory must **not** itself be backed up (avoid recursion)!
* Files that are removed in current directory must be also removed in `backup`,
  if it already exists.
* All removals should occur only after file transfers are complete.

Solution:
```bash
YOUR SOLUTION HERE
```


## Task 7

Create a new directory `links`, and create there **relative** symbolic links to all
files starting with `.` in current directory and its subdirectories.

Pay attention to avoid recursion, skip current directory from the list, and support spaces
and other special characters in filenames (see `-0` option of `xargs`).

Suggested tools: `find`, `xargs`.

Example links:
```
test@centos ~$ ll links/
lrwxrwxrwx. 1 test test   10 Feb 25 17:34 .bashrc -> ../.bashrc
lrwxrwxrwx. 1 test test   20 Feb 25 17:34 .git -> ../linux-design/.git
```

Solution:
```bash
YOUR SOLUTION HERE
```


# Task 8

Create a file `keyring.asc` containing the **contents** of all public keys mentioned
in `yum` repositories located in `/etc/yum.repos.d` using `gpgkey` entries, without
repetitions. Do not use sub-commands (i.e., `` `command` `` or `$(command)`).

Suggested tools: `grep`, `sed`, `sort`, `xargs`.

Solution:
```bash
YOUR SOLUTION HERE
```


# Task 9

Print a list of all remote IP addresses of established TCP connections, without port
numbers, and without repetitions.

Suggested tools: `ss`, `tail`, `awk`, `sed`, `sort`.

Solution:
```bash
YOUR SOLUTION HERE
```


# Task 10

For each executable file in `/usr/bin`, use `ldd` to find out which dynamic libraries it is
linked against. For each “real” dynamic library, located directly under `/lib64` or `/usr/lib64`
(note that one is a symlink to another), ignoring subdirectories, find out the package that it
belongs to using `repoquery`, and print all such short package names without repetitions.

For example, `ldd /usr/bin/ls` lists
```
libacl.so.1 => /lib64/libacl.so.1 (0x00007fdf52f06000)
```
among other entries. `/lib64` is just a symlink, so the file is registered in database of installed
packages as `/usr/lib64/libacl.so.1`. `repoquery` reports that this library belongs to package
`libacl-0:2.2.51-12.el7.x86_64`, the short name being `libacl`. Hence, the output looks like:
```
kmod-libs
krb5-libs
libacl
libassuan
libattr
```

Solution:
```bash
YOUR SOLUTION HERE
```
