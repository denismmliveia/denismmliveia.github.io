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
  const mockInnerDoc = jest.fn(() => ({ set: mockSet, get: mockGet, update: mockUpdate }));
  const mockInnerCol = jest.fn(() => ({ doc: mockInnerDoc, add: mockAdd }));
  const mockOuterDoc = jest.fn(() => ({
    set: mockSet,
    get: mockGet,
    update: mockUpdate,
    collection: mockInnerCol,
  }));

  let reportQueryCount = 0;

  const mockColFn = jest.fn((col: string) => {
    if (col === 'reports') {
      return {
        doc: mockOuterDoc,
        add: mockAdd,
        where: jest.fn().mockReturnValue({
          where: jest.fn().mockReturnValue({
            get: jest.fn(async () => ({
              docs: Array.from({ length: reportQueryCount }, (_, i) => ({ id: `r-${i}` })),
            })),
          }),
        }),
      };
    }
    return { doc: mockOuterDoc, add: mockAdd };
  });

  const mockFirestore = jest.fn(() => ({ collection: mockColFn }));
  (mockFirestore as any).FieldValue = { serverTimestamp: () => 'SERVER_TS' };
  (mockFirestore as any).Timestamp = {
    now: () => ({ toDate: () => new Date() }),
    fromDate: (d: Date) => ({ toDate: () => d }),
  };

  return {
    firestore: Object.assign(mockFirestore, {
      FieldValue: { serverTimestamp: () => 'SERVER_TS' },
      Timestamp: {
        now: () => ({ toDate: () => new Date() }),
        fromDate: (d: Date) => ({ toDate: () => d }),
      },
    }),
    initializeApp: jest.fn(),
    _testHelpers: {
      setReportQueryCount: (n: number) => { reportQueryCount = n; },
    },
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

  test('throws resource-exhausted when report rate limit exceeded (5/hour)', async () => {
    const admin = require('firebase-admin');
    admin._testHelpers.setReportQueryCount(5);

    await expect(
      reportUserHandler(makeRequest('uid-a', { targetUid: 'uid-b', reason: 'spam' }))
    ).rejects.toMatchObject({ code: 'resource-exhausted' });

    // Reset for other tests
    admin._testHelpers.setReportQueryCount(0);
  });
});
