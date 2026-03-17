import '../../../core/api/mobile_api.dart';
import '../../../core/notifications/supplier_runtime_store.dart';
import '../../shared/models/app_models.dart';
import 'package:flutter/foundation.dart';

class SupplierStore extends ChangeNotifier {
  SupplierStore._() {
    SupplierRuntimeStore.instance.addListener(_forwardRuntimeChange);
  }

  static final SupplierStore instance = SupplierStore._();

  bool _loadingSummary = false;
  bool _loadingHistory = false;
  bool _loadedSummary = false;
  bool _loadedHistory = false;
  Object? _summaryError;
  Object? _historyError;

  SupplierHomeSummary _summary = const SupplierHomeSummary(
    pendingCount: 0,
    submittedCount: 0,
    returnedCount: 0,
  );
  List<DispatchRecord> _historyItems = const <DispatchRecord>[];

  bool get loadingSummary => _loadingSummary;
  bool get loadingHistory => _loadingHistory;
  bool get loadedSummary => _loadedSummary;
  bool get loadedHistory => _loadedHistory;
  Object? get summaryError => _summaryError;
  Object? get historyError => _historyError;

  SupplierHomeSummary get summary =>
      SupplierRuntimeStore.instance.applySummary(_summary);
  List<DispatchRecord> get historyItems => _historyItems;

  Future<void> bootstrapSummary({bool force = false}) async {
    if (_loadingSummary) return;
    if (_loadedSummary && !force) return;
    await refreshSummary();
  }

  Future<void> bootstrapHistory({bool force = false}) async {
    if (_loadingHistory) return;
    if (_loadedHistory && !force) return;
    await refreshHistory();
  }

  Future<void> refreshSummary() async {
    if (_loadingSummary) return;
    _loadingSummary = true;
    _summaryError = null;
    notifyListeners();
    try {
      _summary = await MobileApi.instance.supplierSummary();
      _loadedSummary = true;
    } catch (error) {
      _summaryError = error;
    } finally {
      _loadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> refreshHistory() async {
    if (_loadingHistory) return;
    _loadingHistory = true;
    _historyError = null;
    notifyListeners();
    try {
      _historyItems = await MobileApi.instance.supplierHistory();
      _loadedHistory = true;
    } catch (error) {
      _historyError = error;
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      refreshSummary(),
      refreshHistory(),
    ]);
  }

  void recordCreatedPending() {
    SupplierRuntimeStore.instance.recordCreatedPending();
  }

  void recordUnannouncedDecision({
    required DispatchStatus fromStatus,
    required DispatchStatus toStatus,
  }) {
    SupplierRuntimeStore.instance.recordUnannouncedDecision(
      fromStatus: fromStatus,
      toStatus: toStatus,
    );
  }

  void _forwardRuntimeChange() {
    notifyListeners();
  }
}
