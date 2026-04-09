// functions/test/qr/generateQrToken.test.ts
import * as jwt from 'jsonwebtoken';

const TEST_SECRET = 'test-secret-32-chars-minimum-ok!';
const TEST_UID = 'user-uid-123';

// Set environment variable before module load
process.env.QR_SECRET = TEST_SECRET;

// Mock firebase-admin
jest.mock('firebase-admin', () => ({
  firestore: Object.assign(
    jest.fn(() => ({
      collection: jest.fn(() => ({
        doc: jest.fn(() => ({
          update: jest.fn().mockResolvedValue(undefined),
          collection: jest.fn(() => ({
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue({ exists: false }),
            })),
          })),
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

  it('should return uid when token is valid', async () => {
    const validToken = jwt.sign(
      { uid: TEST_UID, issuedAt: Math.floor(Date.now() / 1000) },
      TEST_SECRET,
      { expiresIn: 300 }
    );

    const result = await validateQrTokenHandler({ ...mockRequest, data: { token: validToken } });

    expect(result.uid).toBe(TEST_UID);
    expect(result.valid).toBe(true);
  });

  it('should return invalid for tampered token', async () => {
    const result = await validateQrTokenHandler({ ...mockRequest, data: { token: 'invalid.token.here' } });
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
});
