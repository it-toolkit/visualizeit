# visualizeit

Visualize IT application

## Getting Started

...

## Contribution

### Code quality

#### Flutter Linter
This project uses this static analysis tool that helps to identify and enforce coding conventions, detect potential errors, and suggest best practices in Flutter Dart code.

We've chosen the `flutter_lint` linter rule set [Details](https://dart.dev/tools/linter-rules).



### Git hooks

This project uses the following tools to manage git hooks
* https://pub.dev/packages/git_hooks
* https://pub.dev/packages/dart_pre_commit

We encourage you to use them to ensure your code quality. Please follow the instructions below: 

#### 1 - Get app packages
```bash
flutter pub get
```

#### 2 - Activate `git_hooks` tool in shell
```bash
pub global activate git_hooks
```

> Pub installs executables into $HOME/.pub-cache/bin, if it is not in your path
> try adding this to your shell's config file (.bashrc, .bash_profile, etc.):
> ```bash
> export PATH="$PATH":"$HOME/.pub-cache/bin"
> ```

#### 3 - Enable git_hooks for current project
```bash
git_hooks create tools/git_hooks.dart
```
