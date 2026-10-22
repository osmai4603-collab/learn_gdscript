import 'dart:io';

import 'lsp_transport.dart';

class ProcessLspTransport implements LspTransport {
  ProcessLspTransport(this._process);

  final Process _process;

  static Future<ProcessLspTransport> start(
    String executablePath, {
    List<String> arguments = const [],
    String? workingDirectory,
  }) async {
    if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
      throw UnsupportedError(
        'Local GDScript LSP subprocesses are unsupported on '
        '${Platform.operatingSystem}.',
      );
    }
    final executable = File(executablePath);
    if (!await executable.exists()) {
      throw FileSystemException(
        'Language server executable was not found.',
        executablePath,
      );
    }
    final process = await Process.start(
      executablePath,
      arguments,
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.normal,
    );
    return ProcessLspTransport(process);
  }

  @override
  Stream<List<int>> get stdoutBytes => _process.stdout;

  @override
  Stream<List<int>> get stderrBytes => _process.stderr;

  @override
  Future<int> get exitCode => _process.exitCode;

  @override
  Future<void> write(List<int> bytes) async {
    _process.stdin.add(bytes);
    await _process.stdin.flush();
  }

  @override
  Future<void> closeInput() async {
    await _process.stdin.close();
  }

  @override
  Future<void> kill() async {
    _process.kill();
    await _process.exitCode;
  }
}
