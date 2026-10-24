export interface ApiResponse<T = any> {
    success: boolean;
    message: string;
    data?: T;
    errors?: any[];
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
