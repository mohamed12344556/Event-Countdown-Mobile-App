import 'package:equatable/equatable.dart';

import '../../../data/models/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventsLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventModel> events;

  const EventsLoaded({required this.events});

  @override
  List<Object> get props => [events];
}

class EventLoaded extends EventState {
  final EventModel event;

  const EventLoaded({required this.event});

  @override
  List<Object> get props => [event];
}

class EventError extends EventState {
  final String message;

  const EventError({required this.message});

  @override
  List<Object> get props => [message];
}

class EventSaved extends EventState {}

class EventDeleted extends EventState {}
