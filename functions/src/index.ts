// functions/src/index.ts
import * as admin from 'firebase-admin';

admin.initializeApp();

// QR
export { generateQrToken, validateQrToken } from './qr/generateQrToken';

// Link
export { initiateLink } from './link/initiateLink';
export { confirmLink } from './link/confirmLink';
export { expireLinks } from './link/expireLinks';
export { revokeLink } from './link/revokeLink';

// Chat
export { requestPhotoUploadUrl } from './chat/requestPhotoUploadUrl';
export { getPhotoViewUrl } from './chat/getPhotoViewUrl';

// Moderation
export { blockUser } from './moderation/blockUser';
export { reportUser } from './moderation/reportUser';
