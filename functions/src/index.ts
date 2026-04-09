// functions/src/index.ts
import * as admin from 'firebase-admin';

admin.initializeApp();

// QR
export { generateQrToken, validateQrToken } from './qr/generateQrToken';

// Link
export { initiateLink } from './link/initiateLink';
// export { confirmLink } from './link/confirmLink'; // will exist after Task 9
