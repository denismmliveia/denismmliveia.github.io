import { revokeLinkHandler } from './revokeLink';
import * as admin from 'firebase-admin';

jest.mock('firebase-admin', () => {
  const mockGet = jest.fn();
  const mockUpdate = jest.fn().mockResolvedValue(undefined);
  const mockDoc = jest.fn(() => ({ get: mockGet, update: mockUpdate }));
  const mockCollection = jest.fn(() => ({ doc: mockDoc }));
  const mockFirestore = jest.fn(() => ({ collection: mockCollection }));
  (mockFirestore as any).FieldValue = { serverTimestamp: () => 'SERVER_TS' };
  (mockFirestore as any).Timestamp = {
    now: () => ({ toDate: () => new Date() }),
  };
  return {
    firestore: Object.assign(mockFirestore, {
      FieldValue: { serverTimestamp: () => 'SERVER_TS' },
      Timestamp: { now: () => ({ toDate: () => new Date() }) },
    }),
    initializeApp: jest.fn(),
  };
});

jest.mock('../lib/helpers', () => ({
  createMemories: jest.fn().mockResolvedValue(undefined),
  cleanupPhotos: jest.fn().mockResolvedValue(undefined),
}));

function makeRequest(uid: string, data: object) {
  return { auth: { uid }, data } as any;
}

describe('revokeLinkHandler', () => {
  const db = (admin.firestore as any)();

  function setupLinkDoc(exists: boolean, docData?: object) {
    const mockGet = db.collection().doc().get;
    mockGet.mockResolvedValue({ exists, data: () => docData, id: 'link-1' });
  }

  test('throws unauthenticated when no auth', async () => {
    await expect(
      revokeLinkHandler({ auth: null, data: { linkId: 'link-1' } } as any)
    ).rejects.toMatchObject({ code: 'unauthenticated' });
  });

  test('throws not-found when link does not exist', async () => {
    setupLinkDoc(false);
    await expect(
      revokeLinkHandler(makeRequest('uid-a', { linkId: 'link-1' }))
    ).rejects.toMatchObject({ code: 'not-found' });
  });

  test('throws permission-denied when caller is not participant', async () => {
    setupLinkDoc(true, { status: 'linked', userA: 'uid-x', userB: 'uid-y', linkedAt: null });
    await expect(
      revokeLinkHandler(makeRequest('uid-stranger', { linkId: 'link-1' }))
    ).rejects.toMatchObject({ code: 'permission-denied' });
  });

  test('throws failed-precondition when link is not linked', async () => {
    setupLinkDoc(true, { status: 'expired', userA: 'uid-a', userB: 'uid-b', linkedAt: null });
    await expect(
      revokeLinkHandler(makeRequest('uid-a', { linkId: 'link-1' }))
    ).rejects.toMatchObject({ code: 'failed-precondition' });
  });

  test('revokes link and returns ok for valid participant', async () => {
    setupLinkDoc(true, {
      status: 'linked',
      userA: 'uid-a',
      userB: 'uid-b',
      linkedAt: { toDate: () => new Date() },
    });
    const result = await revokeLinkHandler(makeRequest('uid-a', { linkId: 'link-1' }));
    expect(result).toEqual({ ok: true });
  });
});
