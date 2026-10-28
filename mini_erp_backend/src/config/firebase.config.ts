import { registerAs } from '@nestjs/config';

function stripEnvQuotes(value: string): string {
  const trimmed = value.trim();
  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
    (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
}

export function normalizeFirebasePrivateKey(raw: string): string {
  let key = stripEnvQuotes(raw);
  if (key.includes('\\n')) {
    key = key.replace(/\\n/g, '\n');
  }
  return key.replace(/\r\n/g, '\n').trim();
}

export default registerAs('firebase', () => ({
  projectId: stripEnvQuotes(process.env.FIREBASE_PROJECT_ID ?? '').replace(
    /"/g,
    '',
  ),
  clientEmail: stripEnvQuotes(process.env.FIREBASE_CLIENT_EMAIL ?? '').replace(
    /"/g,
    '',
  ),
  privateKey: normalizeFirebasePrivateKey(process.env.FIREBASE_PRIVATE_KEY ?? ''),
}));