# Test Navigator

This package allows you to quickly navigate between implementation and test files.

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)

# Installation
```
apm install test-navigator
```
Or search for <code>test-navigator</code> in the Atom settings view.

# Configuration

By default, Test Navigator will ignore anything contained in node_modules. This will likely be expanded on and configurable in the future.

### Test File Patterns
This setting is a comma separated list of test patterns that determines the possible test or implementation flies. For instance, if Test Navigator is given the pattern Spec, toggling Test Navigator from index.js will cause it to look for indexSpec.js. Conversely, toggling Test Navigator from indexSpec.js will cause it to look for index.js.

### Location
This setting dictates where the found file should appear. By default, it will appear to the right of the open file. Additional options include down and none.

# Key Bindings
The default <code>cmd-alt-n</code> or <code>ctrl-alt-n</code> will toggle test-navigator for the currently open file.

This can be edited by defining key bindings as shown below.

```coffee
'.platform-darwin atom-text-editor':
  'cmd-alt-n': 'test-navigator:navigate'

'.platform-linux atom-text-editor, .platform-win32 atom-text-editor':
  'ctrl-alt-n': 'test-navigator:navigate'
```

### Full change log [here](./CHANGELOG.md).
