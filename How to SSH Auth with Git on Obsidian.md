SSH Auth may not work on Enterprise networks, had an issue with the SSH port being blocked or something, couldn't make requests on listening port. HTTPS Auth should always work since it's the Website port (443) so if its blocked websites will not load.


(Windows: Install GitHub Desktop + Git)
```powershell
winget install GitHub.GitHubDesktop.Beta; winget install Git.Git
```

(Linux: Flatpak Website / Commandline)
If Flatpak is not Installed:
	[Flatpak Installation Guide](https://flatpak.org/setup/)]
[GitHub Desktop Flatpak](https://beta.flathub.org/apps/details/io.github.shiftey.Desktop)
**OR**
```bash
flatpak install flathub io.github.shiftey.Desktop
```


Clone using regular *HTTPS* on github desktop, open resultant folder in obsidian and manage *obsidian git* plugin settings, e.g. enable auto-push/commit for seamless syncing.

Create Public Private Key Pair for ssh-auth use `ssh-keygen -t name -C "your_email@example.com"` sub in name with name for the key, and "*your_email@example.c0m*" with github private email / GitHub Account Email subbed in.

Resultant keys will be put in *~/.ssh/* with the format id_name (private) and id_name.pub (Public)

take the public key from this (one ending in .pub) open it with text editor, copy its contents and paste it into github keys section in github settings. the other one, *without .pub at the end* is the *private key* that was created **shouldn't be uploaded anywere**, send that private key to all *trusted* computers that need to modify/access the obsidian repo/vault, usually good idea to also store it in ~/.ssh/ on each computer but not necessary, since it is just added to `ssh-agent` by: 

running `ssh-add ~/.ssh/id_<name>`

to actually make this vault use the SSH Auth go into github desktop, repository from top bar, properties, and change the URL to the SSH Url, which you can get from the GitHub Website under Profile Picture --> Your Repos --> {RepositoryName} --> "Code" --> SSH URL --> Copy

### Tl;dr
Generate Public / Private Key Pair
```bash
ssh-keygen -t name -C "your_email@example.com"
stored in ~/.ssh/ which = C:/Users/%USERNAME%/.ssh/
```
Open id_name.pub (**Public**) in notepad, copy it's stuff, paste it in: github --> settings --> keys --> ssh keys
```bash
Create New Repo in github Desktop / HTTPS Clone existing one
Run: ssh-add ~/.ssh/id_name (Private)
Github Desktop --> Top Bar --> Repository --> Repository Settings --> Remote --> Copy Paste in SSH URL instead of HTTP one from github.com
Open the Github Desktop Folder (likely ~/Documents/Github/RepositoryName) in Obsidian
```
Download Obisidan-git plugin
Profit

iiii
(oh also copy this .gitignore template otherwise you get conflcits with the workplace file trying to sync itself every two seconds cus it changes every two seconds)

```shell
# to exclude Obsidian's settings (including plugin and hotkey configurations)

#.obsidian/

# OR only to exclude workspace cache

.obsidian/workspace.json

# Add below lines to exclude OS settings and caches

.trash/

.DS_Store
```


#### Cant ssh-add
"*Could Not Open a Connection to your Authentication Agent*", this happens in both powershell and Git Bash tho sometimes will only happen in one of them at a time for some reason. This Happens When there is **no ssh-agent.exe** running in the **background** this can be resolved by typing ```ssh-agent``` to fix in powershell, or `eval "$(ssh-agent)"` for git bash and regular linux, can't just use regular `ssh-agent` since it just spits out the command that needs to be run, doing it in eval runs that command, stores it as a variable, and then runs that variable as a command, in this case that command is 
```bash
SSH_AUTH_SOCK=/tmp/ssh-C0xd997sfzdN/agent.525; 
export SSH_AUTH_SOCK;
SSH_AGENT_PID=526; export SSH_AGENT_PID;
echo Agent pid 526;
```
with the ; seperating them from one another
**Note an ssh-agent instance is spawned by powershell/Bash after running command, One spawned by Powershell only works for powershell, and one spawned by Git Bash only works for Git Bash.** *Obsidian doesn't rely on ssh-agent's existance, once you use ssh-add to add the Identity Obsidian doesn't give a fu**, it spawns its own ssh.exe instance periodically when connections are made.* 
**May not be necessary but store id_name Private key files in ~/.ssh/, or C:/Users/%USER%/.ssh/ before doing ssh-add on them, could help. can just do ssh-add on them again if need-be.**

[Careful only listen to the comment main post is aids](https://gist.github.com/mortenege/42b12a82f7d79877171af84c7d0a0714)
Add the `sshCommand = "ssh -i ~/.ssh/id_name"` to the .git/config file inside the [core] section, of the .git file is in the local project repo itself, just do the initial clone with http, if messed up before and your getting [[#Host Key Validation Failed]] see below.
The Private Key that is referenced in the snippet below must be the same one on all computers since that is the one linked to the public key added in github.
should look something like this 
(even on windows this is the same though this looks like bash syntax, ~ translated to user folder don't try to use a C: path)
![[Pasted image 20221125014758.png]]
Obviously replace "github_key" with the private key FILE that was generated earleir, e.g. "*id_name*" .

This is only necessary if there is no access to ssh-agent **AND** no admin perms, `ssh-agent ` can be manually enabled if administrator privalledges are allowed (powershell snippet 4 windows)
```powershell
# By default the ssh-agent service is disabled.
Get-Service -Name ssh-agent | Set-Service -StartupType Automatic

Start-Service ssh-agent
```
But if no admin privs go for the other method with Git Bash installed and putting the sshCommand in .git/config.

on linux u can literally just do `ssh-add ~/.ssh/id_<private_key>` which is all you do on windows too if you can enable the ssh-agent normally without git bash, allegedly might have to sometimes do `eval "$(ssh-agent -s)"` to start it on startup but hearsay

testing testing push push git git git git gitfjkgjsfkjgkfdjgkd

##### Host Key Validation Failed
https://stackoverflow.com/questions/13363553/git-error-host-key-verification-failed-when-connecting-to-remote-repository

Essentially comes down to running this command:
```bash
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
```
Even though it's formatted like Linux/Mac it works on windows through the GIT Bash terminal, the ~ just gets translated to windows home folder. Standard Bash Syntax, it just runs an ssh key scan for github, then piping ( | ) that result into the known_hosts file so that the new key is the known_host instead of the old one so that ssh no longer thinks the key is invalid and your getting man in the middle'd

if not using Git Bash just look for the known_hosts and wipe its ass]

#### Other Random Fixes
```bash
git config credential.helper store
```
running this in both git and powershell happened right before it decided to fix itself for whatever reason?




