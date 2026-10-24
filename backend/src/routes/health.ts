import { Router } from 'express';
import { FirestoreService } from '../services/firestore';
import { getRedisService } from '../services/redis';
import { AIGeneralService } from '../services/ai';

const router = Router();

// Health check endpoint
router.get('/', async (req, res) => {
  try {
    const redis = getRedisService();
    const [dbHealth, redisHealth] = await Promise.all([
      new FirestoreService().healthCheck(),
      redis.healthCheck(),
    ]);

    const health = {
      status: 'ok',
      timestamp: new Date().toISOString(),
      services: {
        database: dbHealth ? 'healthy' : 'unhealthy',
        redis: redisHealth ? 'healthy' : 'unhealthy',
        ai: 'healthy', // AI service health check would require API call
      },
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      version: '1.0.0',
    };

    const statusCode = dbHealth && redisHealth ? 200 : 503;

    res.status(statusCode).json(health);
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Health check failed',
      timestamp: new Date().toISOString(),
    });
  }
});

// Detailed health check
router.get('/detailed', async (req, res) => {
  try {
    const database = new FirestoreService();
    const redis = getRedisService();

    const [dbHealth, redisHealth] = await Promise.all([
      database.healthCheck(),
      redis.healthCheck(),
    ]);

    const health = {
      status: 'ok',
      timestamp: new Date().toISOString(),
      services: {
        database: {
          status: dbHealth ? 'healthy' : 'unhealthy',
          details: {
            provider: 'Firestore',
            projectId: process.env.FIREBASE_PROJECT_ID || '(not set)',
          },
        },
        redis: {
          status: redisHealth ? 'healthy' : 'unhealthy',
          details: {
            provider: redis.isCloud() ? 'Upstash' : 'in-memory (dev)',
          },
        },
        ai: {
          status: 'healthy',
          details: {
            model: process.env.GEMINI_MODEL || 'gemini-pro',
            maxTokens: process.env.GEMINI_MAX_TOKENS || '2048',
            temperature: process.env.GEMINI_TEMPERATURE || '0.7',
          },
        },
      },
      system: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        platform: process.platform,
        nodeVersion: process.version,
      },
      version: '1.0.0',
    };

    const statusCode = dbHealth && redisHealth ? 200 : 503;

    res.status(statusCode).json(health);
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Detailed health check failed',
      timestamp: new Date().toISOString(),
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

// Readiness probe
router.get('/ready', async (req, res) => {
  try {
    const redis = getRedisService();
    const [dbHealth, redisHealth] = await Promise.all([
      new FirestoreService().healthCheck(),
      redis.healthCheck(),
    ]);

    if (dbHealth && redisHealth) {
      res.status(200).json({
        status: 'ready',
        timestamp: new Date().toISOString(),
      });
    } else {
      res.status(503).json({
        status: 'not ready',
        timestamp: new Date().toISOString(),
        services: {
          database: dbHealth ? 'ready' : 'not ready',
          redis: redisHealth ? 'ready' : 'not ready',
        },
      });
    }
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Readiness check failed',
      timestamp: new Date().toISOString(),
    });
  }
});

// Liveness probe
router.get('/live', (req, res) => {
  res.status(200).json({
    status: 'alive',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

export default router;
