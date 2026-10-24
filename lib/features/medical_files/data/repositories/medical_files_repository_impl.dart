import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/medical_file_entity.dart';
import '../../domain/repositories/medical_files_repository.dart';

class MedicalFilesRepositoryImpl implements MedicalFilesRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final List<MedicalFile> _mockFiles = List<MedicalFile>.from(_defaultMockFiles);

  MedicalFilesRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<MedicalFile> uploadFile({
    required String filePath,
    required String fileName,
    required FileCategory category,
    String? caseId,
    String? notes,
  }) async {
    final fileSize = File(filePath).existsSync()
        ? File(filePath).lengthSync()
        : 256000;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final file = MedicalFile(
      id: id,
      originalName: fileName,
      fileName: fileName,
      mimeType: _getMimeType(fileName),
      size: fileSize,
      category: category,
      fileUrl: filePath,
      uploadedBy: _uid ?? 'current_user',
      uploadedAt: DateTime.now(),
      caseId: caseId,
      notes: notes,
    );

    // Firestore'a kaydet (fire-and-forget)
    try {
      await _db.collection('medical_files').doc(id).set({
        'originalName': fileName,
        'fileName': fileName,
        'mimeType': file.mimeType,
        'size': fileSize,
        'category': category.name,
        'fileUrl': filePath,
        'uploadedBy': _uid,
        'uploadedAt': FieldValue.serverTimestamp(),
        'caseId': caseId,
        'notes': notes,
      }).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[MEDICAL_FILES] Firestore write failed, local only: $e');
    }

    _mockFiles.insert(0, file);
    return file;
  }

  @override
  Future<List<MedicalFile>> getFilesForCase(String caseId) async {
    try {
      final snap = await _db
          .collection('medical_files')
          .where('caseId', isEqualTo: caseId)
          .orderBy('uploadedAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 3));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => _fromFirestore(d)).toList();
      }
    } catch (e) {
      debugPrint('[MEDICAL_FILES] Firestore read failed, using mock: $e');
    }
    return _mockFiles
        .where((f) => f.caseId == caseId || f.caseId == null)
        .toList();
  }

  @override
  Future<List<MedicalFile>> getAllFiles() async {
    try {
      final snap = await _db
          .collection('medical_files')
          .orderBy('uploadedAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 3));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => _fromFirestore(d)).toList();
      }
    } catch (e) {
      debugPrint('[MEDICAL_FILES] Firestore read failed, using mock: $e');
    }
    return List<MedicalFile>.from(_mockFiles);
  }

  @override
  Future<void> deleteFile(String fileId) async {
    try {
      await _db.collection('medical_files').doc(fileId).delete()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[MEDICAL_FILES] Firestore delete failed: $e');
    }
    _mockFiles.removeWhere((f) => f.id == fileId);
  }

  MedicalFile _fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MedicalFile(
      id: doc.id,
      originalName: d['originalName'] as String? ?? '',
      fileName: d['fileName'] as String? ?? '',
      mimeType: d['mimeType'] as String? ?? 'application/octet-stream',
      size: (d['size'] as num?)?.toInt() ?? 0,
      category: _parseCategory(d['category'] as String?),
      fileUrl: d['fileUrl'] as String? ?? '',
      uploadedBy: d['uploadedBy'] as String? ?? '',
      uploadedAt: (d['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      caseId: d['caseId'] as String?,
      notes: d['notes'] as String?,
      width: (d['width'] as num?)?.toInt(),
      height: (d['height'] as num?)?.toInt(),
    );
  }

  FileCategory _parseCategory(String? cat) {
    switch (cat) {
      case 'labResult': return FileCategory.labResult;
      case 'xray': return FileCategory.xray;
      case 'ct': return FileCategory.ct;
      case 'mri': return FileCategory.mri;
      case 'ecg': return FileCategory.ecg;
      case 'ultrasound': return FileCategory.ultrasound;
      case 'pathology': return FileCategory.pathology;
      default: return FileCategory.other;
    }
  }

  String _getMimeType(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'dcm':
        return 'application/dicom';
      default:
        return 'application/octet-stream';
    }
  }
}

final _defaultMockFiles = <MedicalFile>[
  MedicalFile(
    id: 'mock_1',
    originalName: 'tam_kan_sayimi.pdf',
    fileName: 'tam_kan_sayimi.pdf',
    mimeType: 'application/pdf',
    size: 245760,
    category: FileCategory.labResult,
    fileUrl: '',
    uploadedBy: 'Dr. Ayse',
    uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
    notes: 'WBC: 12.500, Hgb: 11.2, PLT: 245.000',
    caseId: 'KX-2024-0045',
  ),
  MedicalFile(
    id: 'mock_2',
    originalName: 'akciger_pa.jpg',
    fileName: 'akciger_pa.jpg',
    mimeType: 'image/jpeg',
    size: 1536000,
    category: FileCategory.xray,
    fileUrl: '',
    width: 2048,
    height: 2048,
    uploadedBy: 'Dr. Mehmet',
    uploadedAt: DateTime.now().subtract(const Duration(hours: 5)),
    notes: 'PA Akciger grafisi — bilateral infiltrasyon',
    caseId: 'KX-2024-0045',
  ),
  MedicalFile(
    id: 'mock_3',
    originalName: 'beyin_bt.jpg',
    fileName: 'beyin_bt.jpg',
    mimeType: 'image/jpeg',
    size: 3072000,
    category: FileCategory.ct,
    fileUrl: '',
    width: 512,
    height: 512,
    uploadedBy: 'Dr. Fatma',
    uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
    notes: 'Kontrastsiz kranial BT — normal',
    caseId: 'KX-2024-0046',
  ),
  MedicalFile(
    id: 'mock_4',
    originalName: 'lomber_mr.jpg',
    fileName: 'lomber_mr.jpg',
    mimeType: 'image/jpeg',
    size: 4096000,
    category: FileCategory.mri,
    fileUrl: '',
    width: 768,
    height: 768,
    uploadedBy: 'Dr. Ali',
    uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    notes: 'L4-L5 disk hernisi, posterior protruzyon',
  ),
  MedicalFile(
    id: 'mock_5',
    originalName: 'ekg_12_derivasyon.jpg',
    fileName: 'ekg_12_derivasyon.jpg',
    mimeType: 'image/jpeg',
    size: 512000,
    category: FileCategory.ecg,
    fileUrl: '',
    width: 3000,
    height: 1500,
    uploadedBy: 'Dr. Kerem',
    uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
    notes: 'ST elevasyonu V1-V4, anterior STEMI',
  ),
  MedicalFile(
    id: 'mock_6',
    originalName: 'abdominal_usg.jpg',
    fileName: 'abdominal_usg.jpg',
    mimeType: 'image/jpeg',
    size: 768000,
    category: FileCategory.ultrasound,
    fileUrl: '',
    width: 1024,
    height: 768,
    uploadedBy: 'Dr. Selin',
    uploadedAt: DateTime.now().subtract(const Duration(days: 4)),
    notes: 'Safra kesesi — multipl kalkul',
  ),
];
