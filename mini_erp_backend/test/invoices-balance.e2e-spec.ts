import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { getTestMongoUri, setTestEnv } from './test-database';
import { createTestApp } from './create-test-app';

describe('Invoices balance (e2e)', () => {
  let app: INestApplication;
  let adminToken: string;
  let customerId: string;

  beforeAll(async () => {
    setTestEnv(getTestMongoUri());
    app = await createTestApp();

    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ username: 'test-admin', password: 'test-admin-password' });
    adminToken = login.body.accessToken;

    const customer = await request(app.getHttpServer())
      .post('/customers')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        name: 'Test Customer',
        phone: '0500000000',
        account: { username: 'customer1', password: 'customer123' },
      });
    customerId = customer.body.customer._id;
  });

  afterAll(async () => {
    if (app) await app.close();
  });

  it('creates invoice and updates customer balance', async () => {
    await request(app.getHttpServer())
      .post('/invoices')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        customerId,
        date: new Date().toISOString(),
        currency: 'SYP',
        items: [{ name: 'Manual item', quantity: 2, unitPrice: 50 }],
      })
      .expect(201);

    const customer = await request(app.getHttpServer())
      .get(`/customers/${customerId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    expect(customer.body.balances.SYP).toBe(100);
    expect(customer.body.balances.USD).toBe(0);
  });

  it('creates payment and reduces customer balance', async () => {
    await request(app.getHttpServer())
      .post('/payments')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        customerId,
        amount: 40,
        date: new Date().toISOString(),
        method: 'cash',
        currency: 'SYP',
      })
      .expect(201);

    const customer = await request(app.getHttpServer())
      .get(`/customers/${customerId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    expect(customer.body.balances.SYP).toBe(60);
    expect(customer.body.balances.USD).toBe(0);
  });

  it('rejects customer access to another customer invoices', async () => {
    const customerLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ username: 'customer1', password: 'customer123' })
      .expect(201);

    const otherCustomer = await request(app.getHttpServer())
      .post('/customers')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        name: 'Other Customer',
        phone: '0500000001',
        account: { username: 'customer2', password: 'customer123' },
      });

    const invoice = await request(app.getHttpServer())
      .post('/invoices')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        customerId: otherCustomer.body.customer._id,
        date: new Date().toISOString(),
        items: [{ name: 'Other item', quantity: 1, unitPrice: 10 }],
        currency: 'SYP',
      });

    await request(app.getHttpServer())
      .get(`/invoices/${invoice.body._id}`)
      .set('Authorization', `Bearer ${customerLogin.body.accessToken}`)
      .expect(403);
  });

  it('keeps SYP and USD balances independent and settles one currency only', async () => {
    const created = await request(app.getHttpServer())
      .post('/customers')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        name: 'Dual Currency Customer',
        phone: '0500000002',
        account: { username: 'dualcurrency1', password: 'customer123' },
      })
      .expect(201);
    const id = created.body.customer._id;

    await request(app.getHttpServer())
      .post('/invoices')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        customerId: id,
        date: new Date().toISOString(),
        currency: 'SYP',
        items: [{ name: 'SYP item', quantity: 1, unitPrice: 100 }],
      })
      .expect(201);

    await request(app.getHttpServer())
      .post('/invoices')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        customerId: id,
        date: new Date().toISOString(),
        currency: 'USD',
        items: [{ name: 'USD item', quantity: 1, unitPrice: 20 }],
      })
      .expect(201);

    await request(app.getHttpServer())
      .post('/payments')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        customerId: id,
        amount: 40,
        date: new Date().toISOString(),
        method: 'cash',
        currency: 'SYP',
      })
      .expect(201);

    const before = await request(app.getHttpServer())
      .get(`/customers/${id}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(before.body.balances.SYP).toBe(60);
    expect(before.body.balances.USD).toBe(20);

    const settle = await request(app.getHttpServer())
      .post(`/customers/${id}/settle`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ currency: 'SYP' })
      .expect(201);
    expect(settle.body.currency).toBe('SYP');
    expect(settle.body.balanceAtSettlement).toBe(60);

    const after = await request(app.getHttpServer())
      .get(`/customers/${id}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(after.body.balances.SYP).toBe(0);
    expect(after.body.balances.USD).toBe(20);
  });
});
