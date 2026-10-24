import { logger } from '../utils/logger';
import type { IRedisService } from './redis';

interface MemoryEntry {
  value: string;
  expiresAt?: number;
}

export class RedisMemoryService implements IRedisService {
  private store = new Map<string, MemoryEntry>();
  private hashStore = new Map<string, Record<string, string>>();
  private keyPrefix: string;

  constructor(keyPrefix = 'konsexia:') {
    this.keyPrefix = keyPrefix;
  }

  async connect(): Promise<void> {
    logger.info('Redis (in-memory) ready - Upstash credentials yok, geliştirme modu');
  }

  async disconnect(): Promise<void> {
    this.store.clear();
    this.hashStore.clear();
    logger.info('Redis (in-memory) disconnected');
  }

  private fullKey(key: string): string {
    return `${this.keyPrefix}${key}`;
  }

  private pruneExpired(): void {
    const now = Date.now();
    for (const [k, v] of this.store) {
      if (v.expiresAt && v.expiresAt < now) this.store.delete(k);
    }
  }

  async set(key: string, value: string, ttl?: number): Promise<void> {
    this.pruneExpired();
    const fullKey = this.fullKey(key);
    const entry: MemoryEntry = {
      value,
      expiresAt: ttl ? Date.now() + ttl * 1000 : undefined,
    };
    this.store.set(fullKey, entry);
  }

  async get(key: string): Promise<string | null> {
    this.pruneExpired();
    const fullKey = this.fullKey(key);
    const entry = this.store.get(fullKey);
    if (!entry) return null;
    if (entry.expiresAt && entry.expiresAt < Date.now()) {
      this.store.delete(fullKey);
      return null;
    }
    return entry.value;
  }

  async del(key: string): Promise<number> {
    const fullKey = this.fullKey(key);
    const had = this.store.has(fullKey) || this.hashStore.has(fullKey) ? 1 : 0;
    this.store.delete(fullKey);
    this.hashStore.delete(fullKey);
    return had;
  }

  async exists(key: string): Promise<boolean> {
    this.pruneExpired();
    const fullKey = this.fullKey(key);
    const entry = this.store.get(fullKey);
    if (entry?.expiresAt && entry.expiresAt < Date.now()) {
      this.store.delete(fullKey);
      return false;
    }
    return this.store.has(fullKey) || this.hashStore.has(fullKey);
  }

  async hSet(key: string, field: string, value: string): Promise<number> {
    const fullKey = this.fullKey(key);
    let hash = this.hashStore.get(fullKey);
    if (!hash) {
      hash = {};
      this.hashStore.set(fullKey, hash);
    }
    const isNew = !(field in hash);
    hash[field] = value;
    return isNew ? 1 : 0;
  }

  async hGet(key: string, field: string): Promise<string | undefined> {
    const fullKey = this.fullKey(key);
    const hash = this.hashStore.get(fullKey);
    return hash?.[field];
  }

  async hGetAll(key: string): Promise<Record<string, string>> {
    const fullKey = this.fullKey(key);
    return this.hashStore.get(fullKey) || {};
  }

  async healthCheck(): Promise<boolean> {
    return true;
  }

  isCloud(): boolean {
    return false;
  }
}
