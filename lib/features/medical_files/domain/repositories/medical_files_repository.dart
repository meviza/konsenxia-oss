import '../entities/medical_file_entity.dart';

abstract class MedicalFilesRepository {
  Future<MedicalFile> uploadFile({
    required String filePath,
    required String fileName,
    required FileCategory category,
    String? caseId,
    String? notes,
  });
  Future<List<MedicalFile>> getFilesForCase(String caseId);
  Future<List<MedicalFile>> getAllFiles();
  Future<void> deleteFile(String fileId);
}
