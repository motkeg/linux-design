# Assignment 2

Deadline: **21/03/2016** (last updated on 07/03/2016 11:00), submission is in pairs.

Please put details of submitters in the script header.

---

In this assignment you will implement a `gentoo-stage` script for downloading,
verifying and installing a live [Gentoo](https://www.gentoo.org/) root tree, which
we will work with later.  
*Note: Gentoo is the best Linux distribution after Slackware.*

For script arguments processing, you should use the `getopts` shell builtin —
read a [tutorial](http://wiki.bash-hackers.org/howto/getopts_tutorial).
If you want to support alternative long options (optional), you need to use
the `getopt` command instead, or combine both by replacing arguments.

The script must be self-contained (no other files), be well-commented, modular,
should report and fail on errors with a proper exit status and message, avoid long
outputs, and be overall user-friendly. All temporary files must be removed
once the script terminates.

There needs to be a `-h` / `--help` option for summarizing usage instructions.
In addition, `-q` / `--quiet` option should suppress normal (non-error) output.

The script must work in your basic CentOS 7 environment without relying on extra
packages, and should not use superuser privileges (`sudo`) unless necessary.

The submitted script must be located in the same directory as the assignment file.
All files and directories mentioned below must be created in current directory,
unless a `-b <dir>` / `--base <dir>` switch is supplied with a target directory.

The switches in different tasks cannot be combined — you should check for
conflicting switches.


## Task 1

Implement a `-k` / `--get-keys` option for importing all Gentoo Release Media
[keys](https://www.gentoo.org/downloads/signatures/). You need to parse that
page in order to retrieve the keys from the key server using GnuPG (`gpg`)
tool.

Don't specify a keyserver as done in the referenced page — let GnuPG decide
on this matter.

The key firgerprints of imported keys must be verified against both the
fingerprints listed on the website (mandatory), and against hardcoded values in the
script (verbose warning to user if there is a mismatch).

Each key should be imported only if it does not already exist in user's GnuPG
keyring.


## Task 2

Implement a `-a` / `--get-autobuild` option for downloading the latest stage3
amd64 no-multilib autobuild archive to `cache` directory, as indicated
[here](http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-nomultilib.txt).

You should download the relevant file, including the signed digests file
(`.DIGESTS.asc`), if it does not already exist in target directory
with the necessary size. If it exists, but with partial size, resume the download.

Additionally, implement a `-m <url>` / `--mirror <url>` option for using a different base URL instead
of `http://distfiles.gentoo.org/` — e.g., `http://mirror.isoc.org.il/pub/gentoo/`.
See a [mirrors list](https://www.gentoo.org/downloads/mirrors/) for testing.

Once the autobuild and the signed digests are downloaded, the autobuild must be
verified. First, check the signature with `gpg --verify`. Next, restore the
original `.DIGESTS` file by simply running `gpg` on the `.asc` file. Remove lines
verifying `.CONTENTS`, remove WHIRLPOOL hashes, and verify the remaining SHA-512
digest as instructed on the Gentoo keys page.

Finally, create or update a stable symlink to the archive in the same directory
(i.e., without the timestamp), and remove the old downloaded files (if any).


## Task 3

As above, but it is now `-p` / `--get-portage` option for downloading the latest
daily [Portage snapshot](http://distfiles.gentoo.org/releases/snapshots/current/).
You should get the `.xz` version, since it is better compressed, and also get the
detached GnuPG signature (`.gnupg`) as well. Download the small signature first,
otherwise you risk the daily `portage-latest` link changing during download.

The cached (if any) archive and signature should not be removed unless the new
ones are successfully downloaded and verified. Additionally, if the downloaded
signature is identical to existing one, you should only attempt to resume the
snapshot's download, so don't rename the cached snapshot unless you determine
that it is outdated. Don't rely on timestamps reported by HTTP server, they are
often wrong.

Look in `man gpg` for information on verifying detached signatures.

Of course, specifying a mirror should be supported as well.

*Portage describes the available packages in the system — it turns a live filesystem
into an actual Linux distribution with package management (similar to `yum` on CentOS).*


## Task 4

Implement a `-e` / `--extract` option for extracting both archives into `stage` directory.
The autobuild should be extracted directly into `stage/`, and the portage snapshot
should be extracted into `stage/usr/`.

**All** permissions and user / group IDs must be correctly restored. Note that
CentOS might show some user / groups differently, but numeric IDs (`ls -ln`) must
be kept intact. This means that extraction must be run under superuser privileges, so
exercise exceptional care. Check also the `stage/dev` directory.

If the `stage` directory exists, it must be removed first, after the user confirms
the destructive operation, or when `-o` / `--overwrite` is supplied as a script option.


## Good luck!

We will use this script later, so make this effort count.
