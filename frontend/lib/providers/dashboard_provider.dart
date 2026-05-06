import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../data/models/dashboard_model.dart';
import '../data/services/dashboard_service.dart';

final adminDashboardProvider = StateNotifierProvider<AdminDashboardNotifier, AsyncValue<AdminDashboard>>((ref) {
  return AdminDashboardNotifier(ref);
});

class AdminDashboardNotifier extends StateNotifier<AsyncValue<AdminDashboard>> {
  final Ref _ref;
  AdminDashboardNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _ref.read(dashboardServiceProvider).getAdminDashboard();
      state = AsyncValue.data(data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    }
  }
}

final memberDashboardProvider = StateNotifierProvider<MemberDashboardNotifier, AsyncValue<MemberDashboard>>((ref) {
  return MemberDashboardNotifier(ref);
});

class MemberDashboardNotifier extends StateNotifier<AsyncValue<MemberDashboard>> {
  final Ref _ref;
  MemberDashboardNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _ref.read(dashboardServiceProvider).getMemberDashboard();
      state = AsyncValue.data(data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    }
  }
}
