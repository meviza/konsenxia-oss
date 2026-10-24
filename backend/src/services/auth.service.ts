import bcrypt from 'bcryptjs';
import admin from 'firebase-admin';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../config';
import { logger } from '../utils/logger';
import { IUserRepository } from '../repositories/interfaces/user.repository.interface';
import { UserFirestoreRepository } from '../repositories/implementations/user.firestore.repository';

export class AuthService {
    private userRepository: IUserRepository;

    constructor(userRepository?: IUserRepository) {
        // Inject the dependency or default to the existing Firestore implementation
        this.userRepository = userRepository || new UserFirestoreRepository();
    }

    async registerUser(userData: any) {
        const { email, password, firstName, lastName, role, firebaseToken } = userData;

        // 1. Verify Firebase Token if provided
        let firebaseUid: string | undefined;
        if (firebaseToken) {
            try {
                const decodedToken = await admin.auth().verifyIdToken(firebaseToken);
                firebaseUid = decodedToken.uid;
                if (decodedToken.email !== email) {
                    throw new Error('Email mismatch with Firebase token');
                }
            } catch (err) {
                logger.error('Firebase token verification failed', err);
                throw new Error('Invalid Firebase token');
            }
        }

        const existingUser = await this.userRepository.findByEmail(email);
        if (existingUser) {
            throw new Error('User with this email already exists');
        }

        const saltRounds = 12;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const userId = firebaseUid || uuidv4();
        const user = await this.userRepository.create({
            id: userId,
            email,
            password_hash: hashedPassword,
            first_name: firstName,
            last_name: lastName,
            role,
            firebase_uid: firebaseUid,
        });

        const tokens = this.generateTokens(user);
        logger.info('User registered successfully', { userId: user.id, email: user.email });

        return { user, tokens };
    }

    async loginUser(credentials: any) {
        const { email, password, firebaseToken } = credentials;

        // Verify Firebase Token if provided
        if (firebaseToken) {
            try {
                await admin.auth().verifyIdToken(firebaseToken);
            } catch (err) {
                logger.error('Firebase token verification failed', err);
                throw new Error('Invalid Firebase token');
            }
        }

        const user = await this.userRepository.findByEmail(email);
        if (!user) {
            throw new Error('Invalid email or password');
        }

        const isValidPassword = await bcrypt.compare(password, user.password_hash);
        if (!isValidPassword) {
            throw new Error('Invalid email or password');
        }

        const tokens = this.generateTokens(user);
        logger.info('User logged in successfully', { userId: user.id, email: user.email });

        return { user, tokens };
    }

    async refreshUserToken(refreshToken: string) {
        try {
            const decoded = jwt.verify(refreshToken, config.jwt.secret) as { userId: string };
            const user = await this.userRepository.findById(decoded.userId);

            if (!user) {
                throw new Error('Invalid refresh token');
            }

            const newAccessToken = jwt.sign(
                { userId: user.id, email: user.email, role: user.role },
                config.jwt.secret,
                { expiresIn: config.jwt.expiresIn } as jwt.SignOptions
            );

            return newAccessToken;
        } catch (error) {
            throw new Error('Invalid refresh token');
        }
    }

    private generateTokens(user: any) {
        const accessToken = jwt.sign(
            { userId: user.id, email: user.email, role: user.role },
            config.jwt.secret,
            { expiresIn: config.jwt.expiresIn } as jwt.SignOptions
        );

        const refreshToken = jwt.sign(
            { userId: user.id },
            config.jwt.secret,
            { expiresIn: config.jwt.refreshExpiresIn } as jwt.SignOptions
        );

        return { accessToken, refreshToken };
    }
}
