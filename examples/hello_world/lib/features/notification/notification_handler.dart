import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'notification_handler.cqrs.dart';

@CqrsMicroPackage(moduleName: 'Notification')
void configureNotificationHandlers() {}
