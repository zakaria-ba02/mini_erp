import { INestApplication } from '@nestjs/common';
import { getConnectionToken } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { Connection } from 'mongoose';
import request from 'supertest';
import { getTestMongoUri, setTestEnv } from './test-database';
import { createTestApp } from './create-test-app';

describe('Auth (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    setTestEnv(getTestMongoUri());
    app = await createTestApp();
  });

  afterAll(async () => {
    if (app) await app.close();
  });

  it('POST /auth/login returns tokens for admin', async () => {
    const response = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ username: 'test-admin', password: 'test-admin-password' })
      .expect(201);

    expect(response.body.accessToken).toBeDefined();
    expect(response.body.refreshToken).toBeDefined();
  });

  it('POST /auth/login rejects invalid credentials with unified error', async () => {
    const response = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ username: 'admin', password: 'wrong-password' })
      .expect(401);

    expect(response.body.errorCode).toBe('INVALID_CREDENTIALS');
  });

  it('POST /auth/refresh rotates tokens', async () => {
    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ username: 'test-admin', password: 'test-admin-password' })
      .expect(201);

    const refresh = await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: login.body.refreshToken })
      .expect(201);

    expect(refresh.body.accessToken).toBeDefined();
    expect(refresh.body.refreshToken).toBeDefined();
    expect(refresh.body.refreshToken).not.toBe(login.body.refreshToken);
  });

  it('login persists a missing uid and accepts the access token', async () => {
    const passwordHash = await bcrypt.hash('legacy-pass', 12);
    const connection = app.get<Connection>(getConnectionToken());
    const db = connection.db;
    if (!db) {
      throw new Error('Mongo connection is not available');
    }

    const { insertedId } = await db.collection('users').insertOne({
      username: 'legacy-user',
      passwordHash,
      role: 'admin',
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const before = await db.collection('users').findOne({ _id: insertedId });
    expect(before?.uid).toBeUndefined();

    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ username: 'legacy-user', password: 'legacy-pass' })
      .expect(201);

    const after = await db.collection('users').findOne({ _id: insertedId });
    expect(typeof after?.uid).toBe('string');
    expect(String(after?.uid).length).toBeGreaterThan(0);

    await request(app.getHttpServer())
      .patch('/users/me/fcm-token')
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .send({ fcmToken: 'test-fcm-token' })
      .expect(200);

    await request(app.getHttpServer())
      .get('/customers?page=1&limit=20')
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .expect(200);
  });
});
