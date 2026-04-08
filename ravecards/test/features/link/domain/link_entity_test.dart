import 'package:flutter_test/flutter_test.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';

void main() {
  const link = LinkEntity(
    linkId: 'link-1',
    userA: 'user-a',
    userB: 'user-b',
    status: 'pending',
    initiatedBy: 'user-a',
    createdAt: null,
  );

  test('otherUser returns userB when called with userA uid', () {
    expect(link.otherUser('user-a'), 'user-b');
  });

  test('otherUser returns userA when called with userB uid', () {
    expect(link.otherUser('user-b'), 'user-a');
  });

  test('isPending is true when status is pending', () {
    expect(link.isPending, isTrue);
  });

  test('isLinked is false when status is pending', () {
    expect(link.isLinked, isFalse);
  });
}
