# Clipboard
Adventure Game Studio (AGS) plugin for Windows clipboard copy/paste integration.

## How To Use
To use in an AGS game, you have to first add the plugin to the game project and activate it.

### How to Activate Plugin
Place AgsClipboard.dll in the Adventure Game Studio engine folder, e.g. `C:\Program Files (x86)\Adventure Game Studio 3.4.1` (while IDE is not running). Start the IDE and load the game project. Under the "Plugins" entry in the project tree should now appear "AGS Clipboard Plugin vX.Y (agsclipboard.dll)". Right-click and check "Use this plugin". You can now use the plugin.

### How to Use Plugin Features
The plugin provides two methods: `bool Clipboard.CopyText(String copyString)`, which copies a String you provide onto the Windows clipboard (returning `true` if successful), and `String Clipboard.PasteText()`, which returns the String that is currently on the Windows clipboard (or `null` if none). You can use these functions in your game to implement cut, copy and paste functionality (see the demo game).

The plugin also `#define`s two macros: `CLIPBOARD_PLUGIN` and  `CLIPBOARD_PLUGIN_VERSION`, where `CLIPBOARD_PLUGIN_VERSION` is a `float` representation of the plugin version number, with two decimal digits for the minor version (so that e.g. v1.2 is represented as 1.02). That means that you can use `#ifdef`–`#endif` and `#ifndef`–`#endif` blocks in your script, so it only tries to use the clipboard if the plugin is present.

## License and Credits
This code is offered under multiple licenses. Choose whichever one you like.

You may use it under the MIT license:
- https://opensource.org/licenses/MIT

You may also use it under the Creative Commons Attribution 4.0 International License:
- https://creativecommons.org/licenses/by/4.0/

You may also use it under the Artistic License 2.0:
- https://opensource.org/licenses/Artistic-2.0

In game credits, the preferred style is "Clipboard plugin by Snarky" or "Clipboard plugin by Gunnar Harboe", but you can adapt it as you like to the overall style of credit (or leave it out: no in-game credit is required, though it is appreciated).
