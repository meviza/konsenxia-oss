import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { registerValidator, loginValidator, refreshTokenValidator } from '../middleware/validators/auth.validator';

const router = Router();
const authController = new AuthController();

// Register endpoint
router.post('/register', registerValidator, authController.register.bind(authController));

// Login endpoint
router.post('/login', loginValidator, authController.login.bind(authController));

// Refresh token endpoint
router.post('/refresh', refreshTokenValidator, authController.refresh.bind(authController));

// Logout endpoint
router.post('/logout', authController.logout.bind(authController));

export default router;
