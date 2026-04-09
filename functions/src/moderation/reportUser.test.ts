import { reportUserHandler } from './reportUser';

jest.mock('firebase-functions/v2', () => ({ setGlobalOptions: jest.fn() }));
jest.mock('firebase-functions/v2/https', () => ({
  HttpsError: class HttpsError extends Error {
    constructor(public code: string, message: string) { super(message); }
  },
  onCall: jest.fn((handler) => handler),
}));

jest.mock('firebase-admin', () => {
  const mockAdd = jest.fn().mockResolvedValue({ id: 'report-1' });
  const mockSet = jest.fn().mockResolvedValue(undefined);
  const mockGet = jest.fn();
  const mockUpdate = jest.fn().mockResolvedValue(undefined);
  // Inner doc (for subcollection)
  const mockInnerDoc = jest.fn(() => ({ set: mockSet, get: mockGet, update: mockUpdate }));
  // Inner collection (for .collection('blocked'))
  const mockInnerCol = jest.fn(() => ({ doc: mockInnerDoc, add: mockAdd }));
  // Outer doc — supports both .set() and .collection()
  const mockOuterDoc = jest.fn(() => ({
    set: mockSet,
    get: mockGet,
    update: mockUpdate,
    collection: mockInnerCol,
  }));
  const mockColFn = jest.fn(() => ({ doc: mockOuterDoc, add: mockAdd }));
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

describe('reportUserHandler', () => {
  test('throws unauthenticated when no auth', async () => {
    await expect(
      reportUserHandler({ auth: null, data: { targetUid: 'uid-b', reason: 'spam' } } as any)
    ).rejects.toMatchObject({ code: 'unauthenticated' });
  });

  test('throws invalid-argument for missing reason', async () => {
    await expect(
      reportUserHandler(makeRequest('uid-a', { targetUid: 'uid-b', reason: '' }))
    ).rejects.toMatchObject({ code: 'invalid-argument' });
  });

  test('creates report + block and returns ok', async () => {
    const result = await reportUserHandler(
      makeRequest('uid-a', { targetUid: 'uid-b', reason: 'spam', linkId: 'link-1' })
    );
    expect(result).toEqual({ ok: true });
  });
});
