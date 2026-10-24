import express, { Response } from 'express';
import request from 'supertest';
import * as responses from '../utils/responseHandler';

// Exercise the HTTP adapters used by medical-ai routes, without model calls.
const adapters = responses as unknown as {
  sendSuccess: (res: Response, data: unknown) => unknown;
  sendError: (res: Response, message: string, status: number) => unknown;
};

describe('HTTP response adapters', () => {
  it('returns a JSON success envelope containing the route result', async () => {
    const app = express();
    app.get('/result', (_req, res) => {
      adapters.sendSuccess(res, { text: 'synthetic fixture' });
    });
    const result = await request(app).get('/result');
    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.data).toEqual({ text: 'synthetic fixture' });
  });

  it('returns the specified failure status and safe message as JSON', async () => {
    const app = express();
    app.get('/failure', (_req, res) => {
      adapters.sendError(res, 'Service unavailable', 503);
    });
    const result = await request(app).get('/failure');
    expect(result.status).toBe(503);
    expect(result.body).toEqual({ success: false, message: 'Service unavailable' });
  });
});
