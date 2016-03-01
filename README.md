In order to work on assignments and projects, you need to do the following in web interface:

1. Fork this tree to a **private** repository (you will see a *Fork* button after you sign in).
   Again, set the repository as **private**. You don't want non-group members to see your solutions.
2. Add other team members with Master or Developer privileges
   (the main difference is that Developers can't push directly to `master` branch).
3. Add @orlovm with Guest privileges.

Afterwards, setup the `git` command-line environment (global configuration is stored in `~/.gitconfig`):

```bash
yum -y install git
git config --global user.name "User Name"
git config --global user.email "user@email"
git config --global push.default simple
git config --global color.ui true
git config --global alias.lg "log --decorate --summary --stat --graph --date-order"
```

Locally clone this tree — e.g., after forking to user `username`:

```bash
git clone https://git.noexec.org/username/linux-design.git
cd linux-design
```

You will be queried for a password, so you should set it in your profile if you don't have one —
click on the password reset link, logout, and continue from there. When done, you can use your email
address and the new password for authentication.
Regardless, you can continue to use OAuth (e.g., an external Google account) for authenticating via
the web, but it is best to add two-factor authentication for protecting your local account credentials.

However, a better option is to use SSH keys — you will need to generate an SSH keypair using `ssh-keygen`, add the
public key `~/.ssh/id_rsa.pub` via the web interface, and clone the project as follows instead:
```bash
git clone git@ssh.git.noexec.org:username/linux-design.git
```

Add an upstream remote, in order to be able to pull updates from the original tree:

```bash
git remote add upstream https://git.noexec.org/study/linux-design.git
```

If you use SSH authentication, fix the URL above, or change the URL later:
```
git remote set-url upstream git@ssh.git.noexec.org:study/linux-design.git
```

Pull updates from upstream — e.g., after new assignment files are added, or after
an existing assignment is updated:

```bash
git fetch upstream
git merge upstream/master
```
or simply:
```bash
git pull upstream master
```

Push local commits to server, after adding and committing files using `git add` and `git commit`:

```bash
git push origin master
```
or simply:
```bash
git push
```

New to `git` version control?
Start with a [tutorial](https://git-scm.com/docs/gittutorial),
continue to [more tutorials](https://www.atlassian.com/git/tutorials/).
