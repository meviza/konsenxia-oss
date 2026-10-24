import { body } from 'express-validator';

export const registerValidator = [
    body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
    body('firstName').trim().isLength({ min: 2 }).withMessage('First name must be at least 2 characters'),
    body('lastName').trim().isLength({ min: 2 }).withMessage('Last name must be at least 2 characters'),
    body('role').isIn(['PATIENT', 'DOCTOR', 'ADMIN']).withMessage('Invalid role'),
    body('firebaseToken').optional().isString(),

];

export const loginValidator = [
    body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email'),
    body('password').notEmpty().withMessage('Password is required'),
    body('firebaseToken').optional().isString(),

];

export const refreshTokenValidator = [
    body('refreshToken').notEmpty().withMessage('Refresh token is required'),
];
