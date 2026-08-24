import 'package:injectable/injectable.dart';

@lazySingleton
class SideEffectLog {
  final List<String> entries = [];

  void record(String entry) => entries.add(entry);
}
