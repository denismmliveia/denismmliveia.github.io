import 'package:flutter_test/flutter_test.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';

void main() {
  const link = LinkEntity(
    linkId: 'link-1',
    userA: 'user-a',
    userB: 'user-b',
    status: 'pending',
    initiatedBy: 'user-a',
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

  test('isExpired is true when status is expired', () {
    const expiredLink = LinkEntity(
      linkId: 'link-2',
      userA: 'user-a',
      userB: 'user-b',
      status: 'expired',
      initiatedBy: 'user-a',
    );
    expect(expiredLink.isExpired, isTrue);
    expect(expiredLink.isRevoked, isFalse);
  });

  test('isRevoked is true when status is revoked', () {
    const revokedLink = LinkEntity(
      linkId: 'link-3',
      userA: 'user-a',
      userB: 'user-b',
      status: 'revoked',
      initiatedBy: 'user-a',
    );
    expect(revokedLink.isRevoked, isTrue);
    expect(revokedLink.isExpired, isFalse);
  });
}
