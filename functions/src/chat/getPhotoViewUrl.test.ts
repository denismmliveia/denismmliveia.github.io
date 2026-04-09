import { describe, it, expect, jest, beforeEach } from '@jest/globals';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockMsgUpdate: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockMsgGet: jest.Mock<any> = jest.fn();
// Transaction-level get and update mocks
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockTxGet: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockTxUpdate: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockRunTransaction: jest.Mock<any> = jest.fn();
const mockMsgRef = { get: mockMsgGet, update: mockMsgUpdate };
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockMsgsCollection: jest.Mock<any> = jest.fn().mockReturnValue({ doc: jest.fn().mockReturnValue(mockMsgRef) });
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockLinkGet: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockLinkDoc: jest.Mock<any> = jest.fn().mockReturnValue({ get: mockLinkGet, collection: mockMsgsCollection });
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockLinksCollection: jest.Mock<any> = jest.fn().mockReturnValue({ doc: mockLinkDoc });
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockFileDelete: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockGetSignedUrl: jest.Mock<any> = jest.fn();
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockBucketFile: jest.Mock<any> = jest.fn().mockReturnValue({ getSignedUrl: mockGetSignedUrl, delete: mockFileDelete });
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mockBucket: jest.Mock<any> = jest.fn().mockReturnValue({ file: mockBucketFile });
const mockArrayUnion = jest.fn((v: string) => ({ _type: 'arrayUnion', value: v }));

jest.mock('firebase-admin', () => ({
  firestore: Object.assign(
    () => ({ collection: mockLinksCollection, runTransaction: mockRunTransaction }),
    {
      FieldValue: { arrayUnion: mockArrayUnion },
    }
  ),
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

import { getPhotoViewUrl } from './getPhotoViewUrl';

const activeLink = { userA: 'uid-alice', userB: 'uid-bob', status: 'linked' };
const photoMsg = {
  type: 'photo_once',
  photoRef: 'chat/link-1/msg-1/uid-bob_123.jpg',
  viewedBy: [],
  deletedFromStorage: false,
};

describe('getPhotoViewUrl', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockLinkGet.mockResolvedValue({ exists: true, data: () => activeLink });
    mockMsgGet.mockResolvedValue({ exists: true, data: () => ({ ...photoMsg }) });
    mockGetSignedUrl.mockResolvedValue(['https://storage.example.com/view?sig=xyz']);
    mockMsgUpdate.mockResolvedValue(undefined);
    mockTxGet.mockResolvedValue({ data: () => ({ ...photoMsg }) });
    mockTxUpdate.mockReturnValue(undefined);
    // Default runTransaction: executes the callback with a mock transaction object
    mockRunTransaction.mockImplementation(async (fn: Function) => {
      await fn({ get: mockTxGet, update: mockTxUpdate });
    });
    // Re-wire mocks cleared by clearAllMocks
    mockMsgsCollection.mockReturnValue({ doc: jest.fn().mockReturnValue(mockMsgRef) });
    mockLinkDoc.mockReturnValue({ get: mockLinkGet, collection: mockMsgsCollection });
    mockLinksCollection.mockReturnValue({ doc: mockLinkDoc });
    mockBucketFile.mockReturnValue({ getSignedUrl: mockGetSignedUrl, delete: mockFileDelete });
    mockBucket.mockReturnValue({ file: mockBucketFile });
    mockFileDelete.mockResolvedValue(undefined);
  });

  it('throws unauthenticated if no auth', async () => {
    const fn = (getPhotoViewUrl as any).__handler;
    await expect(fn({ auth: null, data: { linkId: 'link-1', msgId: 'msg-1' } }))
      .rejects.toThrow('unauthenticated');
  });

  it('throws already-exists if uid already in viewedBy', async () => {
    mockMsgGet.mockResolvedValue({ exists: true, data: () => ({ ...photoMsg, viewedBy: ['uid-alice'] }) });
    const fn = (getPhotoViewUrl as any).__handler;
    await expect(fn({ auth: { uid: 'uid-alice' }, data: { linkId: 'link-1', msgId: 'msg-1' } }))
      .rejects.toThrow('already-exists');
  });

  it('throws not-found if deletedFromStorage is true', async () => {
    mockMsgGet.mockResolvedValue({ exists: true, data: () => ({ ...photoMsg, deletedFromStorage: true }) });
    const fn = (getPhotoViewUrl as any).__handler;
    await expect(fn({ auth: { uid: 'uid-alice' }, data: { linkId: 'link-1', msgId: 'msg-1' } }))
      .rejects.toThrow('not-found');
  });

  it('returns viewUrl and adds uid to viewedBy', async () => {
    const fn = (getPhotoViewUrl as any).__handler;
    const result = await fn({ auth: { uid: 'uid-alice' }, data: { linkId: 'link-1', msgId: 'msg-1' } });

    expect(result.viewUrl).toBe('https://storage.example.com/view?sig=xyz');
    expect(mockTxUpdate).toHaveBeenCalledWith(
      mockMsgRef,
      expect.objectContaining({ viewedBy: expect.anything() })
    );
    expect(mockGetSignedUrl).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'read' })
    );
  });

  it('deletes from Storage and marks deletedFromStorage when both users have viewed', async () => {
    // uid-bob has already viewed; uid-alice views now → both viewed
    // The initial msgDoc read (outside transaction) must show viewedBy: ['uid-bob']
    mockMsgGet.mockResolvedValue({ exists: true, data: () => ({ ...photoMsg, viewedBy: ['uid-bob'] }) });
    // The fresh read inside the transaction must also show viewedBy: ['uid-bob']
    mockTxGet.mockResolvedValue({ data: () => ({ ...photoMsg, viewedBy: ['uid-bob'] }) });
    const fn = (getPhotoViewUrl as any).__handler;
    await fn({ auth: { uid: 'uid-alice' }, data: { linkId: 'link-1', msgId: 'msg-1' } });

    expect(mockFileDelete).toHaveBeenCalled();
    expect(mockTxUpdate).toHaveBeenCalledWith(
      mockMsgRef,
      expect.objectContaining({ deletedFromStorage: true })
    );
  });
});
