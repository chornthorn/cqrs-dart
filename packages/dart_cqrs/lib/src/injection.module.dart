// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:dart_cqrs/src/core/dispatcher.dart' as _i854;
import 'package:injectable/injectable.dart' as _i526;

class DartCqrsPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.singleton<_i854.CqrsDispatcher>(() => _i854.CqrsDispatcher());
  }
}
