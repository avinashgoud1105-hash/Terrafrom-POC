Cursor CLI – Ubuntu Automated Installation Plan

Document: Cursor CLI Automated Installation on Ubuntu
Status: Draft for Management Approval
Date: 2026-08-13
Target Platform: Ubuntu Linux
Owner: DevOps / Platform Engineering

1. Executive Summary

This document proposes an automated and standardized approach to install and maintain Cursor CLI on approved Ubuntu machines across the organization.

The objective is to replace manual installation with a repeatable deployment script that can later be integrated with enterprise automation platforms such as Ansible, Jenkins, GitHub Actions, or an endpoint-management solution.

The proposed deployment will:

Validate that the target machine is Ubuntu.

Validate CPU architecture.

Validate network connectivity.

Install required dependencies such as curl.

Detect an existing Cursor CLI installation.

Install or update Cursor CLI using the official Cursor installer.

Configure the user's PATH.

Validate the CLI installation.

Record installation logs.

Return meaningful exit codes.

Keep authentication separate from installation.

Provide a foundation for enterprise-scale deployment.

The current Cursor CLI installation command documented by Cursor is:

curl https://cursor.com/install -fsS | bash

Reference: https://cursor.com/en-US/cli

2. Objectives

Primary Objectives

Automate Cursor CLI installation on Ubuntu.

Standardize the installation process.

Reduce manual effort for DevOps and developers.

Ensure repeatable and idempotent execution.

Validate the installation after deployment.

Provide installation logs for troubleshooting.

Prepare the script for large-scale deployment.

Establish a controlled upgrade and rollback process.

Secondary Objectives

Support both x86_64 and ARM64 Ubuntu machines where supported.

Avoid duplicate PATH entries.

Detect existing Cursor CLI installations.

Prevent API keys or credentials from being stored in the installation script.

Integrate the script with existing enterprise automation tools.

3. Scope

In Scope

Ubuntu Linux machines.

Cursor CLI installation.

Cursor CLI upgrade/re-installation.

Dependency validation.

Network validation.

PATH configuration.

Installation validation.

Logging.

Error handling.

Exit-code handling.

Pilot deployment.

Production rollout.

Ansible/Jenkins/GitHub Actions integration in a later phase.

Out of Scope

The initial installation script will not:

Automatically authenticate users.

Store user credentials.

Store API keys.

Modify Git repositories.

Automatically execute Cursor agent commands.

Configure unrestricted agent permissions.

Install or configure MCP servers.

Make production code changes.

Provide production credentials to Cursor CLI.

4. Current Installation Approach

Cursor currently provides an official Linux installer.

The baseline installation command is:

curl https://cursor.com/install -fsS | bash

The organization should use the official Cursor installation mechanism rather than downloading binaries from unofficial locations.

The installation script should wrap this command with organizational controls such as:

OS validation

Architecture validation

Network validation

Existing installation detection

Logging

PATH configuration

Post-install validation

Error handling

5. Proposed Deployment Architecture

                    Git Repository
                          |
                          v
               install-cursor-cli.sh
                          |
             +------------+-------------+
             |                          |
             v                          v
       Manual Pilot                 Automation
             |                    Ansible / Jenkins
             |                    GitHub Actions / MDM
             |                          |
             +------------+-------------+
                          |
                          v
                    Ubuntu Machine
                          |
                          v
                     Cursor CLI
                          |
             +------------+-------------+
             |                          |
             v                          v
       Developer Usage             CI/CD Usage
       Browser/SSO                 API Key
                                      |
                                      v
                              Secret Management

6. Installation Script Design

The script should be designed to be idempotent.

Running the script multiple times should not:

Create duplicate installations.

Add duplicate PATH entries.

Corrupt shell configuration.

Store credentials.

Cause unnecessary configuration changes.

Proposed Script

File:

install-cursor-cli.sh

Script Flow

START
  |
  v
Check /etc/os-release
  |
  v
Is OS Ubuntu?
  |
  +---- No ----> Exit 2
  |
  v
Check Architecture
  |
  +---- Unsupported ----> Exit 3
  |
  v
Check curl
  |
  +---- Missing ----> Install curl
  |
  v
Check Network
  |
  +---- Failed ----> Exit 4
  |
  v
Detect Existing Cursor CLI
  |
  v
Install / Update Cursor CLI
  |
  +---- Failed ----> Exit 5
  |
  v
Configure PATH
  |
  v
Locate CLI
  |
  +---- Not Found ----> Exit 6
  |
  v
Validate Version
  |
  v
Validate CLI Help
  |
  v
Write Installation Log
  |
  v
SUCCESS

7. Pre-Installation Checks

The script should perform the following checks before installation.

7.1 Operating System

Check:

cat /etc/os-release

Expected:

ID=ubuntu

If the system is not Ubuntu:

Exit Code: 2

7.2 Architecture

Check:

uname -m

Expected architectures:

x86_64
aarch64
arm64

Unsupported architecture:

Exit Code: 3

7.3 curl

Check:

command -v curl

If unavailable:

sudo apt-get update
sudo apt-get install -y curl

7.4 Network

Validate connectivity:

curl -I --connect-timeout 10 https://cursor.com

If connectivity fails:

Exit Code: 4

8. Existing Installation Detection

Before installation, check whether Cursor CLI already exists.

For example:

command -v agent

and:

command -v cursor-agent

If found, obtain the current version:

agent --version

or:

cursor-agent --version

The script should record the existing version in the log.

9. Installation

Use the official Cursor installer:

curl https://cursor.com/install -fsS | bash

The command output should be captured in the installation log.

The script should return a failure status if the installation command fails.

10. PATH Configuration

The script should verify whether the Cursor CLI installation directory is available in the user's PATH.

For example:

export PATH="$HOME/.local/bin:$PATH"

If a persistent PATH change is required, update:

~/.bashrc

The script must first check whether the PATH entry already exists.

It should not repeatedly add:

export PATH="$HOME/.local/bin:$PATH"

to .bashrc.

11. Post-Installation Validation

After installation, the script should validate:

CLI Location

which agent

or:

which cursor-agent

Version

agent --version

Help

agent --help

The deployment should only be reported as successful if the CLI can be executed successfully.

12. Authentication Strategy

Authentication should be separate from installation.

Developer Machines

Developers should authenticate using the organization's approved authentication method.

Example:

agent login

The installation script should not automatically store user credentials.

CI/CD

For automation, Cursor supports API-key based authentication.

Example:

export CURSOR_API_KEY="$CURSOR_API_KEY"

The actual secret must be stored in the organization's approved secret-management platform.

Examples:

AWS Secrets Manager

HashiCorp Vault

Jenkins Credentials

GitHub Actions Secrets

GitLab CI/CD Variables

Azure Key Vault

The API key must never be hard-coded into:

Shell scripts

Git repositories

Dockerfiles

AMIs

Cloud-init files

Terraform code

Jenkinsfiles

Public documentation

13. Logging

The installation script should generate a log.

Recommended location for user-level execution:

~/.cursor/cursor-cli-install.log

Alternative temporary log:

/tmp/cursor-cli-install.log

The log should contain:

Timestamp

Hostname

Ubuntu version

Architecture

Existing CLI version

Installed CLI version

Installation status

Validation status

Error messages

The log must never contain:

API keys

Passwords

OAuth tokens

Authentication cookies

Secret values

14. Exit Codes

Use standardized exit codes.

Exit Code

Meaning

0

Installation successful

1

General failure

2

Unsupported operating system

3

Unsupported architecture

4

Network failure

5

Installation failure

6

Validation failure

This allows Ansible, Jenkins, or other automation systems to determine whether deployment succeeded.

15. Security Requirements

Before production rollout, the following should be reviewed.

Network

Validate:

DNS resolution.

HTTPS/443 connectivity.

Corporate proxy.

Firewall restrictions.

SSL/TLS inspection.

Egress policies.

Authentication

Define:

Developer authentication method.

SSO requirements.

API-key management.

User lifecycle.

Offboarding process.

Agent Permissions

Define approved permissions for:

File access.

Shell commands.

Git operations.

Repository changes.

Production systems.

Recommended initial posture:

Read repository        -> Allowed
Code modifications     -> User approval
Shell commands         -> User approval
Git commit             -> User approval
Git push               -> User approval
Production access      -> Prohibited
Secrets access         -> Prohibited
Destructive commands   -> Prohibited

MCP

MCP should be handled as a separate security-controlled activity.

Recommended:

Approved MCP allowlist
        |
        v
Security Review
        |
        v
Least Privilege
        |
        v
Controlled Deployment

16. Pilot Deployment

Do not immediately deploy to every Ubuntu machine.

Start with:

5–10 Ubuntu machines

Recommended pilot users:

2 DevOps engineers

2 Application developers

1 Platform engineer

1 Security representative

1 IT/endpoint-management representative

Pilot Duration

Recommended:

1–2 weeks

17. Pilot Test Cases

Test

Expected Result

Fresh installation

Installation succeeds

Existing installation

Existing version detected

Re-run script

No duplicate configuration

CLI version

Version displayed

CLI help

Help command works

PATH

CLI available after new login

Authentication

User can authenticate

Network

Corporate network works

Proxy

Proxy configuration works if applicable

Logging

Log generated

Secrets

No credentials in logs

Failure handling

Correct exit code

Reboot

CLI remains available

Upgrade

CLI can be updated

Rollback

Previous state can be restored

18. Production Deployment

After pilot approval, deploy in waves.

Wave 1

10–25 Ubuntu machines

Purpose:

Validate production deployment.

Validate automation.

Monitor failures.

Wave 2

50–100 Ubuntu machines

Purpose:

Validate scale.

Validate support model.

Wave 3

Remaining approved Ubuntu machines.

19. Enterprise Automation

Once the script is validated, integrate it with an automation platform.

Option 1 – Ansible

Recommended for Ubuntu server fleets.

Example:

Ansible Controller
       |
       +---- Ubuntu Server 1
       |
       +---- Ubuntu Server 2
       |
       +---- Ubuntu Server 3
       |
       +---- Ubuntu Server N

Advantages:

Centralized deployment.

Repeatable execution.

Inventory management.

Reporting.

Easy rollback.

Option 2 – Jenkins

Pipeline can execute the installation against approved Ubuntu hosts.

Option 3 – GitHub Actions

Useful when deployment is triggered from a controlled infrastructure repository.

Option 4 – Cloud-Init

For new AWS EC2 instances, the script can be executed during instance provisioning.

Example:

Terraform
   |
   v
AWS EC2
   |
   v
Cloud-Init
   |
   v
install-cursor-cli.sh

This should only be used where the organization explicitly wants Cursor CLI installed on every newly provisioned instance.

20. AWS EC2 Consideration

If the Ubuntu machines are AWS EC2 instances, the preferred architecture should be evaluated carefully.

