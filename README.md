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
flutter pub global activate git_hooks
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

#### 4 - Set up custom hooks
Go to `tools` folder and run

```bash
sh setup-git-hooks.sh
```

This is required to enable Code Coverage on git pre-commit hook.

To analyze test coverage we use the tool https://pub.dev/packages/dlcov

### Dependency management

#### Override dependencies

In order to override dependencies during development you can create a file called
`pubspec_overrides.yaml` at project root. All the dependencies defined in this file will override
the configuration available in `pubspec.yaml` file.
The file `pubspec_overrides.yaml` won't be pushed to the git repository (it is already ignored using
.gitignore)

See `pubspec_overrides.yaml.bk` for an example.