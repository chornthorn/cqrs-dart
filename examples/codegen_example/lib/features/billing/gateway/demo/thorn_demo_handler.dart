
import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'thorn_demo_handler.cqrs.dart';

@CqrsMicroPackage(moduleName: 'ThornDemo')
void configureThornDemoHandlers() {}
