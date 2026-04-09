// functions/test/qr/generateQrToken.test.ts
import * as jwt from 'jsonwebtoken';

const TEST_SECRET = 'test-secret-32-chars-minimum-ok!';
const TEST_UID = 'user-uid-123';

// Set environment variable before module load
process.env.QR_SECRET = TEST_SECRET;

// Mock firebase-admin with collection-aware routing
jest.mock('firebase-admin', () => {
  // Mutable state to control test behavior
  let activeQrTokenInDb: string | null = null;

  const mockFirestore = jest.fn(() => ({
    collection: jest.fn((col: string) => {
      if (col === 'users') {
        return {
          doc: jest.fn(() => ({
            update: jest.fn().mockResolvedValue(undefined),
            get: jest.fn(async () => ({
              exists: activeQrTokenInDb !== null,
              data: () =>
                activeQrTokenInDb !== null
                  ? { activeQrToken: activeQrTokenInDb }
                  : undefined,
            })),
          })),
        };
      }
      // 'blocks' collection
      return {
        doc: jest.fn(() => ({
          collection: jest.fn(() => ({
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue({ exists: false }),
            })),
          })),
        })),
      };
    }),
  }));

  return {
    firestore: Object.assign(mockFirestore, {
      Timestamp: {
        fromDate: jest.fn((d: Date) => ({ toDate: () => d })),
      },
      FieldValue: { serverTimestamp: jest.fn() },
    }),
    initializeApp: jest.fn(),
    _testHelpers: {
      setActiveQrToken: (token: string | null) => {
        activeQrTokenInDb = token;
      },
    },
  };
});

// Mock firebase-functions/v2/https
jest.mock('firebase-functions/v2/https', () => ({
  onCall: (fn: Function) => fn,
  HttpsError: class HttpsError extends Error {
    code: string;
    constructor(code: string, message: string) {
      super(message);
      this.code = code;
    }
  },
  CallableRequest: jest.fn(),
}));

// Mock firebase-functions/v2
jest.mock('firebase-functions/v2', () => ({
  setGlobalOptions: jest.fn(),
}));

import { generateQrTokenHandler, validateQrTokenHandler } from '../../src/qr/generateQrToken';

describe('generateQrToken', () => {
  const mockRequest = { auth: { uid: TEST_UID } } as any;

  it('should return a signed JWT with uid and issuedAt', async () => {
    const result = await generateQrTokenHandler(mockRequest);

    expect(result).toHaveProperty('token');
    expect(result).toHaveProperty('expiresAt');

    const decoded = jwt.verify(result.token, TEST_SECRET) as any;
    expect(decoded.uid).toBe(TEST_UID);
    expect(decoded.issuedAt).toBeDefined();
  });

  it('should throw unauthenticated error when no auth context', async () => {
    await expect(generateQrTokenHandler({} as any)).rejects.toThrow();
  });

  it('should have token expiry of approximately 5 minutes', async () => {
    const before = Math.floor(Date.now() / 1000);
    const result = await generateQrTokenHandler(mockRequest);
    const decoded = jwt.verify(result.token, TEST_SECRET) as any;

    expect(decoded.exp - decoded.iat).toBe(300); // 5 minutos
    expect(decoded.iat).toBeGreaterThanOrEqual(before);
  });
});

describe('validateQrToken', () => {
  const mockRequest = { auth: { uid: 'scanner-uid' } } as any;

  beforeEach(() => {
    // Reset DB state before each test
    const admin = require('firebase-admin');
    admin._testHelpers.setActiveQrToken(null);
  });

  it('should return uid when token is valid and matches DB', async () => {
    const validToken = jwt.sign(
      { uid: TEST_UID, issuedAt: Math.floor(Date.now() / 1000) },
      TEST_SECRET,
      { expiresIn: 300 }
    );

    // Set the DB to have this exact token
    const admin = require('firebase-admin');
    admin._testHelpers.setActiveQrToken(validToken);

    const result = await validateQrTokenHandler({ ...mockRequest, data: { token: validToken } });

    expect(result.uid).toBe(TEST_UID);
    expect(result.valid).toBe(true);
  });

  it('should return invalid for tampered token', async () => {
    const result = await validateQrTokenHandler({
      ...mockRequest,
      data: { token: 'invalid.token.here' },
    });
    expect(result.valid).toBe(false);
  });

  it('should return invalid when scanner is the same as token owner', async () => {
    const selfToken = jwt.sign(
      { uid: 'scanner-uid', issuedAt: Math.floor(Date.now() / 1000) },
      TEST_SECRET,
      { expiresIn: 300 }
    );

    const result = await validateQrTokenHandler({ ...mockRequest, data: { token: selfToken } });
    expect(result.valid).toBe(false);
  });

  it('should return invalid when token does not match activeQrToken in DB', async () => {
    const staleToken = jwt.sign(
      { uid: TEST_UID, issuedAt: Math.floor(Date.now() / 1000) },
      TEST_SECRET,
      { expiresIn: 300 }
    );

    // DB has a DIFFERENT token (user generated a new one)
    const admin = require('firebase-admin');
    admin._testHelpers.setActiveQrToken('different-token-in-db');

    const result = await validateQrTokenHandler({ ...mockRequest, data: { token: staleToken } });
    expect(result.valid).toBe(false);
  });

  it('should return invalid when user document does not exist', async () => {
    const validToken = jwt.sign(
      { uid: TEST_UID, issuedAt: Math.floor(Date.now() / 1000) },
      TEST_SECRET,
      { expiresIn: 300 }
    );

    // activeQrTokenInDb === null means user doc won't exist
    const admin = require('firebase-admin');
    admin._testHelpers.setActiveQrToken(null);

    const result = await validateQrTokenHandler({ ...mockRequest, data: { token: validToken } });
    expect(result.valid).toBe(false);
  });
});
