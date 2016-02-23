In order to work on assignments and projects, you need to fork and clone this tree:

```bash
yum -y install git
git config --global user.name "User Name"
git config --global user.email "user@email"
```

After forking to user (or group) `user-or-group`:

```bash
git clone https://git.noexec.org/<user-or-group>/linux-design.git
```

Add an upstream remote:

```bash
git remote add upstream https://git.noexec.org/study/linux-design.git
```

Pull updates from upstream:

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
