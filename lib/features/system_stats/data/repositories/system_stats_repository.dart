import 'dart:async';
import 'dart:io';
import 'package:process_run/shell.dart';
import '../models/system_stats_model.dart';

class SystemStatsRepository {
  final Shell _shell = Shell();
  Timer? _cpuTimer;
  List<double>? _lastCpuStats;

  Future<double> _getCpuUsage() async {
    try {
      final File statFile = File('/proc/stat');
      final List<String> lines = await statFile.readAsLines();
      final String cpuLine = lines.first;
      final List<String> values = cpuLine.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).skip(1).toList();
      
      final List<double> stats = values.map((v) => double.tryParse(v) ?? 0).toList();
      
      if (_lastCpuStats == null) {
        _lastCpuStats = stats;
        await Future.delayed(const Duration(milliseconds: 100));
        return await _getCpuUsage();
      }

      final List<double> prevStats = _lastCpuStats!;
      _lastCpuStats = stats;

      final double prevIdle = prevStats[3] + prevStats[4];
      final double idle = stats[3] + stats[4];

      final double prevTotal = prevStats.reduce((a, b) => a + b);
      final double total = stats.reduce((a, b) => a + b);

      final double totalDiff = total - prevTotal;
      final double idleDiff = idle - prevIdle;

      return ((totalDiff - idleDiff) / totalDiff) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  Future<Map<String, double>> _getMemoryInfo() async {
    try {
      final File memFile = File('/proc/meminfo');
      final List<String> lines = await memFile.readAsLines();
      
      int totalKb = 0;
      int availableKb = 0;
      
      for (final line in lines) {
        if (line.startsWith('MemTotal:')) {
          totalKb = int.parse(line.split(RegExp(r'\s+')).elementAt(1));
        } else if (line.startsWith('MemAvailable:')) {
          availableKb = int.parse(line.split(RegExp(r'\s+')).elementAt(1));
        }
      }
      
      final double totalMb = totalKb / 1024;
      final double usedMb = (totalKb - availableKb) / 1024;
      final double percentage = (usedMb / totalMb) * 100;
      
      return {
        'total': totalMb,
        'used': usedMb,
        'percentage': percentage,
      };
    } catch (e) {
      return {
        'total': 0.0,
        'used': 0.0,
        'percentage': 0.0,
      };
    }
  }

  Future<Map<String, double>> _getDiskStats() async {
    try {
      final result = await _shell.run('iostat -d -k 1 1');
      final lines = result.outLines.toList(); // Ensure lines is a List
      double diskRead = 0.0;
      double diskWrite = 0.0;
      
      if (lines.length > 3) {
        final stats = lines[3].split(RegExp(r'\s+'));
        if (stats.length > 2) {
          diskRead = double.tryParse(stats[2]) ?? 0.0;
          diskWrite = double.tryParse(stats[3]) ?? 0.0;
        }
      }
      
      return {
        'read': diskRead,
        'write': diskWrite,
      };
    } catch (e) {
      return {
        'read': 0.0,
        'write': 0.0,
      };
    }
  }

  Map<String, int>? _lastNetworkBytes;
  DateTime? _lastNetworkTime;

  Future<Map<String, double>> _getNetworkStats() async {
    try {
      final netFile = File('/proc/net/dev');
      final netLines = await netFile.readAsLines();
      int totalRx = 0;
      int totalTx = 0;

      for (final line in netLines.skip(2)) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.isEmpty) continue;
        final iface = parts[0].replaceAll(':', '');
        if (iface == 'lo' || iface.isEmpty) continue;
        totalRx += int.tryParse(parts[1]) ?? 0;
        totalTx += int.tryParse(parts[9]) ?? 0;
      }

      final now = DateTime.now();
      double downloadKbps = 0.0;
      double uploadKbps = 0.0;

      if (_lastNetworkBytes != null && _lastNetworkTime != null) {
        final elapsed = now.difference(_lastNetworkTime!).inMilliseconds;
        if (elapsed > 0) {
          final rxDiff = totalRx - (_lastNetworkBytes!['rx'] ?? 0);
          final txDiff = totalTx - (_lastNetworkBytes!['tx'] ?? 0);
          downloadKbps = rxDiff / (elapsed / 1000) / 1024; // KB/s
          uploadKbps = txDiff / (elapsed / 1000) / 1024;   // KB/s
        }
      }

      _lastNetworkBytes = {'rx': totalRx, 'tx': totalTx};
      _lastNetworkTime = now;

      return {
        'upload': uploadKbps,
        'download': downloadKbps,
      };
    } catch (e) {
      return {
        'upload': 0.0,
        'download': 0.0,
      };
    }
  }

  Future<SystemStats> getSystemStats() async {
    try {
      final cpuUsage = await _getCpuUsage();
      final memoryInfo = await _getMemoryInfo();
      final diskStats = await _getDiskStats();
      final networkStats = await _getNetworkStats();

      return SystemStats(
        cpuUsage: cpuUsage,
        memoryUsage: memoryInfo['percentage'] ?? 0.0,
        totalMemory: memoryInfo['total'] ?? 0.0,
        networkUpload: networkStats['upload'] ?? 0.0,
        networkDownload: networkStats['download'] ?? 0.0,
        diskRead: diskStats['read'] ?? 0.0,
        diskWrite: diskStats['write'] ?? 0.0,
      );
    } catch (e) {
      throw Exception('Failed to get system stats: $e');
    }
  }

  Future<List<ProcessInfo>> getProcesses() async {
    try {
      final result = await _shell.run('ps aux --sort=-%cpu');
      final lines = result.outLines.toList(); // Ensure lines is a List
      
      if (lines.isEmpty) return [];
      lines.removeAt(0); // Remove header after converting to List
      
      return lines.where((line) => line.trim().isNotEmpty).map((line) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 11) {
          return ProcessInfo(
            name: 'Unknown',
            pid: 0,
            cpuUsage: 0.0,
            memoryUsage: 0.0,
          );
        }
        return ProcessInfo(
          name: parts[10],
          pid: int.parse(parts[1]),
          cpuUsage: double.tryParse(parts[2]) ?? 0.0,
          memoryUsage: double.tryParse(parts[3]) ?? 0.0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get processes: $e');
    }
  }

  void dispose() {
    _cpuTimer?.cancel();
    _lastCpuStats = null;
  }
}
