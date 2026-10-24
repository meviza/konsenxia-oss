/**
 * Redis service - Upstash (cloud) veya in-memory fallback (geliştirme)
 * Upstash credentials yoksa otomatik in-memory mod kullanılır
 */

export interface IRedisService {
  connect(): Promise<void>;
  disconnect(): Promise<void>;
  set(key: string, value: string, ttl?: number): Promise<void>;
  get(key: string): Promise<string | null>;
  del(key: string): Promise<number>;
  exists(key: string): Promise<boolean>;
  hSet(key: string, field: string, value: string): Promise<number>;
  hGet(key: string, field: string): Promise<string | undefined>;
  hGetAll(key: string): Promise<Record<string, string>>;
  healthCheck(): Promise<boolean>;
  isCloud(): boolean;
}

export function getRedisService(): IRedisService {
  // Lazy load to avoid circular dependency
  const { config } = require('../config');
  if (config.upstash.url && config.upstash.token) {
    const { RedisUpstashService } = require('./redis-upstash');
    return new RedisUpstashService();
  }
  const { RedisMemoryService } = require('./redis-memory');
  return new RedisMemoryService(config.upstash.keyPrefix);
}
