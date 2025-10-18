import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_size/window_size.dart';
import 'features/system_stats/data/repositories/system_stats_repository.dart';
import 'features/system_stats/presentation/cubit/system_stats_cubit.dart';
import 'features/system_stats/presentation/screens/task_manager_screen.dart';
import 'core/constants/app_strings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Calculator');
    const fixedSize = Size(732, 935); 
    setWindowMinSize(fixedSize);
    setWindowMaxSize(fixedSize);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        brightness: Brightness.dark,
      ),
      home: BlocProvider(
        create: (context) => SystemStatsCubit(SystemStatsRepository()),
        child: const TaskManagerScreen(),
      ),
    );
  }
}
