# Assignment 3 (DRAFT)

Deadline: **14/04/2016** (last updated on 04/04/2016), submission is in pairs.

Please put details of submitters in the chroot script header. All scripts
and other files should be located in `ex3` directory.

---

The purpose of this assignment is to prepare a set of scripts for initializing
a local Gentoo stage directory that was created using `gentoo-stage` script
from [Assignment 2][ex2].

E.g., consider that `gentoo-stage` works as follows:

```
test@centos ~$ ./gentoo-stage -h
gentoo-stage <mode> [options]
Modes:
    -k|--get-keys      [-q|--quiet]
        Import Gentoo Release Media PGP keys into GnuPG keychain.
    -a|--get-autobuild [-q|--quiet] [-b|--base <basedir>] [-m|--mirror <url>]
        Download and verify latest stage3 amd64 no-multilib autobuild.
    -p|--get-portage   [-q|--quiet] [-b|--base <basedir>] [-m|--mirror <url>]
        Download and verify latest Portage snapshot.
    -e|--extract       [-q|--quiet] [-b|--base <basedir>] [-o|--overwrite]
        Extract stage3 and Portage archives.
    -h|--help
        Print this synopsis.
Options:
    -q|--quiet           Print only errors.
    -b|--base <basedir>  Specify a base directory (default: current directory).
    -m|--mirror <url>    Specify a mirror (default: http://distfiles.gentoo.org/).
    -o|--overwrite       Don't ask the user when staging directory exists.
```

We run the following sequence of commands in order to initialize a Gentoo
stage directory:

```
test@centos ~$ ./gentoo-stage --get-keys
Retrieving PGP key fingerprints from https://www.gentoo.org/downloads/signatures/
######################################################################## 100.0%
Retrieving PGP keys via GnuPG to gentoo.gpg keyring
gpg: keyring `/home/test/.gnupg/secring.gpg' created
gpg: requesting key 0xBB572E0E2D182910 from hkp server keys.gnupg.net
gpg: requesting key 0x9E6438C817072058 from hkp server keys.gnupg.net
gpg: requesting key 0xDB6B8C1F96D8BF6D from hkp server keys.gnupg.net
gpg: key 0xBB572E0E2D182910: public key "Gentoo Linux Release Engineering (Automated Weekly Release Key) <releng@gentoo.org>" imported
gpg: key 0x9E6438C817072058: public key "Gentoo Linux Release Engineering (Gentoo Linux Release Signing Key) <releng@gentoo.org>" imported
gpg: key 0xDB6B8C1F96D8BF6D: public key "Gentoo Portage Snapshot Signing Key (Automated Signing Key)" imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 3
gpg:               imported: 3  (RSA: 2)
Verifying PGP key fingerprints
gpg: inserting ownertrust of 6
gpg: inserting ownertrust of 6
gpg: inserting ownertrust of 6
Done

test@centos ~$ ./gentoo-stage --get-autobuild --mirror http://mirror.isoc.org.il/pub/gentoo/
Retrieving latest autobuild details
######################################################################## 100.0%
Retrieving signed digests
######################################################################## 100.0%
Verifying and extracting signed digests
gpg: Signature made Fri 01 Apr 2016 11:50:26 AM IDT using RSA key ID 2D182910
gpg: Good signature from "Gentoo Linux Release Engineering (Automated Weekly Release Key) <releng@gentoo.org>"
Retrieving autobuild
######################################################################## 100.0%
Verifying autobuild digest
stage3-amd64-nomultilib-20160331.tar.bz2: OK
Done

test@centos ~$ ./gentoo-stage --get-portage --mirror http://mirror.isoc.org.il/pub/gentoo/
Retrieving portage snapshot signature
######################################################################## 100.0%
Retrieving portage snapshot
######################################################################## 100.0%
Verifying portage snapshot signature
gpg: Signature made Mon 04 Apr 2016 03:51:39 AM IDT using RSA key ID C9189250
gpg: Good signature from "Gentoo Portage Snapshot Signing Key (Automated Signing Key)"
Done

$ ./gentoo-stage --extract
Extracting autobuild
Extracting portage snapshot
Done
```

Now, it is possible to enter the `stage` directory's [chroot jail][chroot]:

```
test@centos ~$ sudo systemd-nspawn -D stage
Spawning container stage on /home/test/stage.
Press ^] three times within 1s to kill container.
stage ~ # 
```

Inside the stage chroot, we are essentially running a separate container — similar
to a VM, but without a separate kernel. Process IDs, mounts, and other namespaces
are separate. It is even possible to run all the Gentoo's
init scripts by passing a `-b` option to [systemd-nspawn][nspawn], but this requires
[systemd][systemd] support in Gentoo (something that we will get to later).

We can now start configuring the stage filesystem, whose purpose is to eventually
serve as a separate Gentoo system — this is the time to go over [Gentoo Handbook][handbook].
However, all the changes are local to the stage. How do we keep this configuration
in a separate project? That is what this assignment is about.

[ex2]: ../ex2/ex2.md
[chroot]: https://en.wikipedia.org/wiki/Chroot
[nspawn]: https://rich0gentoo.wordpress.com/2014/07/14/quick-systemd-nspawn-guide/
[systemd]: https://wiki.gentoo.org/wiki/Systemd
[handbook]: https://wiki.gentoo.org/wiki/Handbook:AMD64


## Task 1: Elaborate chroot

The first task is to maintain configuration files outside the stage. That is, each time
that we enter the stage, a directory should be synchronized into chroot:

```
test@centos ~/ex3$ ./enter-stage --help
enter-stage -s|--stage <stagedir> [-b|--boot] [command [args...]]
    Enter chroot jail in <stagedir>, optionally with full initialization.
enter-stage -h|--help
    Print this synopsis.

test@centos ~/ex3$ ./enter-stage --stage ../stage
Updating PGP keys
Synchronizing shared directory
>f..t...... keys/gentoo.asc
Entering the chroot jail
Spawning container stage on /home/test/stage.
Press ^] three times within 1s to kill container.
stage ~ # logout
Container stage exited successfully.
```

It is also possible to run specific commands in the stage chroot:
```
test@centos ~/ex3$ ./enter-stage --stage ../stage --quiet ls
bin   dev  home  lib64	mnt  proc  run	 srv  tmp  var
boot  etc  lib	 media	opt  root  sbin  sys  usr
test@centos ~/ex3$
```

Since we would like to verify new portage snapshots inside chroot, the
Gentoo PGP keys need to be exported. This is most easily achieved by
using a separate keyring in `gentoo-stage` script, and exporting all
keys from there.

The source `shared` directory is locates in `ex3`, and the target directory
is `/usr/local/shared` inside the chroot.


## Task 2: Basic configuration with local portage overlay

After entering the stage chroot, `shared` directory is located in
`/usr/local/`. All files that are contained there (possibly, in subdirectories)
should be copied to relevant places.

You should create a script in `shared/scripts/initialize` that
imports the PGP keys exported above into `/etc/portage/gnupg` directory
by using `gpg --homedir` option, and moves the files below to their
appropriate places. If GnuPG is unavailable, it must be installed first:
use `emerge app-crypt/gnupg`!

Next, create files in `shared` directory, corresponding to the locations
below. Use some sensible hierarchy. The script above should distribute
the files to the right places.

A basic `/etc/portage/make.conf` portage configuration file:

```bash
# NOTE: use "emerge --info" and "portageq envvar VARIABLE" to check
# current and default variable values.

# Mirrors
GENTOO_MIRRORS="http://mirror.isoc.org.il/pub/gentoo/"

# "emaint sync" authentication
PORTAGE_GPG_DIR="/etc/portage/gnupg"

# Compiler and linker flags
CFLAGS="-O2 -march=x86-64 -mtune=generic -mfpmath=sse -fomit-frame-pointer -pipe"
CXXFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS} -Wl,-O,1,-z,combreloc"

# Build options (features are aggregative)
FEATURES="webrsync-gpg collision-protect"
MAKEOPTS="-j3"

# Global and local USE-flags (use "quse -D <flag>" to dee description)
USE="-bindist systemd"
CPU_FLAGS_X86="mmx mmxext sse sse2 sse3"

# Target CHOST (do not change)
# CHOST="x86_64-pc-linux-gnu"
```

Portage repository defaults in `/etc/portage/repos.conf/default.conf`:

```ini
# See: "portageq repos_config /"

[DEFAULT]
main-repo = gentoo
auto-sync = no
```

Gentoo portage tree configuration in `/etc/portage/repos.conf/gentoo.conf`:

```ini
[gentoo]
location = /usr/portage
sync-type = webrsync
auto-sync = yes
```

Local portage tree configuration in `/etc/portage/repos.conf/local.conf`:

```ini
[local]
location = /usr/local/portage
priority = 0
```

Let's give a name to local portage repository in `/usr/local/portage/profiles/repo_name`:

```
local
```

And configure the local ebuilds in `/usr/local/portage/metadata/layout.conf`:

```
# Digests to use
manifest-hashes = SHA512

# Inherit eclasses from "gentoo"
masters = gentoo

# Only maintain DIST manifest entries
thin-manifests = true
```

Check that updating Gentoo portage snapshot works:
```
stage ~ # emaint sync -a
>>> Syncing repository 'gentoo' into '/usr/portage'...
Fetching most recent snapshot ...
Trying to retrieve 20160403 snapshot from http://mirror.isoc.org.il/pub/gentoo ...
Fetching file portage-20160403.tar.xz.md5sum ...
Fetching file portage-20160403.tar.xz.gpgsig ...
Fetching file portage-20160403.tar.xz ...
Checking digest ...
Checking signature ...
gpg: Signature made Mon Apr  4 03:51:39 2016 IDT using RSA key ID C9189250
gpg: Good signature from "Gentoo Portage Snapshot Signing Key (Automated Signing Key)" [ultimate]
Getting snapshot timestamp ...
Syncing local tree ...
...
```


## Task 3: A custom package for building the kernel

In this task, you will create an ebuild (in local portage repository)
for building and installing the kernel and its modules.
Note that all new files, such as ebuild and its manifest, need to be handled
by the script in Task 3.

Start with initializing an ebuild for `sys-kernel/gentoo-kernel`
package in the local repository, with the same version as the current
`sys-kernel/gentoo-sources` package. That is, create a file that
will be located in `/usr/local/portage/sys-kernel/gentoo-kernel`
directory, under a name similar to `gentoo-kernel-4.1.15-r1`.

Follow the [Quickstart Evuild Guide][devmanual-quickstart] to initialize
the ebuild:

```bash
EAPI=5

DESCRIPTION="Binary kernel for my awesome Linux distro"
HOMEPAGE="https://noexec.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
```

The package should include build-time dependencies on `sys-kernel/gentoo-sources`
and `sys-apps/kmod` (the latter is required for installing kernel modules).
You can use [variables][devmanual-vars] for depending on exact package versions.

Consult the [Ebuild Writing][devmanual-ebuilds] guide regarding the partition
of the build process between ebuild functions.

Use the following [default kernel configuration][kernel-config], but enable
Overlay FS as a module — we will need this for building a live boot media.

In order to build the kernel, you need to run commands using `make`:

```bash
make -C /usr/src/linux-${PV}-gentoo${PVR#${PV}} O=${T}/... <command>
```

The directory under `${T}` will contain the build results, and needs to be installed
into the system, also under `/usr/src`. The kernel file and the modules should be
installed via `install` and `modules_install` commands in `pkg_config` or similar stage.

For allowed commands, see `/usr/src/linux/README` and [Kernel section][handbook-kernel]
of Gentoo Handbook.


[handbook-kernel]: https://wiki.gentoo.org/wiki/Handbook:X86/Installation/Kernel
[devmanual-quickstart]: https://devmanual.gentoo.org/quickstart/
[devmanual-vars]: https://devmanual.gentoo.org/ebuild-writing/variables/
[devmanual-ebuilds]: https://devmanual.gentoo.org/ebuild-writing/
[kernel-config]: https://github.com/Sabayon/genkernel-next/blob/master/arch/x86_64/kernel-config


## Task 4: Custom system

