part of 'medical_files_bloc.dart';

abstract class MedicalFilesState extends Equatable {
  const MedicalFilesState();

  @override
  List<Object?> get props => [];
}

class MedicalFilesInitial extends MedicalFilesState {}

class MedicalFilesLoading extends MedicalFilesState {}

class MedicalFilesLoaded extends MedicalFilesState {
  final List<MedicalFile> allFiles;
  final List<MedicalFile> filteredFiles;
  final FileCategory? activeFilter;

  /// Map of fileId -> AI analysis result (null = not analyzed yet)
  final Map<String, MedicalImageAnalysis> aiAnalyses;

  /// File IDs currently being analyzed by AI
  final Set<String> analyzingFileIds;

  const MedicalFilesLoaded({
    required this.allFiles,
    required this.filteredFiles,
    this.activeFilter,
    this.aiAnalyses = const {},
    this.analyzingFileIds = const {},
  });

  MedicalFilesLoaded copyWith({
    List<MedicalFile>? allFiles,
    List<MedicalFile>? filteredFiles,
    FileCategory? activeFilter,
    Map<String, MedicalImageAnalysis>? aiAnalyses,
    Set<String>? analyzingFileIds,
    bool clearFilter = false,
  }) {
    return MedicalFilesLoaded(
      allFiles: allFiles ?? this.allFiles,
      filteredFiles: filteredFiles ?? this.filteredFiles,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      aiAnalyses: aiAnalyses ?? this.aiAnalyses,
      analyzingFileIds: analyzingFileIds ?? this.analyzingFileIds,
    );
  }

  @override
  List<Object?> get props => [allFiles, filteredFiles, activeFilter, aiAnalyses, analyzingFileIds];
}

class MedicalFilesError extends MedicalFilesState {
  final String message;
  const MedicalFilesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FileUploading extends MedicalFilesState {
  final double progress;
  final String? fileName;
  final int currentFile;
  final int totalFiles;

  const FileUploading({
    this.progress = 0.0,
    this.fileName,
    this.currentFile = 1,
    this.totalFiles = 1,
  });

  @override
  List<Object?> get props => [progress, fileName, currentFile, totalFiles];
}

class FileUploaded extends MedicalFilesState {
  final MedicalFile file;
  const FileUploaded(this.file);

  @override
  List<Object?> get props => [file];
}

class UploadCancelled extends MedicalFilesState {
  const UploadCancelled();
}
