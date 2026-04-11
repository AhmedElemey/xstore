import '../../domain/entities/store_hours_entity.dart';
import 'day_schedule_model.dart';

class StoreHoursModel {
  const StoreHoursModel({
    required this.vendorId,
    required this.isStoreOpen,
    required this.temporaryMessage,
    required this.schedule,
    required this.updatedAt,
  });

  final String vendorId;
  final bool isStoreOpen;
  final String? temporaryMessage;
  final List<DayScheduleModel> schedule;
  final DateTime updatedAt;

  factory StoreHoursModel.fromEntity(StoreHoursEntity e) => StoreHoursModel(
        vendorId: e.vendorId,
        isStoreOpen: e.isStoreOpen,
        temporaryMessage: e.temporaryMessage,
        schedule: e.schedule.map(DayScheduleModel.fromEntity).toList(),
        updatedAt: e.updatedAt,
      );

  StoreHoursEntity toEntity() => StoreHoursEntity(
        vendorId: vendorId,
        isStoreOpen: isStoreOpen,
        temporaryMessage: temporaryMessage,
        schedule: schedule.map((e) => e.toEntity()).toList(),
        updatedAt: updatedAt,
      );
}

