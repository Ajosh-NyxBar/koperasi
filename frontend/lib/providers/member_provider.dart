import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../data/models/member_model.dart';
import '../data/services/member_service.dart';

final memberListProvider = StateNotifierProvider<MemberListNotifier, MemberListState>((ref) {
  return MemberListNotifier(ref);
});

class MemberListState {
  final List<MemberModel> members;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;
  final String search;

  const MemberListState({
    this.members = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
    this.search = '',
  });

  MemberListState copyWith({
    List<MemberModel>? members,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
    String? search,
  }) {
    return MemberListState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
      search: search ?? this.search,
    );
  }
}

class MemberListNotifier extends StateNotifier<MemberListState> {
  final Ref _ref;
  MemberListNotifier(this._ref) : super(const MemberListState());

  MemberService get _service => _ref.read(memberServiceProvider);

  Future<void> load({String? search}) async {
    state = MemberListState(isLoading: true, search: search ?? state.search);
    try {
      final result = await _service.getMembers(page: 1, search: state.search.isEmpty ? null : state.search);
      state = state.copyWith(
        members: result.items,
        hasMore: result.hasMore,
        page: 1,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final next = state.page + 1;
      final result = await _service.getMembers(page: next, search: state.search.isEmpty ? null : state.search);
      state = state.copyWith(
        members: [...state.members, ...result.items],
        hasMore: result.hasMore,
        page: next,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _service.createMember(data);
      await load();
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      await _service.updateMember(id, data);
      await load();
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _service.deleteMember(id);
      await load();
      return true;
    } on ApiException {
      return false;
    }
  }
}
