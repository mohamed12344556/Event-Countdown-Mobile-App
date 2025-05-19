import 'package:sqflite/sqflite.dart';

import '../../../core/errors/exceptions.dart';
import '../../models/event_model.dart';

abstract class EventLocalDataSource {
  /// Gets all the cached events
  ///
  /// Throws [CacheException] if no cached data is present
  Future<List<EventModel>> getEvents();

  /// Gets a specific event by its ID
  ///
  /// Throws [CacheException] if no cached data is present
  Future<EventModel> getEvent(String id);

  /// Caches a new event
  Future<void> cacheEvent(EventModel eventToCache);

  /// Updates an existing event
  Future<void> updateEvent(EventModel eventToUpdate);

  /// Deletes an event by its ID
  Future<void> deleteEvent(String id);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final Database database;

  EventLocalDataSourceImpl({required this.database});

  @override
  Future<List<EventModel>> getEvents() async {
    final eventsMap = await database.query('events');

    if (eventsMap.isEmpty) {
      return [];
    }

    return eventsMap.map((map) => EventModel.fromMap(map)).toList();
  }

  @override
  Future<EventModel> getEvent(String id) async {
    final eventMap = await database.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (eventMap.isEmpty) {
      throw CacheException();
    }

    return EventModel.fromMap(eventMap.first);
  }

  @override
  Future<void> cacheEvent(EventModel eventToCache) async {
    try {
      print("Caching event: ${eventToCache.title}");
      await database.insert(
        'events',
        eventToCache.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Event cached successfully");
    } catch (e) {
      print("Database error: $e");
      throw CacheException();
    }
  }

  @override
  Future<void> updateEvent(EventModel eventToUpdate) async {
    final rowsAffected = await database.update(
      'events',
      eventToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [eventToUpdate.id],
    );

    if (rowsAffected == 0) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    final rowsAffected = await database.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rowsAffected == 0) {
      throw CacheException();
    }
  }
}
