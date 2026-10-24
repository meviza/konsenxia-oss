import { Server } from 'socket.io';
import { logger } from '../utils/logger';

export class WebSocketService {
  private io: Server;

  constructor(io: Server) {
    this.io = io;
  }

  initialize(): void {
    this.io.on('connection', (socket) => {
      logger.info('WebSocket client connected', { socketId: socket.id });

      socket.on('joinCaseRoom', (caseId: string) => {
        socket.join(`case_${caseId}`);
        logger.info(`Socket ${socket.id} joined room case_${caseId}`);
      });

      socket.on('leaveCaseRoom', (caseId: string) => {
        socket.leave(`case_${caseId}`);
        logger.info(`Socket ${socket.id} left room case_${caseId}`);
      });

      socket.on('disconnect', () => {
        logger.info('WebSocket client disconnected', { socketId: socket.id });
      });
    });
  }

  // Helper methods to broadcast updates from other services
  broadcastVoteUpdate(caseId: string, payload: any): void {
    this.io.to(`case_${caseId}`).emit('vote_updated', payload);
  }

  broadcastConsensusReached(caseId: string, payload: any): void {
    this.io.to(`case_${caseId}`).emit('consensus_reached', payload);
  }
}
