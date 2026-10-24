import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import { AuthService } from '../services/auth.service';
import { logger } from '../utils/logger';
import { ResponseHandler } from '../utils/responseHandler';

export class AuthController {
    private authService: AuthService;

    constructor() {
        this.authService = new AuthService();
    }

    async register(req: Request, res: Response) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json(ResponseHandler.error('Validation failed', errors.array()));
            }

            const { user, tokens } = await this.authService.registerUser(req.body);

            res.status(201).json(ResponseHandler.success('User registered successfully', {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    role: user.role,
                },
                tokens,
                token: tokens.accessToken,
            }));
        } catch (error: any) {
            if (error.message === 'User with this email already exists') {
                return res.status(409).json(ResponseHandler.error(error.message));
            }
            logger.error('Registration error:', error);
            res.status(500).json(ResponseHandler.error('Internal server error'));
        }
    }

    async login(req: Request, res: Response) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json(ResponseHandler.error('Validation failed', errors.array()));
            }

            const { user, tokens } = await this.authService.loginUser(req.body);

            res.json(ResponseHandler.success('Login successful', {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    role: user.role,
                },
                tokens,
                token: tokens.accessToken,
            }));
        } catch (error: any) {
            if (error.message === 'Invalid email or password') {
                return res.status(401).json(ResponseHandler.error(error.message));
            }
            logger.error('Login error:', error);
            res.status(500).json(ResponseHandler.error('Internal server error'));
        }
    }

    async refresh(req: Request, res: Response) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json(ResponseHandler.error('Validation failed', errors.array()));
            }

            const newAccessToken = await this.authService.refreshUserToken(req.body.refreshToken);

            res.json(ResponseHandler.success('Token refreshed successfully', {
                accessToken: newAccessToken,
                token: newAccessToken,
            }));
        } catch (error: any) {
            logger.error('Token refresh error:', error);
            res.status(401).json(ResponseHandler.error('Invalid refresh token'));
        }
    }

    async logout(req: Request, res: Response) {
        try {
            logger.info('User logged out');
            res.json(ResponseHandler.success('Logout successful'));
        } catch (error) {
            logger.error('Logout error:', error);
            res.status(500).json(ResponseHandler.error('Internal server error'));
        }
    }
}
