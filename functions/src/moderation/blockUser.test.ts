import { blockUserHandler } from './blockUser';

jest.mock('firebase-functions/v2', () => ({ setGlobalOptions: jest.fn() }));
jest.mock('firebase-functions/v2/https', () => ({
  HttpsError: class HttpsError extends Error {
    constructor(public code: string, message: string) { super(message); }
  },
  onCall: jest.fn((handler) => handler),
}));

jest.mock('firebase-admin', () => {
  const mockSet = jest.fn().mockResolvedValue(undefined);
  const mockGet = jest.fn();
  const mockUpdate = jest.fn().mockResolvedValue(undefined);
  // Inner doc (for subcollection)
  const mockInnerDoc = jest.fn(() => ({ set: mockSet, get: mockGet, update: mockUpdate }));
  // Inner collection (for .collection('blocked'))
  const mockInnerCol = jest.fn(() => ({ doc: mockInnerDoc }));
  // Outer doc (for .doc(callerUid)) — supports both .set() and .collection()
  const mockOuterDoc = jest.fn(() => ({
    set: mockSet,
    get: mockGet,
    update: mockUpdate,
    collection: mockInnerCol,
  }));
  const mockColFn = jest.fn(() => ({ doc: mockOuterDoc }));
  const mockFirestore = jest.fn(() => ({ collection: mockColFn }));
  (mockFirestore as any).FieldValue = { serverTimestamp: () => 'SERVER_TS' };
  (mockFirestore as any).Timestamp = { now: () => ({ toDate: () => new Date() }) };
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

describe('blockUserHandler', () => {
  test('throws unauthenticated when no auth', async () => {
    await expect(
      blockUserHandler({ auth: null, data: { targetUid: 'uid-b' } } as any)
    ).rejects.toMatchObject({ code: 'unauthenticated' });
  });

  test('throws invalid-argument when blocking self', async () => {
    await expect(
      blockUserHandler(makeRequest('uid-a', { targetUid: 'uid-a' }))
    ).rejects.toMatchObject({ code: 'invalid-argument' });
  });

  test('creates block doc and returns ok', async () => {
    const result = await blockUserHandler(makeRequest('uid-a', { targetUid: 'uid-b' }));
    expect(result).toEqual({ ok: true });
  });
});
