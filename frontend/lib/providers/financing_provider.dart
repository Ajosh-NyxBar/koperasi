import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../data/models/financing_model.dart';
import '../data/services/financing_service.dart';

final financingListProvider = StateNotifierProvider<FinancingListNotifier, FinancingListState>((ref) {
  return FinancingListNotifier(ref);
});

class FinancingListState {
  final List<FinancingModel> items;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? statusFilter;
  final String? error;

  const FinancingListState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.statusFilter,
    this.error,
  });

  FinancingListState copyWith({
    List<FinancingModel>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? statusFilter,
    String? error,
  }) {
    return FinancingListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      statusFilter: statusFilter ?? this.statusFilter,
      error: error,
    );
  }
}

class FinancingListNotifier extends StateNotifier<FinancingListState> {
  final Ref _ref;
  FinancingListNotifier(this._ref) : super(const FinancingListState());

  FinancingService get _service => _ref.read(financingServiceProvider);

  Future<void> load({String? status, int? memberId}) async {
    state = FinancingListState(isLoading: true, statusFilter: status);
    try {
      final result = await _service.getFinancings(page: 1, status: status, memberId: memberId);
      state = state.copyWith(
        items: result.items,
        hasMore: result.hasMore,
        page: 1,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadMore({int? memberId}) async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final next = state.page + 1;
      final result = await _service.getFinancings(
        page: next,
        status: state.statusFilter,
        memberId: memberId,
      );
      state = state.copyWith(
        items: [...state.items, ...result.items],
        hasMore: result.hasMore,
        page: next,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }
}

final simulationProvider = StateNotifierProvider<SimulationNotifier, AsyncValue<SimulationResult?>>((ref) {
  return SimulationNotifier(ref);
});

class SimulationNotifier extends StateNotifier<AsyncValue<SimulationResult?>> {
  final Ref _ref;
  SimulationNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> simulate(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ref.read(financingServiceProvider).simulate(data);
      state = AsyncValue.data(result);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}
