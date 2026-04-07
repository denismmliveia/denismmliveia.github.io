// functions/src/index.ts
import * as admin from 'firebase-admin';

admin.initializeApp();

// QR
export { generateQrToken, validateQrToken } from './qr/generateQrToken';
