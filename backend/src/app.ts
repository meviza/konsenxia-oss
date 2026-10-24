import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import path from 'path';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { config } from './config';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import { authMiddleware } from './middleware/auth';
import { FirestoreService } from './services/firestore';
import { getRedisService, type IRedisService } from './services/redis';
import { AIGeneralService } from './services/ai';
import { WebSocketService } from './services/websocket';
import { registerEventSubscribers } from './events/subscribers';
import { eventBus } from './utils/eventBus';

// Routes
import authRoutes from './routes/auth';
import aiRoutes from './routes/ai';
import medicalAiRoutes from './routes/medical-ai';
import healthRoutes from './routes/health';
import consensusRoutes from './routes/consensus';
import drugAnalyticsRoutes from './routes/drug-analytics';
import simulationRoutes from './routes/simulation';
import emergencyRoutes from './routes/emergency';
import medicalFilesRoutes from './routes/medical-files';

class KONSENXIAServer {
  private app: express.Application;
  private server: any;
  private io: Server;
  private database: FirestoreService;
  private redis: IRedisService;
  private aiService: AIGeneralService;
  private webSocketService: WebSocketService;

  constructor() {
    this.app = express();
    this.server = createServer(this.app);
    this.io = new Server(this.server, {
      cors: {
        origin: config.cors.origins,
        methods: ['GET', 'POST'],
        credentials: true,
      },
    });

    this.webSocketService = new WebSocketService(this.io); // Created before async init
    this.initializeServices();
    this.initializeMiddleware();
    this.initializeRoutes();
    this.initializeWebSocket();
    this.initializeErrorHandling();
  }

  private async initializeServices(): Promise<void> {
    try {
      this.database = new FirestoreService();
      await this.database.connect();

      this.redis = getRedisService();
      await this.redis.connect();

      this.aiService = new AIGeneralService();

      // Register async event listeners (Workers)
      registerEventSubscribers();

      logger.info('All services initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize services:', error);
      process.exit(1);
    }
  }

  private initializeMiddleware(): void {
    // Security middleware
    this.app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: ["'self'", "'unsafe-inline'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          imgSrc: ["'self'", "data:", "https:"],
        },
      },
    }));

    // CORS configuration
    this.app.use(cors({
      origin: config.cors.origins,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
      credentials: true,
    }));

    // Compression
    this.app.use(compression());

    // Rate limiting
    const limiter = rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100, // limit each IP to 100 requests per windowMs
      message: {
        error: 'Too many requests from this IP, please try again later.',
      },
      standardHeaders: true,
      legacyHeaders: false,
    });
    this.app.use('/api', limiter);

    // Body parsing
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Request logging
    this.app.use(requestLogger);
  }

  private initializeRoutes(): void {
    // Health check
    this.app.use('/health', healthRoutes);

    // API routes
    this.app.use('/api/v1/auth', authRoutes);
    this.app.use('/api/v1/ai', authMiddleware, aiRoutes);
    this.app.use('/api/v1/medical-ai', authMiddleware, medicalAiRoutes);
    this.app.use('/api/v1/consensus', authMiddleware, consensusRoutes);
    this.app.use('/api/v1/drug-analytics', authMiddleware, drugAnalyticsRoutes);
    this.app.use('/api/v1/simulation', authMiddleware, simulationRoutes);
    this.app.use('/api/v1/emergency', authMiddleware, emergencyRoutes);
    this.app.use('/api/v1/files', authMiddleware, medicalFilesRoutes);

    // Static serving for uploads
    this.app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

    // 404 handler
    this.app.use('*', (req, res) => {
      res.status(404).json({
        error: 'Route not found',
        path: req.originalUrl,
        method: req.method,
      });
    });
  }

  private initializeWebSocket(): void {
    if (this.webSocketService) {
      this.webSocketService.initialize();

      // Listen for domain events and broadcast to socket rooms
      eventBus.subscribe('VOTE_UPDATED', (payload: any) => {
        this.webSocketService.broadcastVoteUpdate(payload.caseId, payload);
      });

      eventBus.subscribe('CONSENSUS_REACHED', (payload: any) => {
        this.webSocketService.broadcastConsensusReached(payload.caseId, payload);
      });
    }
  }

  private initializeErrorHandling(): void {
    this.app.use(errorHandler);

    // Unhandled promise rejection
    process.on('unhandledRejection', (reason, promise) => {
      logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
    });

    // Uncaught exception
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => this.gracefulShutdown());
    process.on('SIGINT', () => this.gracefulShutdown());
  }

  private async gracefulShutdown(): Promise<void> {
    logger.info('Starting graceful shutdown...');

    this.server.close(async () => {
      logger.info('HTTP server closed');

      await this.database.disconnect();
      await this.redis.disconnect();

      logger.info('All services disconnected');
      process.exit(0);
    });

    // Force shutdown after 30 seconds
    setTimeout(() => {
      logger.error('Force shutdown after timeout');
      process.exit(1);
    }, 30000);
  }

  public async start(): Promise<void> {
    const port = config.server.port;

    this.server.listen(port, () => {
      logger.info(`🚀 KONSENXIA Server running on port ${port}`);
      logger.info(`📊 Environment: ${config.nodeEnv}`);
      logger.info(`🔗 API Base URL: http://localhost:${port}/api/v1`);
    });
  }
}

// Start the server
const server = new KONSENXIAServer();
server.start().catch((error) => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});

export default server;
