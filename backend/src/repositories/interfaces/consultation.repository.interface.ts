import { IBaseRepository } from './base.repository.interface';
import { MedicalConsultation } from '../../types/consultation.types';

export interface IConsultationRepository extends IBaseRepository<MedicalConsultation> {
    findByPatientId(patientId: string): Promise<MedicalConsultation[]>;
    findByDoctorId(doctorId: string): Promise<MedicalConsultation[]>;
    updateStatus(id: string, status: string): Promise<MedicalConsultation | null>;
}
