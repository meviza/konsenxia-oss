import admin from 'firebase-admin';
import { config } from '../config';
import { logger } from '../utils/logger';

const USERS_COLLECTION = 'users';

export interface FirestoreUser {
  id: string;
  email: string;
  password_hash: string;
  first_name: string;
  last_name: string;
  role: 'PATIENT' | 'DOCTOR' | 'ADMIN';
  created_at: FirebaseFirestore.Timestamp;
  updated_at: FirebaseFirestore.Timestamp;
}

export class FirestoreService {
  private db: admin.firestore.Firestore;
  private initialized = false;

  constructor() {
    if (!admin.apps.length) {
      if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        admin.initializeApp({ credential: admin.credential.applicationDefault() });
      } else if (config.firebase.projectId && config.firebase.clientEmail && config.firebase.privateKey) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: config.firebase.projectId,
            clientEmail: config.firebase.clientEmail,
            privateKey: config.firebase.privateKey.replace(/\\n/g, '\n'),
          }),
        });
      } else {
        throw new Error(
          'Firebase configuration is missing. Set GOOGLE_APPLICATION_CREDENTIALS (path to JSON) or FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY in .env'
        );
      }
    }

    this.db = admin.firestore();
  }

  async connect(): Promise<void> {
    try {
      await this.db.collection(USERS_COLLECTION).limit(1).get();
      this.initialized = true;
      logger.info('Firestore connected successfully');
    } catch (error) {
      logger.error('Firestore connection failed:', error);
      throw error;
    }
  }

  async disconnect(): Promise<void> {
    try {
      if (admin.apps.length) {
        await admin.app().delete();
      }
      this.initialized = false;
      logger.info('Firestore disconnected successfully');
    } catch (error) {
      logger.error('Firestore disconnection failed:', error);
    }
  }

  async getUserByEmail(email: string): Promise<FirestoreUser | null> {
    const snapshot = await this.db
      .collection(USERS_COLLECTION)
      .where('email', '==', email.toLowerCase())
      .limit(1)
      .get();

    if (snapshot.empty) return null;

    const doc = snapshot.docs[0];
    return { id: doc.id, ...doc.data() } as FirestoreUser;
  }

  async getUserById(id: string): Promise<FirestoreUser | null> {
    const doc = await this.db.collection(USERS_COLLECTION).doc(id).get();

    if (!doc.exists) return null;

    return { id: doc.id, ...doc.data() } as FirestoreUser;
  }

  async createUser(data: Omit<FirestoreUser, 'created_at' | 'updated_at'>): Promise<FirestoreUser> {
    const now = admin.firestore.Timestamp.now();
    const userData = {
      ...data,
      email: data.email.toLowerCase(),
      created_at: now,
      updated_at: now,
    };

    await this.db.collection(USERS_COLLECTION).doc(data.id).set(userData);

    return { ...userData, created_at: now, updated_at: now } as FirestoreUser;
  }

  async healthCheck(): Promise<boolean> {
    try {
      await this.db.collection(USERS_COLLECTION).limit(1).get();
      return true;
    } catch (error) {
      logger.error('Firestore health check failed:', error);
      return false;
    }
  }
}
