part of 'medical_files_bloc.dart';

abstract class MedicalFilesEvent extends Equatable {
  const MedicalFilesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFilesEvent extends MedicalFilesEvent {
  final String? caseId;
  const LoadFilesEvent({this.caseId});

  @override
  List<Object?> get props => [caseId];
}

class UploadFileEvent extends MedicalFilesEvent {
  final String filePath;
  final String fileName;
  final FileCategory category;
  final String? caseId;
  final String? notes;

  const UploadFileEvent({
    required this.filePath,
    required this.fileName,
    required this.category,
    this.caseId,
    this.notes,
  });

  @override
  List<Object?> get props => [filePath, fileName, category, caseId, notes];
}

/// Multi-file upload event (drag & drop or multi-select)
class UploadMultipleFilesEvent extends MedicalFilesEvent {
  final List<String> filePaths;
  final List<String> fileNames;
  final FileCategory category;
  final String? caseId;

  const UploadMultipleFilesEvent({
    required this.filePaths,
    required this.fileNames,
    required this.category,
    this.caseId,
  });

  @override
  List<Object?> get props => [filePaths, fileNames, category, caseId];
}

class DeleteFileEvent extends MedicalFilesEvent {
  final String fileId;
  const DeleteFileEvent(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

class FilterByCategoryEvent extends MedicalFilesEvent {
  final FileCategory? category;
  const FilterByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Trigger AI medical image analysis for a specific file
class AnalyzeFileWithAIEvent extends MedicalFilesEvent {
  final String fileId;
  final String filePath;
  final String mimeType;

  const AnalyzeFileWithAIEvent({
    required this.fileId,
    required this.filePath,
    required this.mimeType,
  });

  @override
  List<Object?> get props => [fileId, filePath, mimeType];
}

/// Cancel an ongoing upload
class CancelUploadEvent extends MedicalFilesEvent {
  const CancelUploadEvent();
}
