# Godot 4.3 official documentation registry

Use the version-pinned English URL for `documentationSources.url`. The displayed
title belongs in both `ar` and `en`; reference entries should be specific to the
lesson objective rather than a general documentation landing page.

| Topic | Reference | Godot documentation URL | Intended use |
| --- | --- | --- | --- |
| Syntax and execution | GDScript basics | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_basics.html> | Statements, syntax, variables, operators, control flow, functions, and `await` |
| Static typing | GDScript static typing | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/static_typing.html> | Type annotations, inference, and typed collections |
| Style | GDScript style guide | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_styleguide.html> | Naming, formatting, and code organization |
| Documentation comments | GDScript documentation comments | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_documentation_comments.html> | Documenting classes and members |
| Classes | GDScript exports | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_exports.html> | Script properties and exported values |
| Inheritance and classes | GDScript basics: inheritance | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_basics.html#inheritance> | `extends`, class names, and inherited behavior |
| Properties | GDScript basics: setters and getters | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_basics.html#setters-and-getters> | Property accessors |
| Signals | Using signals | <https://docs.godotengine.org/en/4.3/getting_started/step_by_step/signals.html> | Connecting and emitting signals |
| Nodes | Nodes and scene instances | <https://docs.godotengine.org/en/4.3/tutorials/scripting/nodes_and_scene_instances.html> | Node references and scene composition |
| Scene tree | SceneTree class | <https://docs.godotengine.org/en/4.3/classes/class_scenetree.html> | Scene-tree ownership and lifecycle |
| Node lifecycle | Node class | <https://docs.godotengine.org/en/4.3/classes/class_node.html> | `_ready`, `_process`, groups, and node paths |
| Groups | Groups | <https://docs.godotengine.org/en/4.3/tutorials/scripting/groups.html> | Adding nodes to groups and calling group methods |
| Packed scenes | PackedScene class | <https://docs.godotengine.org/en/4.3/classes/class_packedscene.html> | Instantiating and adding scenes |
| Input events | InputEvent class | <https://docs.godotengine.org/en/4.3/classes/class_inputevent.html> | Event-driven input handling |
| Input actions | Input examples | <https://docs.godotengine.org/en/4.3/tutorials/inputs/input_examples.html> | InputMap actions and querying input |
| Resources | Resources | <https://docs.godotengine.org/en/4.3/tutorials/scripting/resources.html> | Resource creation, loading, and reuse |
| Resource class | Resource class | <https://docs.godotengine.org/en/4.3/classes/class_resource.html> | Resource identity and lifecycle |
| Saving | Saving games | <https://docs.godotengine.org/en/4.3/tutorials/io/saving_games.html> | Persisting and restoring game data |
| Configuration files | ConfigFile class | <https://docs.godotengine.org/en/4.3/classes/class_configfile.html> | INI-style section and key settings |
| Coroutines and `await` | GDScript basics: coroutines | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_basics.html#coroutines> | Awaiting signals and asynchronous flow |
| Timers | Timer class | <https://docs.godotengine.org/en/4.3/classes/class_timer.html> | Timeouts and timer lifecycle |
| Warnings and debugging | GDScript warning system | <https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/warning_system.html> | Warning configuration and handling |
| Debugger panel | Debugger panel | <https://docs.godotengine.org/en/4.3/tutorials/scripting/debug/debugger_panel.html> | Breakpoints, errors, and runtime inspection |

## Authoring rules

1. Keep the URL pinned to `/en/4.3/`; do not use `/en/stable/` or a redirecting
   `latest` URL.
2. Link to the most specific official tutorial or class reference available.
3. Use a short Arabic and English title in the source object:

```json
{
   "title": {"ar": "أساسيات GDScript", "en": "GDScript basics"},
   "url": "https://docs.godotengine.org/en/4.3/tutorials/scripting/gdscript/gdscript_basics.html"
}
```

1. Run `dart run tool/validate_curriculum.dart --check-links` when network
   access is available. The routine offline audit verifies host and version
   without issuing HTTP requests.
