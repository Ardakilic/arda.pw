---
title: 'Removing Sensitive Files from Git History: A Step-by-Step Guide'
description: 'Learn how to remove sensitive files from Git history using git-filter-repo. A practical guide with real-world examples.'
summary: 'Accidentally committed sensitive files to Git? Learn how to remove them from history using git-filter-repo. A practical guide with real-world examples.'
date: '2025-04-22T08:36:08.000Z'
author: ["Arda Kılıçdağı"]
categories: ["Development"]
tags: ["git", "history", "commit", "english"]
slug: "remove-sensitive-files-from-git-history"
draft: false
---


## Introduction

In software development, it's not uncommon to accidentally commit sensitive files to a Git repository. This could be configuration files containing API keys, environment variables, or other sensitive information. Once these files are pushed to a remote repository, they become part of the Git history, which can pose security risks.

In this post, I'll walk you through the process of completely removing a sensitive file from Git history, using a real-world example from the sox_ng_dockerized project.

## The Problem

During the development of a private project, a `.env.local` file containing sensitive configuration was accidentally committed to the repository. This file needed to be removed not just from the current state of the repository, but from the entire Git history.

## The Solution

### Step 1: Remove the File from Current Working Directory

First, we need to remove the file from Git's tracking and the working directory:

```bash
git rm --cached .env.local
rm .env.local
```

### Step 2: Remove from Git History

I used `git-filter-repo`, a more modern and safer alternative to `git filter-branch`, to remove the file from the entire Git history:

```bash
git filter-repo --invert-paths --path .env.local --force
```

This command:
- Scans through all commits in the repository
- Removes any occurrence of the `.env.local` file
- Rewrites the Git history to exclude these files
- Maintains the integrity of the remaining history

### Step 3: Prevent Future Accidents

To prevent similar accidents in the future, we added the file to `.gitignore`:

```bash
echo ".env.local" >> .gitignore
```

### Step 4: Push Changes to Remote

Since we've rewritten the Git history, we need to force push the changes to the remote repository:

```bash
git remote add origin git@github.com:user/upstream.git
git push origin --force --all
```

## Important Notes

1. **Force Push Warning**: Force pushing rewrites the remote history, which can cause issues for other developers. They'll need to:
   ```bash
   git fetch origin
   git reset --hard origin/main
   ```

2. **Backup First**: Always make a backup of your repository before performing history rewrites.

3. **Consider Alternatives**: For less sensitive information, you might consider:
   - Using environment variables
   - Implementing a secrets management system
   - Using configuration files that are gitignored by default

## Best Practices for Sensitive Data

1. **Prevention is Better than Cure**:
   - Add sensitive files to `.gitignore` before starting development
   - Use environment variables for sensitive data
   - Consider using a secrets management service

2. **Regular Audits**:
   - Periodically check your repository for sensitive data
   - Use tools like `git-secrets` or `trufflehog` to scan for sensitive information

3. **Team Education**:
   - Ensure all team members understand the importance of not committing sensitive data
   - Document procedures for handling sensitive information

## Conclusion

While removing sensitive files from Git history is possible, it's always better to prevent such situations in the first place. By implementing proper security practices and educating team members, you can avoid the need for history rewriting and maintain a secure codebase.

Remember: Once sensitive data is pushed to a public repository, even if you remove it, it might have already been exposed. Always rotate any exposed credentials or keys immediately.

## Additional Resources

- [git-filter-repo documentation](https://github.com/newren/git-filter-repo)
- [GitHub's guide on removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [OWASP's guide on secure coding practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)