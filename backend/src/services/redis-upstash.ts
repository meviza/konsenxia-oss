import { Redis } from '@upstash/redis';
import { config } from '../config';
import { logger } from '../utils/logger';
import type { IRedisService } from './redis';

export class RedisUpstashService implements IRedisService {
  private client: Redis;
  private keyPrefix: string;

  constructor() {
    if (!config.upstash.url || !config.upstash.token) {
      throw new Error('Upstash Redis configuration is missing. Set UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN in .env');
    }

    this.client = new Redis({
      url: config.upstash.url,
      token: config.upstash.token,
    });
    this.keyPrefix = config.upstash.keyPrefix || 'konsexia:';
  }

  async connect(): Promise<void> {
    try {
      await this.client.ping();
      logger.info('Upstash Redis connected successfully');
    } catch (error) {
      logger.error('Upstash Redis connection failed:', error);
      throw error;
    }
  }

  async disconnect(): Promise<void> {
    logger.info('Upstash Redis disconnected (connectionless - no action needed)');
  }

  async set(key: string, value: string, ttl?: number): Promise<void> {
    const fullKey = `${this.keyPrefix}${key}`;

    if (ttl) {
      await this.client.setex(fullKey, ttl, value);
    } else {
      await this.client.set(fullKey, value);
    }

    logger.debug('Redis SET', { key: fullKey, ttl });
  }

  async get(key: string): Promise<string | null> {
    const fullKey = `${this.keyPrefix}${key}`;
    const value = await this.client.get<string>(fullKey);

    logger.debug('Redis GET', { key: fullKey, found: value !== null });

    return value ?? null;
  }

  async del(key: string): Promise<number> {
    const fullKey = `${this.keyPrefix}${key}`;
    const result = await this.client.del(fullKey);

    logger.debug('Redis DEL', { key: fullKey, deleted: result });

    return result;
  }

  async exists(key: string): Promise<boolean> {
    const fullKey = `${this.keyPrefix}${key}`;
    const result = await this.client.exists(fullKey);

    logger.debug('Redis EXISTS', { key: fullKey, exists: result === 1 });

    return result === 1;
  }

  async hSet(key: string, field: string, value: string): Promise<number> {
    const fullKey = `${this.keyPrefix}${key}`;
    const result = await this.client.hset(fullKey, { [field]: value });

    logger.debug('Redis HSET', { key: fullKey, field, result });

    return result;
  }

  async hGet(key: string, field: string): Promise<string | undefined> {
    const fullKey = `${this.keyPrefix}${key}`;
    const value = await this.client.hget<string>(fullKey, field);

    logger.debug('Redis HGET', { key: fullKey, field, found: !!value });

    return value ?? undefined;
  }

  async hGetAll(key: string): Promise<Record<string, string>> {
    const fullKey = `${this.keyPrefix}${key}`;
    const value = await this.client.hgetall<Record<string, string>>(fullKey);

    logger.debug('Redis HGETALL', { key: fullKey, count: value ? Object.keys(value).length : 0 });

    return value || {};
  }

  async healthCheck(): Promise<boolean> {
    try {
      await this.client.ping();
      return true;
    } catch (error) {
      logger.error('Upstash Redis health check failed:', error);
      return false;
    }
  }

  isCloud(): boolean {
    return true;
  }
}
