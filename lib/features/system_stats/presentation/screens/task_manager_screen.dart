import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:taskmanager/core/constants/app_colors.dart';
import 'package:taskmanager/core/constants/app_strings.dart';

import '../cubit/system_stats_cubit.dart';
import '../widgets/stats_card.dart';
import '../widgets/process_action_sheet.dart';

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppStrings.appTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                builder: (context, state) {
                  if (state is SystemStatsLoaded) {
                    return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                      children: [
                        StatsCard(
                          title: AppStrings.cpu,
                          value: '',
                          unit: AppStrings.percentage,
                          color: AppColors.cpuColor,
                          icon: CupertinoIcons.settings,
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  state.stats.cpuUsage.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0');
                            },
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.ram,
                          value: '',
                          unit: AppStrings.percentage,
                          color: AppColors.ramColor,
                          icon: Icons.memory,
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  state.stats.memoryUsage.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0');
                            },
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.network,
                          value: '',
                          unit: AppStrings.networkPerSec,
                          color: AppColors.networkColor,
                          icon: CupertinoIcons.wifi,
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  '${state.stats.networkDownload.toStringAsFixed(1)}/${state.stats.networkUpload.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0/0.0');
                            },
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.disk,
                          value: '',
                          unit: AppStrings.megabytesPerSec,
                          color: AppColors.diskColor,
                          icon: CupertinoIcons.folder,
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  '${state.stats.diskRead.toStringAsFixed(1)} /${state.stats.diskWrite.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0/0.0');
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CupertinoActivityIndicator());
                },
              ),
            ),
            const SizedBox(height: 24),
            // Process List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                AppStrings.processes,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                builder: (context, state) {
                  if (state is SystemStatsLoaded) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.processes.length,
                      itemBuilder: (context, index) {
                        final process = state.processes[index];
                        return GestureDetector(
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ProcessActionSheet(
                                onKill: () async {
                                  Navigator.pop(context);
                                  try {
                                    final result = await Process.run('kill', ['-9', process.pid.toString()]);
                                    if (result.exitCode == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Process ${process.pid} killed.')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to kill process: ${result.stderr}')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                                onShowLog: () async {
                                  Navigator.pop(context);
                                  // Try to show /proc/[pid]/fd/1 (stdout) and /proc/[pid]/fd/2 (stderr)
                                  String log = '';
                                  try {
                                    final stdoutFile = File('/proc/${process.pid}/fd/1');
                                    final stderrFile = File('/proc/${process.pid}/fd/2');
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Process ${process.pid} Log'),
                                      content: SingleChildScrollView(child: Text(log, style: const TextStyle(fontSize: 12))),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onRestart: () async {
                                  Navigator.pop(context);
                                  try {
                                    // Get the command line of the process
                                    final cmdFile = File('/proc/${process.pid}/cmdline');
                                    if (await cmdFile.exists()) {
                                      final cmdline = await cmdFile.readAsString();
                                      final args = cmdline.split('\u0000').where((s) => s.isNotEmpty).toList();
                                      if (args.isNotEmpty) {
                                        await Process.run('kill', ['-9', process.pid.toString()]);
                                        await Future.delayed(const Duration(milliseconds: 300));
                                        await Process.start(args[0], args.sublist(1));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Process ${process.pid} restarted.')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Could not parse command line for restart.')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('No command line found for process.')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    process.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    process.pid.toString(),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${process.cpuUsage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${process.memoryUsage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CupertinoActivityIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}