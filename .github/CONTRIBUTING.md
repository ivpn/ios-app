# Contributing

Thanks for your time and interest for contributing to the IVPN iOS app project!  
As a contributor, here are the guidelines we would like you to follow:

* [Contributing Code](#contributing)
* [Creating an Issue](#issue)
* [Pull Requests](#pr)
* [Git Workflow](#git)
* [Commit Message Guidelines](#commit)
* [Coding Conventions](#conventions)

<a name="contributing"></a>
## Contributing Code

* By contributing to this project you are agreeing to the terms stated in the [Contributor License Agreement](/CLA.md).
* By contributing to this project, you share your code under the GPLv3 license, as specified in the [License](/LICENSE.md) file.
* Don't forget to add yourself to the [Authors](/AUTHORS) file.

<a name="issue"></a>
## Creating an Issue

* If you want to report a security problem **DO NOT CREATE AN ISSUE**, please read our [Security Policy](/.github/SECURITY.md) on how to submit a security vulnerability.
* When creating a new issue, chose a "Bug report" or "Feature request" template and fill the required information.
* Please describe the steps necessary to reproduce the issue you are running into.

<a name="pr"></a>
## Pull Requests

Good pull requests - patches, improvements, new features - are a fantastic help. They should remain focused in scope and avoid containing unrelated commits.

Please ask first before embarking on any significant pull request (e.g. implementing features, refactoring code), otherwise you risk spending a lot of time working on something that the developers might not want to merge into the project.

Follow these steps when you want to submit a pull request:  

1. Go over installation guides in the [README](/README.md#installation)
2. Follow our [Git Workflow](#git)
3. Follow our [Commit Message Guidelines](#commit)
4. Follow instructions in the [PR Template](/.github/PULL_REQUEST_TEMPLATE.md)
5. Update the [README](/README.md) file with details of changes if applicable

<a name="git"></a>
## Git Workflow

This project is using [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow).

### Branch naming guidelines

Naming for branches is made with following structure:

```
<type>/<issue ID>-<short-summary-or-description>
```

In case when there is no issue:

```
<type>/<short-summary-or-description>
```

Where <type> can be `epic`, `feature`, `task`, `bugfix`, `hotfix` or `release`.

### Branches

`master` - The production branch. Clone or fork this repository for the latest copy.  
`develop` - The active development branch. Pull requests should be directed to this branch.  
`<feature branch>` - The feature of fix branch. Pull requests should be made from this branch into `develop` brach.  

<a name="commit"></a>
## Commit Message Guidelines

We have very precise rules over how our git commit messages should be formatted. This leads to readable messages that are easy to follow when looking through the project history.

### Commit message format

We follow the [Conventional Commits specification](https://www.conventionalcommits.org/). A commit message consists of a **header**, **body** and **footer**.  The header has a **type**, **scope** and **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The **header** is mandatory and the **scope** of the header is optional.

### Type

Must be one of the following:

* **feat**: A new feature  
* **fix**: A bug fix  
* **docs**: Documentation only changes  
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)  
* **refactor**: A code change that neither fixes a bug nor adds a feature  
* **perf**: A code change that improves performance  
* **test**: Adding missing tests  
* **build**: Changes that affect the build system  
* **ci**: Changes to our CI configuration files and scripts  
* **vendor**: Bumping a dependency like libchromiumcontent or node  
* **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation  

<a name="conventions"></a>
## Coding Conventions

This projects is using [SwiftLint](https://github.com/realm/SwiftLint) to enforce code style and conventions. Before submitting any code changes, make sure to run lint task to check for any compile warnings:  

```sh
$ fastlane lint
```