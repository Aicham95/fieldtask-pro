import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/interventions/data/services/local_notification_scheduler.dart';
import '../../features/interventions/domain/services/reminder_scheduler.dart';
import '../../features/interventions/domain/usecases/save_field_work.dart';
import '../../features/interventions/domain/usecases/schedule_reminder.dart';
import '../../features/map/data/datasources/location_datasource.dart';
import '../../features/map/data/repositories/location_repository_impl.dart';
import '../../features/map/domain/entities/geo_position.dart';
import '../../features/map/domain/usecases/get_current_position.dart';
import 'interventions_providers.dart';

/// Providers du Lot 3 : travail terrain, rappels, localisation.

final saveFieldWorkProvider = Provider<SaveFieldWork>(
    (ref) => SaveFieldWork(ref.watch(interventionRepositoryProvider)));

final reminderSchedulerProvider =
    Provider<ReminderScheduler>((ref) => LocalNotificationScheduler());

final scheduleReminderProvider = Provider<ScheduleReminder>(
    (ref) => ScheduleReminder(ref.watch(reminderSchedulerProvider)));

final getCurrentPositionProvider = Provider<GetCurrentPosition>((ref) =>
    GetCurrentPosition(LocationRepositoryImpl(LocationDataSource())));

/// Position du technicien (null si refusée). Se recharge avec ref.invalidate.
final currentPositionProvider = FutureProvider<GeoPosition?>(
    (ref) => ref.watch(getCurrentPositionProvider)());
