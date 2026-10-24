import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/claude_ai_service.dart';
import '../../domain/entities/medical_file_entity.dart';
import '../../domain/entities/medical_image_analysis.dart';
import '../../domain/repositories/medical_files_repository.dart';

part 'medical_files_event.dart';
part 'medical_files_state.dart';

class MedicalFilesBloc extends Bloc<MedicalFilesEvent, MedicalFilesState> {
  final MedicalFilesRepository repository;
  final ClaudeAIService? aiService;

  MedicalFilesBloc({
    required this.repository,
    this.aiService,
  }) : super(MedicalFilesInitial()) {
    on<LoadFilesEvent>(_onLoadFiles);
    on<UploadFileEvent>(_onUploadFile);
    on<UploadMultipleFilesEvent>(_onUploadMultipleFiles);
    on<DeleteFileEvent>(_onDeleteFile);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<AnalyzeFileWithAIEvent>(_onAnalyzeFileWithAI);
    on<CancelUploadEvent>(_onCancelUpload);
  }

  List<MedicalFile> _allFiles = [];
  FileCategory? _activeFilter;
  Map<String, MedicalImageAnalysis> _aiAnalyses = {};
  Set<String> _analyzingFileIds = {};
  bool _uploadCancelled = false;

  Future<void> _onLoadFiles(
    LoadFilesEvent event,
    Emitter<MedicalFilesState> emit,
  ) async {
    emit(MedicalFilesLoading());
    try {
      if (event.caseId != null) {
        _allFiles = await repository.getFilesForCase(event.caseId!);
      } else {
        _allFiles = await repository.getAllFiles();
      }
      _activeFilter = null;
      emit(MedicalFilesLoaded(
        allFiles: _allFiles,
        filteredFiles: _allFiles,
        activeFilter: null,
        aiAnalyses: _aiAnalyses,
        analyzingFileIds: _analyzingFileIds,
      ));
    } catch (e) {
      emit(MedicalFilesError('Dosyalar yuklenemedi: $e'));
    }
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<MedicalFilesState> emit,
  ) async {
    _uploadCancelled = false;
    emit(FileUploading(progress: 0.0, fileName: event.fileName));
    try {
      emit(FileUploading(progress: 0.3, fileName: event.fileName));
      if (_uploadCancelled) {
        emit(const UploadCancelled());
        return;
      }

      final file = await repository.uploadFile(
        filePath: event.filePath,
        fileName: event.fileName,
        category: event.category,
        caseId: event.caseId,
        notes: event.notes,
      );

      if (_uploadCancelled) {
        emit(const UploadCancelled());
        return;
      }

      emit(FileUploading(progress: 1.0, fileName: event.fileName));
      emit(FileUploaded(file));

      // Reload files
      _allFiles = await repository.getAllFiles();
      final filtered = _activeFilter != null
          ? _allFiles.where((f) => f.category == _activeFilter).toList()
          : _allFiles;
      emit(MedicalFilesLoaded(
        allFiles: _allFiles,
        filteredFiles: filtered,
        activeFilter: _activeFilter,
        aiAnalyses: _aiAnalyses,
        analyzingFileIds: _analyzingFileIds,
      ));

      // Auto-trigger AI analysis for image files
      if (file.isImage && aiService != null) {
        add(AnalyzeFileWithAIEvent(
          fileId: file.id,
          filePath: event.filePath,
          mimeType: file.mimeType,
        ));
      }
    } catch (e) {
      emit(MedicalFilesError('Dosya yuklenemedi: $e'));
    }
  }

  Future<void> _onUploadMultipleFiles(
    UploadMultipleFilesEvent event,
    Emitter<MedicalFilesState> emit,
  ) async {
    _uploadCancelled = false;
    final total = event.filePaths.length;
    final uploadedFiles = <MedicalFile>[];

    for (int i = 0; i < total; i++) {
      if (_uploadCancelled) {
        emit(const UploadCancelled());
        return;
      }

      final progress = (i + 0.5) / total;
      emit(FileUploading(
        progress: progress,
        fileName: event.fileNames[i],
        currentFile: i + 1,
        totalFiles: total,
      ));

      try {
        final file = await repository.uploadFile(
          filePath: event.filePaths[i],
          fileName: event.fileNames[i],
          category: event.category,
          caseId: event.caseId,
        );
        uploadedFiles.add(file);
      } catch (e) {
        // Continue uploading remaining files
      }
    }

    // Reload all files
    _allFiles = await repository.getAllFiles();
    final filtered = _activeFilter != null
        ? _allFiles.where((f) => f.category == _activeFilter).toList()
        : _allFiles;
    emit(MedicalFilesLoaded(
      allFiles: _allFiles,
      filteredFiles: filtered,
      activeFilter: _activeFilter,
      aiAnalyses: _aiAnalyses,
      analyzingFileIds: _analyzingFileIds,
    ));

    // Auto-trigger AI analysis for uploaded image files
    if (aiService != null) {
      for (int i = 0; i < uploadedFiles.length; i++) {
        final file = uploadedFiles[i];
        if (file.isImage && i < event.filePaths.length) {
          add(AnalyzeFileWithAIEvent(
            fileId: file.id,
            filePath: event.filePaths[i],
            mimeType: file.mimeType,
          ));
        }
      }
    }
  }

  Future<void> _onDeleteFile(
    DeleteFileEvent event,
    Emitter<MedicalFilesState> emit,
  ) async {
    try {
      await repository.deleteFile(event.fileId);
      _allFiles = await repository.getAllFiles();
      _aiAnalyses.remove(event.fileId);
      _analyzingFileIds.remove(event.fileId);
      final filtered = _activeFilter != null
          ? _allFiles.where((f) => f.category == _activeFilter).toList()
          : _allFiles;
      emit(MedicalFilesLoaded(
        allFiles: _allFiles,
        filteredFiles: filtered,
        activeFilter: _activeFilter,
        aiAnalyses: Map.of(_aiAnalyses),
        analyzingFileIds: Set.of(_analyzingFileIds),
      ));
    } catch (e) {
      emit(MedicalFilesError('Dosya silinemedi: $e'));
    }
  }

  void _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<MedicalFilesState> emit,
  ) {
    _activeFilter = event.category;
    final filtered = event.category != null
        ? _allFiles.where((f) => f.category == event.category).toList()
        : _allFiles;
    emit(MedicalFilesLoaded(
      allFiles: _allFiles,
      filteredFiles: filtered,
      activeFilter: event.category,
      aiAnalyses: _aiAnalyses,
      analyzingFileIds: _analyzingFileIds,
    ));
  }

  Future<void> _onAnalyzeFileWithAI(
    AnalyzeFileWithAIEvent event,
    Emitter<MedicalFilesState> emit,
  ) async {
    if (aiService == null) return;

    // Mark file as being analyzed
    _analyzingFileIds = Set.of(_analyzingFileIds)..add(event.fileId);
    if (state is MedicalFilesLoaded) {
      final loaded = state as MedicalFilesLoaded;
      emit(loaded.copyWith(analyzingFileIds: _analyzingFileIds));
    }

    try {
      // Read file and convert to base64
      final file = File(event.filePath);
      if (!await file.exists()) {
        _analyzingFileIds = Set.of(_analyzingFileIds)..remove(event.fileId);
        return;
      }

      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);

      // Perform AI analysis
      final analysis = await aiService!.analyzeMedicalImage(
        base64Data,
        event.mimeType,
      );

      // Store result and update state
      _aiAnalyses = Map.of(_aiAnalyses)..[event.fileId] = analysis;
      _analyzingFileIds = Set.of(_analyzingFileIds)..remove(event.fileId);

      if (state is MedicalFilesLoaded) {
        final loaded = state as MedicalFilesLoaded;
        emit(loaded.copyWith(
          aiAnalyses: _aiAnalyses,
          analyzingFileIds: _analyzingFileIds,
        ));
      }
    } catch (e) {
      _analyzingFileIds = Set.of(_analyzingFileIds)..remove(event.fileId);
      if (state is MedicalFilesLoaded) {
        final loaded = state as MedicalFilesLoaded;
        emit(loaded.copyWith(analyzingFileIds: _analyzingFileIds));
      }
    }
  }

  void _onCancelUpload(
    CancelUploadEvent event,
    Emitter<MedicalFilesState> emit,
  ) {
    _uploadCancelled = true;
  }
}
