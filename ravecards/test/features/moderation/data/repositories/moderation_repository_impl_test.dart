import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ravecards/features/moderation/data/repositories/moderation_repository_impl.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}
class MockHttpsCallable extends Mock implements HttpsCallable {}
class MockHttpsCallableResult extends Mock implements HttpsCallableResult {}

void main() {
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late MockHttpsCallableResult callableResult;

  setUp(() {
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    callableResult = MockHttpsCallableResult();
    when(() => functions.httpsCallable(any())).thenReturn(callable);
    when(() => callable.call(any())).thenAnswer((_) async => callableResult);
    when(() => callableResult.data).thenReturn({'ok': true});
  });

  group('ModerationRepositoryImpl', () {
    late ModerationRepositoryImpl repo;

    setUp(() => repo = ModerationRepositoryImpl(functions: functions));

    test('revokeLink returns Right(null) on success', () async {
      final result = await repo.revokeLink('link-1');
      expect(result, const Right(null));
    });

    test('blockUser returns Right(null) on success', () async {
      final result = await repo.blockUser(targetUid: 'uid-b');
      expect(result, const Right(null));
    });

    test('reportUser returns Right(null) on success', () async {
      final result = await repo.reportUser(targetUid: 'uid-b', reason: 'spam');
      expect(result, const Right(null));
    });

    test('revokeLink returns Left(ModerationFailure) on exception', () async {
      when(() => callable.call(any())).thenThrow(Exception('network error'));
      final result = await repo.revokeLink('link-1');
      result.fold(
        (f) => expect(f.message, contains('network error')),
        (_) => fail('expected Left'),
      );
    });
  });
}
