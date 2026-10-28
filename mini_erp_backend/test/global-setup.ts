import { MongoMemoryReplSet } from 'mongodb-memory-server';
import { writeFileSync } from 'fs';
import { join } from 'path';

export default async function globalSetup(): Promise<void> {
  process.env.MONGOMS_VERSION = '7.0.14';

  const mongoReplSet = await MongoMemoryReplSet.create({
    replSet: { count: 1, storageEngine: 'wiredTiger' },
  });

  const uri = mongoReplSet.getUri();
  writeFileSync(join(__dirname, 'mongo-uri.txt'), uri);

  process.env.MONGODB_URI = uri;
  process.env.JWT_ACCESS_SECRET = 'test_access_secret_at_least_32_chars_long';
  process.env.JWT_REFRESH_SECRET =
    'test_refresh_secret_at_least_32_chars_long';
  process.env.ADMIN_SEED_USERNAME = 'test-admin';
  process.env.ADMIN_SEED_PASSWORD = 'test-admin-password';

  (globalThis as { __MONGO_REPLSET__: MongoMemoryReplSet }).__MONGO_REPLSET__ =
    mongoReplSet;
}
