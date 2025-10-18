// utils/event_bus.dart
import 'dart:async';

class ProfileUpdatedEvent {
  final DateTime timestamp = DateTime.now();
  final String? userId;
  final String? fieldUpdated;

  ProfileUpdatedEvent({this.userId, this.fieldUpdated});

  @override
  String toString() => 'ProfileUpdatedEvent(userId: $userId, field: $fieldUpdated, $timestamp)';
}

class UserDataRefreshedEvent {
  final DateTime timestamp = DateTime.now();
  final String? userId;

  UserDataRefreshedEvent({this.userId});

  @override
  String toString() => 'UserDataRefreshedEvent(userId: $userId, $timestamp)';
}

class ImageUploadCompletedEvent {
  final String imageUrl;
  final String userId;
  final DateTime timestamp = DateTime.now();

  ImageUploadCompletedEvent({
    required this.imageUrl,
    required this.userId,
  });

  @override
  String toString() => 'ImageUploadCompletedEvent(userId: $userId, url: $imageUrl, $timestamp)';
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _controller = StreamController<dynamic>.broadcast();

  /// Listen to specific event type and return StreamSubscription
  StreamSubscription<T> listen<T>(void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream
        .where((event) => event is T)
        .cast<T>()
        .listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Alternative method that returns StreamSubscription directly
  StreamSubscription<T> subscribe<T>(void Function(T) listener) {
    return _controller.stream
        .where((event) => event is T)
        .cast<T>()
        .listen(listener);
  }

  /// Get stream for specific event type
  Stream<T> on<T>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// Fire an event
  void fire(dynamic event) {
    print('EventBus: Firing event - ${event.runtimeType}');
    _controller.add(event);
  }

  /// Fire profile updated event
  void fireProfileUpdated({String? userId, String? fieldUpdated}) {
    fire(ProfileUpdatedEvent(userId: userId, fieldUpdated: fieldUpdated));
  }

  /// Fire user data refreshed event
  void fireUserDataRefreshed({String? userId}) {
    fire(UserDataRefreshedEvent(userId: userId));
  }

  /// Fire image upload completed event
  void fireImageUploadCompleted({required String imageUrl, required String userId}) {
    fire(ImageUploadCompletedEvent(imageUrl: imageUrl, userId: userId));
  }

  void dispose() {
    _controller.close();
  }
}