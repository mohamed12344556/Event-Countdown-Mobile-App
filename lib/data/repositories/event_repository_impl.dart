import '../../core/errors/exceptions.dart';
import '../datasources/local/event_local_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl {
  final EventLocalDataSource localDataSource;

  EventRepositoryImpl({required this.localDataSource});

  Future<List<EventModel>> getEvents() async {
    try {
      return await localDataSource.getEvents();
    } on CacheException {
      return [];
    }
  }

  Future<EventModel> getEvent(String id) async {
    return await localDataSource.getEvent(id);
  }

  Future<void> saveEvent(EventModel event) async {
    await localDataSource.cacheEvent(event);
  }

  Future<void> updateEvent(EventModel event) async {
    await localDataSource.updateEvent(event);
  }

  Future<void> deleteEvent(String id) async {
    await localDataSource.deleteEvent(id);
  }
}
