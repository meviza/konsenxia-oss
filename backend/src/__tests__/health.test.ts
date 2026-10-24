import express from 'express';
import request from 'supertest';

import healthRoutes from '../routes/health';
import { FirestoreService } from '../services/firestore';
import { getRedisService } from '../services/redis';

jest.mock('../services/firestore');
jest.mock('../services/redis');

describe('Health routes', () => {
  const createApp = () => {
    const app = express();
    app.use('/health', healthRoutes);
    return app;
  };

  const mockFirestoreHealth = (value: boolean) => {
    (FirestoreService as unknown as jest.Mock).mockImplementation(() => ({
      healthCheck: jest.fn().mockResolvedValue(value),
      connect: jest.fn(),
    }));
  };

  const mockRedisHealth = (value: boolean) => {
    (getRedisService as unknown as jest.Mock).mockReturnValue({
      healthCheck: jest.fn().mockResolvedValue(value),
      isCloud: jest.fn().mockReturnValue(false),
      connect: jest.fn(),
    });
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns 200 and healthy statuses when Firestore and Redis are healthy', async () => {
    const app = createApp();
    mockFirestoreHealth(true);
    mockRedisHealth(true);

    const res = await request(app).get('/health');

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.services.database).toBe('healthy');
    expect(res.body.services.redis).toBe('healthy');
  });

  it('returns 503 when Firestore or Redis is unhealthy', async () => {
    const app = createApp();
    mockFirestoreHealth(false);
    mockRedisHealth(true);

    const res = await request(app).get('/health');

    expect(res.status).toBe(503);
    expect(res.body.status).toBe('ok');
    expect(res.body.services.database).toBe('unhealthy');
  });

  it('returns 500 when health check throws', async () => {
    const app = createApp();

    (FirestoreService as unknown as jest.Mock).mockImplementation(() => ({
      healthCheck: jest.fn().mockRejectedValue(new Error('firestore down')),
      connect: jest.fn(),
    }));
    (getRedisService as unknown as jest.Mock).mockReturnValue({
      healthCheck: jest.fn().mockResolvedValue(true),
      isCloud: jest.fn().mockReturnValue(false),
      connect: jest.fn(),
    });

    const res = await request(app).get('/health');

    expect(res.status).toBe(500);
    expect(res.body.status).toBe('error');
    expect(res.body.message).toBe('Health check failed');
  });

  it('returns 200 for liveness probe', async () => {
    const app = createApp();

    const res = await request(app).get('/health/live');

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('alive');
  });

  it('returns correct readiness status when dependencies are healthy', async () => {
    const app = createApp();
    mockFirestoreHealth(true);
    mockRedisHealth(true);

    const res = await request(app).get('/health/ready');

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ready');
  });

  it('returns 503 readiness when dependencies are not ready', async () => {
    const app = createApp();
    mockFirestoreHealth(false);
    mockRedisHealth(false);

    const res = await request(app).get('/health/ready');

    expect(res.status).toBe(503);
    expect(res.body.status).toBe('not ready');
    expect(res.body.services.database).toBe('not ready');
    expect(res.body.services.redis).toBe('not ready');
  });
});

