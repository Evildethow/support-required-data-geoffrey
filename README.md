# About

Say hello to Geoffrey, the butler! He is here to help you diagnose problems with your CJP instance.

# Usage

```bash
geoffrey help
```

# Installing

Geoffrey needs to be installed on the machine running Jenkins.

* TODO: support remote execution (bastion) (?)

**NOTE**: You need to refresh your bash profile to apply the installation.

## Online Mode

Requires a connection to https://github.com

```bash
curl -sL "https://raw.githubusercontent.com/cloudbees/support-required-data-geoffrey/${GEOFFREY_REMOTE_BRANCH:-master}/install.sh" | bash -s --
```

Geoffrey will take care of the rest for you.

## Offline Mode

Geoffrey can be manually installed using the following steps:

```bash
# Setup environment first (your values go here)
JENKINS_USER_ID=jenkins
JENKINS_HOST=my.jenkins.host
# Download the project  branch from Github as a zip file
curl -L -o "${HOME}/${GEOFFREY_REMOTE_BRANCH:-master}.zip" "https://github.com/cloudbees/support-required-data-geoffrey/archive/${GEOFFREY_REMOTE_BRANCH:-master}.zip"
# Copy it to the server hosting Jenkins. 
scp "${HOME}/geoffrey" ${JENKINS_USER_ID}@${JENKINS_HOST}:/home/${JENKINS_USER_ID}
# SSH to the host 
ssh ${JENKINS_USER_ID}@${JENKINS_HOST}
# Extract the project
unzip -j "${HOME}/${GEOFFREY_REMOTE_BRANCH:-master}.zip" -d "${HOME}/geoffrey"
# Setup Geoffrey environment
printf "\n\nGEOFFREY_MODE=offline\n\n" >> ${HOME}/.geoffrey
printf "\n\nsource ${HOME}/.geoffrey\n\n" >> ${HOME}/.bashrc
```

## Verifying 

Verify that the installation was successful by running:

```bash
geoffrey help
```

## Troubleshooting

If you system is unable to find `geoffrey` on your path it probably means you forgot to add it to your bash profile.

The following should do that for you:

```bash
printf "\n\nsource ${GEOFFREY_CONF_FILE}\n\n" >> ${HOME}/.bashrc
```

# Environment

## Order

* Core Properties
* Application Properties
* Local Properties (`~/.geoffrey.config`)

# Development

Developers should use `--profile development`.

```bash
geoffrey help --profile development
```

## Standards

[GitHub Standard Fork and Pull Request Workflow](https://gist.github.com/Chaser324/ce0505fbed06b947d962)

Ping `@cloudbees/team-support` for a PR review.

## Environment

See [Environment](#Environment).

## Styles and Conventions

Some conventions are followed in regards to directory layout to allow Geoffrey to discover services as they are added.

### Documentation

TBD. Need to define a template.

### Configuration and session variables

Don't try writing commands that pass around various things as parameters. Instead, use the application config to define 
environment variables, and use those to make values globally available to the command at runtime.

See [Config](###Config).

## Branching

TBD

# Releasing

TBD

## Feature toggling

TBD

## Versioning

TBD