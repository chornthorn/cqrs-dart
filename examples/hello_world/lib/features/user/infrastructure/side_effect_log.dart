import 'package:injectable/injectable.dart';

@Injectable(scope: Scope.lazySingleton)
class SideEffectLog {
  final List<String> entries = [];

  void record(String entry) => entries.add(entry);
}
