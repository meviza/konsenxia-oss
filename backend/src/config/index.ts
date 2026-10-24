import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

interface Config {
  nodeEnv: string;
  server: {
    port: number;
    host: string;
  };
  firebase: {
    projectId: string;
    clientEmail: string;
    privateKey: string;
  };
  upstash: {
    url: string;
    token: string;
    keyPrefix: string;
  };
  jwt: {
    secret: string;
    expiresIn: string;
    refreshExpiresIn: string;
  };
  cors: {
    origins: string[];
  };
  ai: {
    geminiApiKey: string;
    model: string;
    maxTokens: number;
    temperature: number;
  };
  upload: {
    maxSize: number;
    allowedTypes: string[];
    destination: string;
  };
  logging: {
    level: string;
    format: string;
  };
  rateLimit: {
    windowMs: number;
    max: number;
  };
}

export const config: Config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  
  server: {
    port: parseInt(process.env.PORT || '3000', 10),
    host: process.env.HOST || '0.0.0.0',
  },
  
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
    privateKey: process.env.FIREBASE_PRIVATE_KEY || '',
  },
  
  upstash: {
    url: process.env.UPSTASH_REDIS_REST_URL || '',
    token: process.env.UPSTASH_REDIS_REST_TOKEN || '',
    keyPrefix: process.env.UPSTASH_REDIS_KEY_PREFIX || 'konsexia:',
  },
  
  jwt: {
    secret: process.env.JWT_SECRET || 'your-super-secret-jwt-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '24h',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },
  
  cors: {
    origins: process.env.CORS_ORIGINS?.split(',') || [
      'http://localhost:3000',
      'http://localhost:8081',
      'https://konsexia.com',
    ],
  },
  
  ai: {
    geminiApiKey: process.env.GEMINI_API_KEY || '',
    model: process.env.GEMINI_MODEL || 'gemini-pro',
    maxTokens: parseInt(process.env.GEMINI_MAX_TOKENS || '2048', 10),
    temperature: parseFloat(process.env.GEMINI_TEMPERATURE || '0.7'),
  },
  
  upload: {
    maxSize: parseInt(process.env.UPLOAD_MAX_SIZE || '10485760', 10), // 10MB
    allowedTypes: process.env.UPLOAD_ALLOWED_TYPES?.split(',') || [
      'image/jpeg',
      'image/png',
      'image/gif',
      'application/pdf',
    ],
    destination: process.env.UPLOAD_DESTINATION || './uploads',
  },
  
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    format: process.env.LOG_FORMAT || 'json',
  },
  
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX || '100', 10),
  },
};

// Validation
const requiredEnvVars = [
  'JWT_SECRET',
  'GEMINI_API_KEY',
];

if (config.nodeEnv === 'production') {
  requiredEnvVars.push('UPSTASH_REDIS_REST_URL', 'UPSTASH_REDIS_REST_TOKEN');
  const hasFirebaseCreds = process.env.GOOGLE_APPLICATION_CREDENTIALS ||
    (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY);
  if (!hasFirebaseCreds) {
    requiredEnvVars.push('FIREBASE_PROJECT_ID', 'FIREBASE_CLIENT_EMAIL', 'FIREBASE_PRIVATE_KEY');
  }
}

const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar]);

if (missingEnvVars.length > 0 && config.nodeEnv === 'production') {
  throw new Error(`Missing required environment variables: ${missingEnvVars.join(', ')}`);
}

export default config;
