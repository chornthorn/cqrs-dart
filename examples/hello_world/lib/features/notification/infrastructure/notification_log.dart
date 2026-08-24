import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationLog {
  final List<String> entries = [];

  void record(String entry) => entries.add(entry);
}
