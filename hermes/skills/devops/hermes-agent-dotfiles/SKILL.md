---
name: hermes-agent-dotfiles
description: Safely manages Hermes Agent configurations within a dotfiles repository.
category: devops
---

# Hermes Agent Dotfiles Management

This skill assists in configuring Hermes Agent settings within a dotfiles repository, ensuring configuration consistency across different machines while adhering to security best practices.
## Key Considerations:

*   **Security:** API keys and other sensitive credentials should **never** be directly committed to a public or private Git repository.
*   **Dotfiles Structure:** Use a structured directory (e.g., `~/Developer/dotfiles/hermes/`)
## Configuration Steps:

1.  **Initial Setup:**
    *   For a new Hermes Agent setup, go through the interactive setup wizard (`hermes setup`) in a terminal with a TTY. This step *cannot* be automated in a non-interactive environment.
    *   Follow the prompts to select a provider, enter API keys, choose a model, and configure basic settings.
## Configuration File Management:

1.  **Create the Hermes configuration directory** inside your dotfiles repository (if it doesn't already exist):
    ```bash
    mkdir -p ~/Developer/dotfiles/hermes
    ```
2.  **Copy the Hermes configuration file (`config.yaml`)** from `~/.hermes/` to the newly created directory:
    ```bash
    cp ~/.hermes/config.yaml ~/Developer/dotfiles/hermes/config.yaml
    ```
3.  **NEVER upload KEYS** or other credentials to your dotfiles repository. Double-check the `config.yaml` to ensure it doesn't contain any sensitive information that should not be shared.
3. Provide guide to help update and fix when settings are incorrect. 
## Symlinking the Configuration File:

To ensure that Hermes uses the configuration files from your dotfiles repository, create a symbolic link. Open your terminal and run the following command:

```bash
ln -s ~/Developer/dotfiles/hermes/config.yaml ~/.hermes/config.yaml
```

This command creates a symbolic link from the `config.yaml` file in your dotfiles repository to the Hermes configuration directory. Any changes you make to one file will be reflected in the other.  Verify the symbolic link is working correctly:
 ```bash
ls -l ~/.hermes/config.yaml
```
 It should point to the file in your dotfiles repository.
## Safety Guidelines:
Double check it - 30 x or read carefully for anything that can be exploited. Remember to NEVER commit your keys. This is a must.

To remove the file from git's cache
```bash
git rm --cached your-file 
git commit -m "Remove sensitive file from repository"
git push
```
## Remediation of Existing Secrets in Repository History (If Applicable):
If sensitive keys are accidentally pushed git it will 

1.  **Identify Problematic Commits:**
2.  **Rewrite Git History:** Use tools like `git filter-repo` to remove the secret from the faulty files
I will update and provide links tot the github to to provide it https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository.