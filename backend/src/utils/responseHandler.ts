import type { Response } from 'express';

export interface ApiResponse<T = any> {
    success: boolean;
    message: string;
    data?: T;
    errors?: any[];
}

export function sendSuccess<T>(res: Response, data: T): Response {
    return res.status(200).json(ResponseHandler.success('Success', data));
}

export function sendError(res: Response, message: string, statusCode = 500): Response {
    return res.status(statusCode).json(ResponseHandler.error(message));
}

export class ResponseHandler {
    static success<T>(message: string, data?: T): ApiResponse<T> {
        return {
            success: true,
            message,
            data,
        };
    }

    static error(message: string, errors?: any[]): ApiResponse {
        return {
            success: false,
            message,
            errors,
        };
    }
}
