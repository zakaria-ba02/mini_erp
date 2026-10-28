async function main() {
  const base = 'http://localhost:3000';
  const login = await fetch(`${base}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username: 'Admin999', password: '0945175182' }),
  }).then((r) => r.json());

  if (!login.accessToken) {
    throw new Error(`Login failed: ${JSON.stringify(login)}`);
  }

  const headers = {
    Authorization: `Bearer ${login.accessToken}`,
    'Content-Type': 'application/json',
  };

  const suffix = Date.now();
  const customerRes = await fetch(`${base}/customers`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      name: `BalanceTest-${suffix}`,
      phone: `05${suffix}`.slice(0, 10),
      account: { username: `bal${suffix}`, password: 'test123456' },
    }),
  }).then((r) => r.json());

  const customerId = customerRes.customer._id;
  console.log('1) Customer created — balance:', customerRes.customer.balance);

  const invoiceRes = await fetch(`${base}/invoices`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      customerId,
      date: new Date().toISOString(),
      items: [{ name: 'Test item', quantity: 1, unitPrice: 125 }],
    }),
  }).then((r) => r.json());

  console.log('2) Invoice created — total:', invoiceRes.total);

  const invoicesList = await fetch(
    `${base}/invoices?customerId=${customerId}&limit=100`,
    { headers: { Authorization: headers.Authorization } },
  ).then((r) => r.json());

  const customerAfter = await fetch(`${base}/customers/${customerId}`, {
    headers: { Authorization: headers.Authorization },
  }).then((r) => r.json());

  console.log('3) Invoice count for customer:', invoicesList.data.length);
  console.log('4) Customer balance:', customerAfter.balance);

  const ok =
    customerRes.customer.balance === 0 &&
    invoicesList.data.length === 1 &&
    customerAfter.balance === invoiceRes.total;

  if (ok) {
    console.log('PASS — balance matches invoice total (no doubling)');
  } else {
    console.error('FAIL — expected balance', invoiceRes.total, 'got', customerAfter.balance);
    process.exitCode = 1;
  }

  // Payment flow: balance should decrease by payment amount
  const paymentRes = await fetch(`${base}/payments`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      customerId,
      amount: 25,
      date: new Date().toISOString(),
      method: 'cash',
    }),
  }).then((r) => r.json());

  const customerAfterPayment = await fetch(`${base}/customers/${customerId}`, {
    headers: { Authorization: headers.Authorization },
  }).then((r) => r.json());

  const expectedAfterPayment = invoiceRes.total - paymentRes.amount;
  console.log('5) After payment — balance:', customerAfterPayment.balance, '(expected:', expectedAfterPayment + ')');

  if (customerAfterPayment.balance !== expectedAfterPayment) {
    console.error('FAIL — payment balance mismatch');
    process.exitCode = 1;
  } else {
    console.log('PASS — payment balance correct');
  }
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
