import mongoose from 'mongoose';

const uri =
  process.env.MONGODB_URI ||
  'mongodb://localhost:27017/mini_erp?replicaSet=rs0';

async function main() {
  await mongoose.connect(uri);
  const db = mongoose.connection.db;

  const customers = await db.collection('customers').find({}).toArray();
  const invoices = await db.collection('invoices').find({ deletedAt: null }).toArray();
  const payments = await db.collection('payments').find({ deletedAt: null }).toArray();

  console.log('Customers:', customers.length);
  for (const c of customers.slice(-5)) {
    const cid = c._id.toString();
    const invSum = invoices
      .filter((i) => i.customerId?.toString() === cid && !i.deletedAt)
      .reduce((s, i) => s + (i.total || 0), 0);
    const paySum = payments
      .filter((p) => p.customerId?.toString() === cid && !p.deletedAt)
      .reduce((s, p) => s + (p.amount || 0), 0);
    const expected = invSum - paySum;
    const ok = c.balance === expected ? 'OK' : 'MISMATCH';
    console.log(
      `${ok} ${c.name}: balance=${c.balance}, expected=${expected} (inv=${invSum}, pay=${paySum})`,
    );
  }

  await mongoose.disconnect();
}

main().catch(console.error);
