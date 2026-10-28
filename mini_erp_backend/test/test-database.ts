import { readFileSync } from 'fs';
import { join } from 'path';

export function getTestMongoUri(): string {
  return readFileSync(join(__dirname, 'mongo-uri.txt'), 'utf-8').trim();
}

export function setTestEnv(uri: string): void {
  process.env.MONGODB_URI = uri;
  process.env.JWT_ACCESS_SECRET = 'test_access_secret_at_least_32_chars_long';
  process.env.JWT_REFRESH_SECRET =
    'test_refresh_secret_at_least_32_chars_long';
  process.env.ADMIN_SEED_USERNAME = 'test-admin';
  process.env.ADMIN_SEED_PASSWORD = 'test-admin-password';
}
