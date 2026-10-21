import 'dart:ffi';
import 'dart:io';

import 'language_server_client.dart';
import 'lsp_process_transport.dart';

class LanguageServerExecutable {
  const LanguageServerExecutable({
    required this.path,
    this.arguments = const [],
    this.workingDirectory,
  });

  final String path;
  final List<String> arguments;
  final String? workingDirectory;

  Future<LanguageServerClient> start() async {
    final transport = await ProcessLspTransport.start(
      path,
      arguments: arguments,
      workingDirectory: workingDirectory,
    );
    return LanguageServerClient(transport);
  }
}

class LanguageServerFactory {
  const LanguageServerFactory();

  LanguageServerExecutable resolve({String? executablePath}) {
    final platformFile = _platformExecutableName();
    final configured =
        executablePath ?? Platform.environment['GDSCRIPT_LSP_EXECUTABLE'];
    final path =
        configured ??
        '${Directory.current.parent.path}/gdscript_lsp/build/$platformFile';
    if (!File(path).existsSync()) {
      throw FileSystemException(
        'Configure GDSCRIPT_LSP_EXECUTABLE or build the platform executable.',
        path,
      );
    }
    return LanguageServerExecutable(path: path);
  }

  String _platformExecutableName() {
    final architecture = Abi.current().toString();
    return switch ((Platform.operatingSystem, architecture)) {
      ('linux', 'Abi.linuxX64') => 'gdscript_lsp-linux-x64',
      ('linux', 'Abi.linuxArm64') => 'gdscript_lsp-linux-arm64',
      ('macos', 'Abi.macosX64') => 'gdscript_lsp-macos-x64',
      ('macos', 'Abi.macosArm64') => 'gdscript_lsp-macos-arm64',
      ('windows', 'Abi.windowsX64') => 'gdscript_lsp-windows-x64.exe',
      ('android', _) || ('ios', _) || ('web', _) => throw UnsupportedError(
        'Local GDScript LSP subprocesses are unsupported on '
        '${Platform.operatingSystem}.',
      ),
      _ => throw UnsupportedError(
        'No GDScript LSP executable is defined for '
        '${Platform.operatingSystem} ($architecture).',
      ),
    };
  }
}
