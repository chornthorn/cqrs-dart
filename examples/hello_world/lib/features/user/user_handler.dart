import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'user_handler.cqrs.dart';

@CqrsMicroPackage(moduleName: 'User')
void configureUserHandlers() {}
