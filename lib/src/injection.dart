import 'package:injectable/injectable.dart';

/// Generates [DartCqrsPackageModule] so host apps can register this package
/// with injectable's [ExternalModule].
@InjectableInit.microPackage()
void initMicroPackage() {}
