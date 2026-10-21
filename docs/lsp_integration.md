# Engine and LSP integration contract

## Responsibilities

- `gdscript_engine` runs lesson code and exercises in-process. It does not
  communicate with Godot or provide real scene-tree nodes.
- `gdscript_lsp` provides editor services in a separate process over LSP
  `stdio`. Its protocol stream uses `stdin` and `stdout`; logs go to `stderr`.
- The Flutter app owns workspace selection, file discovery, filtering, indexing,
  and update notifications. The language server never discovers or reads
  workspace files on its own.

The engine dependency is a local Dart path package. Keep the engine repository
available at the path configured in `pubspec.yaml` before resolving packages.

## Workspace index protocol

After `initialize`, send an explicit `gdscript/updateWorkspaceFiles` request
whenever indexed workspace contents change:

```json
{
  "files": [
    {"uri": "file:///project/scripts/player.gd", "text": "class_name Player\n"}
  ],
  "removedUris": ["file:///project/scripts/old_player.gd"]
}
```

`files` upserts the listed GDScript snapshots; `removedUris` removes snapshots.
The update is atomic. URIs must be absolute and identify `.gd` files. Each
UTF-8 file is limited to 1 MiB, and the server index is limited to 10,000 files.
An invalid or over-limit update returns a JSON-RPC error instead of silently
accepting a partial index. Open document contents override indexed snapshots;
closing a document exposes its indexed snapshot again, if present.

The app must:

1. Choose and retain the workspace root(s).
2. Discover and filter GDScript files, including excluding generated and
   irrelevant directories according to app policy.
3. Send changed file contents and removed URIs as files change or roots change.
4. Avoid sending unrelated workspace files or secrets.

The server uses that content for `workspace/symbol`,
`textDocument/definition`, `textDocument/references`, and the custom
`gdscript/searchWorkspaceText` request. Text search is literal, case-insensitive
by default, and capped at 5,000 matches. References currently match identifier
spelling and are not scope- or type-aware.

Bracket matching is exposed through standard `textDocument/documentHighlight`
and `textDocument/selectionRange`; a visible bracket-pair UI is the editor
client's responsibility.

## Executable and platform support

The LSP server runs as a native subprocess over `stdio`. Use the release
executable matching both the host OS and architecture, or run the server from
source with a compatible Dart SDK. The currently documented release targets are
Linux x64, macOS arm64, and Windows x64.

Launching this subprocess is not supported by this integration on Android,
iOS, or Flutter web. Do not expose local LSP features on those targets unless a
separate compatible hosting/transport solution is implemented. The in-process
Dart engine is a separate dependency and does not require launching the LSP
server.

## Integration tests

Run the Flutter tests from the app root:

```sh
flutter test test/engine_integration_test.dart test/lsp_client_integration_test.dart
```

The LSP integration test uses a sibling `gdscript_lsp` checkout by default.
Set `GDSCRIPT_LSP_PATH` to another server source directory when needed. The
server repository must have its Dart dependencies resolved; the test launches
`dart run bin/gdscript_lsp.dart` as a child process and exercises initialization,
document synchronization, editor features, workspace updates/search, and a
clean shutdown.
