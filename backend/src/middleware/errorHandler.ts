import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
  code?: number;
  errors?: Record<string, { message: string }>;
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Server Error';

  logger.error(err);

  if (err.name === 'CastError') {
    statusCode = 404;
    message = 'Resource not found';
  }

  if ((err as any).code === 11000) {
    statusCode = 400;
    message = 'Duplicate field value entered';
  }

  if (err.name === 'ValidationError' && err.errors) {
    statusCode = 400;
    message = Object.values(err.errors).map((val) => val.message).join(', ');
  }

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};
