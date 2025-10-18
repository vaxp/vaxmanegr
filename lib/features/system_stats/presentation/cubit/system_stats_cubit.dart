import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/system_stats_model.dart';
import '../../data/repositories/system_stats_repository.dart';

/// ====== States ======
abstract class SystemStatsState extends Equatable {
  @override
  List<Object> get props => [];
}

class SystemStatsInitial extends SystemStatsState {}

class SystemStatsLoading extends SystemStatsState {}

class SystemStatsLoaded extends SystemStatsState {
  final SystemStats stats;
  final List<ProcessInfo> processes;

   SystemStatsLoaded({
    required this.stats,
    required this.processes,
  });

  @override
  List<Object> get props => [stats, processes];
}

class SystemStatsError extends SystemStatsState {
  final String message;

   SystemStatsError(this.message);

  @override
  List<Object> get props => [message];
}

/// ====== Cubit ======
class SystemStatsCubit extends Cubit<SystemStatsState> {
  final SystemStatsRepository repository;
  Timer? _timer;

  SystemStatsCubit(this.repository) : super(SystemStatsInitial()) {
    startUpdates();
  }

  void startUpdates() {
    _timer?.cancel();
    // يمكنك تغيير المدة هنا حسب رغبتك
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchStats();
    });
    // تحميل أول مرة
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      // فقط في البداية نعرض Loading
      if (state is SystemStatsInitial) {
        emit(SystemStatsLoading());
      }

      final stats = await repository.getSystemStats();
      final processes = await repository.getProcesses();

      final newState = SystemStatsLoaded(stats: stats, processes: processes);

      // إذا الحالة الحالية Loaded ولم تتغير البيانات -> لا تبعث emit
      if (state is SystemStatsLoaded) {
        final current = state as SystemStatsLoaded;
        if (current.stats == newState.stats &&
            _areProcessesEqual(current.processes, newState.processes)) {
          return; // لا تغيّر
        }
      }

      emit(newState);
    } catch (e) {
      emit(SystemStatsError(e.toString()));
    }
  }

  bool _areProcessesEqual(List<ProcessInfo> a, List<ProcessInfo> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
