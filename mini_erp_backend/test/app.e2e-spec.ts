import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { getTestMongoUri, setTestEnv } from './test-database';
import { createTestApp } from './create-test-app';

describe('Health (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    setTestEnv(getTestMongoUri());
    app = await createTestApp();
  });

  afterAll(async () => {
    if (app) await app.close();
  });

  it('/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .expect((res) => {
        expect(res.body.status).toBe('ok');
        expect(res.body.mongo).toBe('connected');
      });
  });
});
