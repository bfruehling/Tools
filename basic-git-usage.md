# Basic Git Command Line Usage

## Git Binaries
https://git-scm.com/downloads

## Git Sub-commands
### Clone a repository
```sh
git clone <repository-url>
```

### Checkout a specific branch
```sh
git checkout <branch-name>
```

### Update your local branch from the remote repository
```sh
git pull
```

### Stage changes in your working directory to be committed
```sh
git add <filename>
```

### Commit Changes to your local Repository
```sh
git commit -m "<Commit Message>"
```

### Upload your local commits to the remote repository
```sh
git push
```

### Combine Changes from another branch
```sh
git merge main
```

### Examine the difference between the current branch and main
```sh
git diff main
```

## Examples
### Checkout a new repository, edit a file and commit it back to the repository
```sh
cd $home\git
git clone https://github.com/EliLillyCo/INFOSEC_CfC_AzureAd_ServiceDocs.git
cd INFOSEC_CfC_AzureAd_ServiceDocs
code basic-git-usage.md
git add .\basic-git-usage.md
git commit -m "updated git usage documentation"
git push
```

### Update your branch with the latest changes from the main branch
```sh
cd $home\git\INFOSEC_CfC_AzureAd_ServiceDocs
git pull
git checkout main
git pull
git checkout bfruehling-patch
git merge main
git push
```






