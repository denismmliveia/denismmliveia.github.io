const SCANNER_UID = 'scanner-uid'; // was initiatedBy
const TARGET_UID = 'target-uid';   // is confirming

process.env.QR_SECRET = 'test-secret-32-chars-minimum-ok!';

let mockLinkData: any = null;
let lastUpdate: any = null;

const makeLinkDoc = (overrides: any = {}) => ({
  exists: true,
  data: () => ({
    userA: SCANNER_UID,
    userB: TARGET_UID,
    status: 'pending',
    initiatedBy: SCANNER_UID,
    pendingExpiresAt: { toDate: () => new Date(Date.now() + 30000) }, // 30s remaining
    ...overrides,
  }),
  ref: {
    update: jest.fn(async (data: any) => { lastUpdate = data; }),
  },
});

jest.mock('firebase-admin', () => ({
  firestore: Object.assign(
    jest.fn(() => ({
      collection: jest.fn(() => ({
        doc: jest.fn(() => ({
          get: jest.fn(async () => mockLinkData),
          update: jest.fn(async (data: any) => { lastUpdate = data; }),
        })),
      })),
    })),
    {
      Timestamp: {
        fromDate: jest.fn((d: Date) => ({ toDate: () => d })),
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

import { confirmLinkHandler } from '../../src/link/confirmLink';

describe('confirmLink', () => {
  beforeEach(() => {
    mockLinkData = makeLinkDoc();
    lastUpdate = null;
  });

  it('throws unauthenticated when no auth', async () => {
    await expect(confirmLinkHandler({} as any)).rejects.toThrow();
  });

  it('throws not-found when link does not exist', async () => {
    mockLinkData = { exists: false };
    const req = {
      auth: { uid: TARGET_UID },
      data: { linkId: 'link-abc', duration: 4 },
    } as any;
    await expect(confirmLinkHandler(req)).rejects.toThrow();
  });

  it('throws failed-precondition when link is not pending', async () => {
    mockLinkData = makeLinkDoc({ status: 'linked' });
    const req = {
      auth: { uid: TARGET_UID },
      data: { linkId: 'link-abc', duration: 4 },
    } as any;
    await expect(confirmLinkHandler(req)).rejects.toThrow();
  });

  it('throws permission-denied when initiator tries to confirm own link', async () => {
    const req = {
      auth: { uid: SCANNER_UID }, // is the initiatedBy
      data: { linkId: 'link-abc', duration: 4 },
    } as any;
    await expect(confirmLinkHandler(req)).rejects.toThrow();
  });

  it('throws deadline-exceeded when pending window has expired', async () => {
    mockLinkData = makeLinkDoc({
      pendingExpiresAt: { toDate: () => new Date(Date.now() - 5000) },
    });
    const req = {
      auth: { uid: TARGET_UID },
      data: { linkId: 'link-abc', duration: 4 },
    } as any;
    await expect(confirmLinkHandler(req)).rejects.toThrow();
  });

  it('throws invalid-argument for unknown duration', async () => {
    const req = {
      auth: { uid: TARGET_UID },
      data: { linkId: 'link-abc', duration: 8 }, // 8 is not valid
    } as any;
    await expect(confirmLinkHandler(req)).rejects.toThrow();
  });

  it('transitions link to LINKED and returns expiresAt', async () => {
    const req = {
      auth: { uid: TARGET_UID },
      data: { linkId: 'link-abc', duration: 4 },
    } as any;

    const result = await confirmLinkHandler(req);

    expect(result).toHaveProperty('expiresAt');
    expect(lastUpdate.status).toBe('linked');
    expect(lastUpdate.duration).toBe(4);
  });

  it('accepts duration 12, 24, 72', async () => {
    for (const dur of [12, 24, 72]) {
      lastUpdate = null;
      mockLinkData = makeLinkDoc();
      const req = {
        auth: { uid: TARGET_UID },
        data: { linkId: 'link-abc', duration: dur },
      } as any;
      await confirmLinkHandler(req);
      expect(lastUpdate.status).toBe('linked');
      expect(lastUpdate.duration).toBe(dur);
    }
  });
});
