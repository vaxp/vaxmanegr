import 'dart:io';

class ProcessActions {
  static Future<String> killProcess(int pid) async {
    try {
      final result = await Process.run('kill', ['-9', pid.toString()]);
      if (result.exitCode == 0) {
        return 'Process $pid killed.';
      } else {
        return 'Failed to kill process: ${result.stderr}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<String> showProcessLog(int pid) async {
    String log = '';
    try {
      final stdoutFile = File('/proc/$pid/fd/1');
      final stderrFile = File('/proc/$pid/fd/2');
      if (await stdoutFile.exists()) {
        log += '--- STDOUT ---\n';
        log += await stdoutFile.readAsString();
      }
      if (await stderrFile.exists()) {
        log += '\n--- STDERR ---\n';
        log += await stderrFile.readAsString();
      }
      if (log.isEmpty) log = 'No log available for this process.';
    } catch (e) {
      log = 'Could not read log: $e';
    }
    return log;
  }

  static Future<String> restartProcess(int pid) async {
    try {
      final cmdFile = File('/proc/$pid/cmdline');
      if (await cmdFile.exists()) {
        final cmdline = await cmdFile.readAsString();
        final args = cmdline.split('\u0000').where((s) => s.isNotEmpty).toList();
        if (args.isNotEmpty) {
          await Process.run('kill', ['-9', pid.toString()]);
          await Future.delayed(const Duration(milliseconds: 300));
          await Process.start(args[0], args.sublist(1));
          return 'Process $pid restarted.';
        } else {
          return 'Could not parse command line for restart.';
        }
      } else {
        return 'No command line found for process.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
