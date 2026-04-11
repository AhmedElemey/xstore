import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_store_hours.dart';
import '../models/store_hours_model.dart';

abstract interface class StoreHoursDataSource {
  Future<StoreHoursModel> getStoreHours(String vendorId);
  Future<StoreHoursModel> updateStoreHours(StoreHoursModel hours);
  Future<bool> toggleStoreStatus(String vendorId, bool isOpen);
}

class StoreHoursDataSourceImpl implements StoreHoursDataSource {
  static StoreHoursModel _cache = StoreHoursModel.fromEntity(mockStoreHours);

  @override
  Future<StoreHoursModel> getStoreHours(String vendorId) async {
    if (MockConfig.useMock) {
      return MockConfig.simulate(_cache);
    }
    throw UnimplementedError();
  }

  @override
  Future<StoreHoursModel> updateStoreHours(StoreHoursModel hours) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _cache = hours;
      return hours;
    }
    throw UnimplementedError();
  }

  @override
  Future<bool> toggleStoreStatus(String vendorId, bool isOpen) async {
    if (MockConfig.useMock) {
      await MockConfig.simulate(null);
      _cache = StoreHoursModel(
        vendorId: _cache.vendorId,
        isStoreOpen: isOpen,
        temporaryMessage: _cache.temporaryMessage,
        schedule: _cache.schedule,
        updatedAt: DateTime.now(),
      );
      return isOpen;
    }
    throw UnimplementedError();
  }
}

