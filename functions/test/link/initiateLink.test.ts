import * as jwt from 'jsonwebtoken';

const TEST_SECRET = 'test-secret-32-chars-minimum-ok!';
const SCANNER_UID = 'scanner-uid';
const TARGET_UID = 'target-uid';

process.env.QR_SECRET = TEST_SECRET;

// Build a valid JWT for the target user
function makeToken(uid: string, ageSeconds = 0): string {
  return jwt.sign(
    { uid, issuedAt: Math.floor(Date.now() / 1000) - ageSeconds },
    TEST_SECRET,
    { expiresIn: 300 }
  );
}

// ---- Firestore mock state ----
let mockLinkDocs: any[] = [];
let lastCreatedLink: any = null;

const mockFirestore = {
  collection: jest.fn((col: string) => ({
    where: jest.fn().mockReturnThis(),
    get: jest.fn(async () => ({ docs: mockLinkDocs })),
    add: jest.fn(async (data: any) => {
      lastCreatedLink = data;
      return { id: 'new-link-id' };
    }),
    doc: jest.fn((_id: string) => ({
      get: jest.fn(async () => ({ exists: false })), // blocks check
      update: jest.fn(async (_data: any) => { /* no-op */ }),
    })),
  })),
};

// User doc for target
const mockUserDoc = {
  data: () => ({
    displayName: 'DJ GHOST',
    photoUrl: 'https://example.com/photo.jpg',
    genre: 'Techno',
    orientation: 'Bisexual',
    relationshipStatus: 'Free',
    favoriteTheme: 'Industrial',
  }),
  exists: true,
};

jest.mock('firebase-admin', () => ({
  firestore: Object.assign(
    jest.fn(() => mockFirestore),
    {
      Timestamp: {
        fromDate: jest.fn((d: Date) => ({ toDate: () => d, seconds: Math.floor(d.getTime() / 1000) })),
        now: jest.fn(() => ({ toDate: () => new Date(), seconds: Math.floor(Date.now() / 1000) })),
      },
      FieldValue: { serverTimestamp: jest.fn() },
    }
  ),
  initializeApp: jest.fn(),
}));

jest.mock('firebase-functions/v2/https', () => ({
  onCall: (fn: Function) => fn,
  HttpsError: class HttpsError extends Error {
    code: string;
    constructor(code: string, message: string) { super(message); this.code = code; }
  },
}));

jest.mock('firebase-functions/v2', () => ({ setGlobalOptions: jest.fn() }));

import { initiateLinkHandler } from '../../src/link/initiateLink';

// Helper to build a subcollection-capable doc mock
function makeDocMock(existsValue = false) {
  return {
    get: jest.fn(async () => ({ exists: existsValue })),
    update: jest.fn(async (_data: any) => { /* no-op */ }),
    collection: jest.fn((_subCol: string) => ({
      doc: jest.fn((_subId: string) => ({
        get: jest.fn(async () => ({ exists: false })),
        update: jest.fn(async (_data: any) => { /* no-op */ }),
      })),
    })),
  };
}

// Helper to build a full collection mock
function makeCollectionMock() {
  return {
    where: jest.fn().mockReturnThis(),
    get: jest.fn(async () => ({ docs: mockLinkDocs })),
    add: jest.fn(async (data: any) => {
      lastCreatedLink = data;
      return { id: 'new-link-id' };
    }),
    doc: jest.fn((_id: string) => makeDocMock(false)),
  };
}

describe('initiateLink', () => {
  beforeEach(() => {
    mockLinkDocs = [];
    lastCreatedLink = null;
    // Reset the user doc mock
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    mockFirestore.collection.mockImplementation((col: string): any => {
      if (col === 'users') {
        return {
          ...makeCollectionMock(),
          doc: jest.fn(() => ({
            get: jest.fn(async () => mockUserDoc),
            update: jest.fn(async (_data: any) => { /* no-op */ }),
            collection: jest.fn((_subCol: string) => ({
              doc: jest.fn((_subId: string) => ({
                get: jest.fn(async () => ({ exists: false })),
              })),
            })),
          })),
        };
      }
      return makeCollectionMock();
    });
  });

  it('throws unauthenticated when no auth', async () => {
    await expect(initiateLinkHandler({} as any)).rejects.toThrow();
  });

  it('throws invalid-argument when token is invalid', async () => {
    const req = { auth: { uid: SCANNER_UID }, data: { token: 'bad.token.here' } } as any;
    await expect(initiateLinkHandler(req)).rejects.toThrow();
  });

  it('throws invalid-argument when scanner scans own QR', async () => {
    const selfToken = makeToken(SCANNER_UID);
    const req = { auth: { uid: SCANNER_UID }, data: { token: selfToken } } as any;
    await expect(initiateLinkHandler(req)).rejects.toThrow();
  });

  it('creates a new PENDING link when no existing link', async () => {
    const token = makeToken(TARGET_UID);
    const req = { auth: { uid: SCANNER_UID }, data: { token } } as any;

    const result = await initiateLinkHandler(req);

    expect(result.status).toBe('pending');
    expect(result.isMutual).toBe(false);
    expect(result.linkId).toBe('new-link-id');
    expect(lastCreatedLink.status).toBe('pending');
    expect(lastCreatedLink.initiatedBy).toBe(SCANNER_UID);
    expect(lastCreatedLink.userA).toBe(SCANNER_UID);
    expect(lastCreatedLink.userB).toBe(TARGET_UID);
  });

  it('detects mutual scan and returns isMutual: true', async () => {
    // Existing PENDING where TARGET scanned SCANNER first
    const futureDate = new Date(Date.now() + 50000); // still within window
    mockLinkDocs = [{
      id: 'existing-link',
      data: () => ({
        userA: TARGET_UID,
        userB: SCANNER_UID,
        status: 'pending',
        initiatedBy: TARGET_UID,
        pendingExpiresAt: { toDate: () => futureDate },
      }),
      ref: { update: jest.fn() },
    }];

    const token = makeToken(TARGET_UID);
    const req = { auth: { uid: SCANNER_UID }, data: { token } } as any;

    const result = await initiateLinkHandler(req);

    expect(result.status).toBe('linked');
    expect(result.isMutual).toBe(true);
    expect(result.linkId).toBe('existing-link');
  });

  it('creates new PENDING when existing PENDING is expired', async () => {
    const pastDate = new Date(Date.now() - 10000); // expired
    mockLinkDocs = [{
      id: 'old-link',
      data: () => ({
        userA: TARGET_UID,
        userB: SCANNER_UID,
        status: 'pending',
        initiatedBy: TARGET_UID,
        pendingExpiresAt: { toDate: () => pastDate },
      }),
      ref: { update: jest.fn() },
    }];

    const token = makeToken(TARGET_UID);
    const req = { auth: { uid: SCANNER_UID }, data: { token } } as any;

    const result = await initiateLinkHandler(req);

    expect(result.status).toBe('pending');
    expect(result.isMutual).toBe(false);
    expect(result.linkId).toBe('new-link-id');
  });
});
