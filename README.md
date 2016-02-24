In order to work on assignments and projects, you need to do the following in web interface:
1. Fork this tree.
2. Add other team members with Master or Developer privileges
   (the main difference is that Developers can't push directly to `master` branch).
3. Add @orlovm with Guest privileges.

Afterwards, setup the `git` command-line environment:

```bash
yum -y install git
git config --global user.name "User Name"
git config --global user.email "user@email"
```

Locally clone this tree — e.g., after forking to user (or group) `user-or-group`:

```bash
git clone https://git.noexec.org/<user-or-group>/linux-design.git
```

Add an upstream remote, in order to be able to pull updates from the original tree:

```bash
git remote add upstream https://git.noexec.org/study/linux-design.git
```

Pull updates from upstream — e.g., after new assignment files are added:

```bash
git fetch upstream
git merge upstream/master
```

Push local commits to server, after adding and committing files using `git add` and `git commit`:

```bash
git push origin master
```
or simply:
```bash
git push
```
