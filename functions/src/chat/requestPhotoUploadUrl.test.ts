import { describe, it, expect, jest, beforeEach } from '@jest/globals';

// Mock firebase-admin before importing the function
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockLinkGet: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockLinkDoc: jest.Mock<any> = jest.fn().mockReturnValue({ get: mockLinkGet });
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockLinksCollection: jest.Mock<any> = jest.fn().mockReturnValue({ doc: mockLinkDoc });
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockGetSignedUrl: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockBucketFile: jest.Mock<any> = jest.fn().mockReturnValue({ getSignedUrl: mockGetSignedUrl });
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockBucket: jest.Mock<any> = jest.fn().mockReturnValue({ file: mockBucketFile });

jest.mock('firebase-admin', () => ({
  firestore: () => ({ collection: mockLinksCollection }),
  storage: () => ({ bucket: mockBucket }),
  initializeApp: jest.fn(),
  apps: ['app'],
}));

jest.mock('firebase-functions/v2/https', () => ({
  onCall: (fn: Function) => { const wrapped = fn; (wrapped as any).__handler = fn; return wrapped; },
  HttpsError: class HttpsError extends Error {
    code: string;
    constructor(code: string, message: string) { super(code); this.code = code; }
  },
}));

jest.mock('firebase-functions/v2', () => ({ setGlobalOptions: jest.fn() }));

// Must import after mock
import { requestPhotoUploadUrl } from './requestPhotoUploadUrl';

const activeLink = { userA: 'uid-alice', userB: 'uid-bob', status: 'linked' };

describe('requestPhotoUploadUrl', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockLinkGet.mockResolvedValue({ exists: true, data: () => activeLink });
    mockGetSignedUrl.mockResolvedValue(['https://storage.example.com/upload?sig=abc']);
  });

  it('throws unauthenticated if no auth', async () => {
    const fn = (requestPhotoUploadUrl as any).__handler;
    await expect(fn({ auth: null, data: { linkId: 'link-1', msgId: 'msg-1' } }))
      .rejects.toThrow('unauthenticated');
  });

  it('throws permission-denied if caller is not participant', async () => {
    mockLinkGet.mockResolvedValue({ exists: true, data: () => ({ userA: 'uid-x', userB: 'uid-y', status: 'linked' }) });
    const fn = (requestPhotoUploadUrl as any).__handler;
    await expect(fn({ auth: { uid: 'uid-alice' }, data: { linkId: 'link-1', msgId: 'msg-1' } }))
      .rejects.toThrow('permission-denied');
  });

  it('throws failed-precondition if link is not linked', async () => {
    mockLinkGet.mockResolvedValue({ exists: true, data: () => ({ ...activeLink, status: 'pending' }) });
    const fn = (requestPhotoUploadUrl as any).__handler;
    await expect(fn({ auth: { uid: 'uid-alice' }, data: { linkId: 'link-1', msgId: 'msg-1' } }))
      .rejects.toThrow('failed-precondition');
  });

  it('returns uploadUrl and photoRef for valid participant', async () => {
    const fn = (requestPhotoUploadUrl as any).__handler;
    const result = await fn({ auth: { uid: 'uid-alice' }, data: { linkId: 'link-1', msgId: 'msg-1' } });

    expect(result.uploadUrl).toBe('https://storage.example.com/upload?sig=abc');
    expect(result.photoRef).toMatch(/^chat\/link-1\/msg-1\/uid-alice_\d+\.jpg$/);
    expect(mockGetSignedUrl).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'write', contentType: 'image/jpeg' })
    );
  });
});
