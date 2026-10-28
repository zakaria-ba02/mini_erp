import { randomUUID } from 'crypto';
import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';
import mongoose from 'mongoose';

function loadDotEnv() {
  const envPath = resolve(process.cwd(), '.env');
  if (!existsSync(envPath)) {
    return;
  }

  for (const line of readFileSync(envPath, 'utf8').split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) {
      continue;
    }
    const eq = trimmed.indexOf('=');
    if (eq < 1) {
      continue;
    }
    const key = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

loadDotEnv();

const uri =
  process.env.MONGODB_URI ||
  'mongodb://localhost:27017/mini_erp?replicaSet=rs0';

const missingUidFilter = {
  $or: [
    { uid: { $exists: false } },
    { uid: null },
    { uid: '' },
  ],
};

async function nextUniqueUid(users) {
  for (let attempt = 0; attempt < 8; attempt += 1) {
    const uid = randomUUID();
    const clash = await users.findOne({ uid });
    if (!clash) {
      return uid;
    }
  }
  throw new Error('Could not allocate a unique uid');
}

async function main() {
  await mongoose.connect(uri);
  const users = mongoose.connection.db.collection('users');

  const missing = await users.find(missingUidFilter).toArray();
  console.log(`Users missing uid: ${missing.length}`);

  let updated = 0;
  for (const user of missing) {
    const uid = await nextUniqueUid(users);
    const result = await users.updateOne(
      {
        _id: user._id,
        $or: [
          { uid: { $exists: false } },
          { uid: null },
          { uid: '' },
        ],
      },
      { $set: { uid } },
    );
    if (result.modifiedCount === 1) {
      updated += 1;
      console.log(`Set uid for username=${user.username ?? '(unknown)'}`);
    }
  }

  const stillMissing = await users.countDocuments(missingUidFilter);
  console.log(`Updated: ${updated}`);
  console.log(`Still missing uid: ${stillMissing}`);

  await mongoose.disconnect();

  if (stillMissing > 0) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
