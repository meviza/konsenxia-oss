import { IBaseRepository } from './base.repository.interface';

// This interface allows us to easily switch from Firestore to PostgreSQL
export interface IUserRepository extends IBaseRepository<any> {
    findByEmail(email: string): Promise<any | null>;
    findByRole(role: string): Promise<any[]>;
}
