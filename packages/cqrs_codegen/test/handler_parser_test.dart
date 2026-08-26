import 'package:cqrs_codegen/cqrs_codegen.dart';
import 'package:test/test.dart';

void main() {
  group('HandlerInfo', () {
    test('formats paramName correctly', () {
      final info = HandlerInfo(
        className: 'CreateUserCommandHandler',
        kind: HandlerKind.command,
        messageTypeName: 'CreateUserCommand',
        resultTypeName: 'User',
        hasDefaultConstructor: false,
      );

      expect(info.paramName, 'createUserCommandHandler');
      expect(info.className, 'CreateUserCommandHandler');
      expect(info.kind, HandlerKind.command);
      expect(info.messageTypeName, 'CreateUserCommand');
      expect(info.resultTypeName, 'User');
      expect(info.hasDefaultConstructor, isFalse);
    });

    test('formats query and event HandlerInfo correctly', () {
      final queryInfo = HandlerInfo(
        className: 'GetUserQueryHandler',
        kind: HandlerKind.query,
        messageTypeName: 'GetUserQuery',
        resultTypeName: 'User',
        hasDefaultConstructor: true,
      );
      expect(queryInfo.paramName, 'getUserQueryHandler');
      expect(queryInfo.hasDefaultConstructor, isTrue);

      final eventInfo = HandlerInfo(
        className: 'WelcomeEmailHandler',
        kind: HandlerKind.event,
        messageTypeName: 'UserCreatedEvent',
        hasDefaultConstructor: true,
      );
      expect(eventInfo.paramName, 'welcomeEmailHandler');
      expect(eventInfo.resultTypeName, isNull);
    });
  });

  group('CqrsMicroPackage annotation naming conventions', () {
    // Verifies the expected module class name derivation from moduleName.
    // The actual generator uses this pattern: '${_capitalize(moduleName)}CqrsModule'
    test('module class name follows {moduleName}CqrsModule convention', () {
      // Simulate the capitalization logic used in CqrsGenerator
      String capitalize(String s) =>
          s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

      expect('${capitalize("orders")}CqrsModule', 'OrdersCqrsModule');
      expect('${capitalize("auth")}CqrsModule', 'AuthCqrsModule');
      expect('${capitalize("billing")}CqrsModule', 'BillingCqrsModule');
    });

    test('extension name follows AutoRegister{moduleName}Cqrs convention', () {
      String capitalize(String s) =>
          s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

      expect('AutoRegister${capitalize("orders")}Cqrs', 'AutoRegisterOrdersCqrs');
    });

    test('method name follows register{moduleName}Handlers convention', () {
      String capitalize(String s) =>
          s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

      expect('register${capitalize("orders")}Handlers', 'registerOrdersHandlers');
    });
  });
}
