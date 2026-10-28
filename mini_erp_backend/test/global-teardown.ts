import type { MongoMemoryReplSet } from 'mongodb-memory-server';

export default async function globalTeardown(): Promise<void> {
  const mongoReplSet = (globalThis as { __MONGO_REPLSET__?: MongoMemoryReplSet })
    .__MONGO_REPLSET__;

  if (mongoReplSet) {
    await mongoReplSet.stop();
  }
}
