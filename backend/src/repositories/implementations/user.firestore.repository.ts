import { IUserRepository } from '../interfaces/user.repository.interface';
import { FirestoreService } from '../../services/firestore';

export class UserFirestoreRepository implements IUserRepository {
    private db: FirestoreService;

    constructor() {
        this.db = new FirestoreService();
    }

    async create(user: any): Promise<any> {
        return await this.db.createUser(user);
    }

    async update(id: string, user: Partial<any>): Promise<any> {
        // A future DB abstraction will make this truly dynamic.
        // For now, wrapping the existing logic.
        throw new Error('Method not completely implemented for Firestore yet.');
    }

    async delete(id: string): Promise<boolean> {
        throw new Error('Method not completely implemented for Firestore yet.');
    }

    async findById(id: string): Promise<any | null> {
        return await this.db.getUserById(id);
    }

    async findAll(filters?: Record<string, any>): Promise<any[]> {
        throw new Error('Method not completely implemented for Firestore yet.');
    }

    async findByEmail(email: string): Promise<any | null> {
        return await this.db.getUserByEmail(email);
    }

    async findByRole(role: string): Promise<any[]> {
        throw new Error('Method not completely implemented for Firestore yet.');
    }
}
