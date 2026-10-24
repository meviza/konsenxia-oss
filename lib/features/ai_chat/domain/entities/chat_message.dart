import 'package:equatable/equatable.dart';

/// Represents a file attachment in a chat message.
class ChatAttachment extends Equatable {
  final String fileName;
  final String filePath;
  final int fileSize;
  final String extension;
  /// Base64-encoded file content (for images)
  final String? base64Content;
  /// Extracted text content (for PDFs/text files)
  final String? textContent;

  const ChatAttachment({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.extension,
    this.base64Content,
    this.textContent,
  });

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension.toLowerCase());
  bool get isPdf => extension.toLowerCase() == 'pdf';

  String get mimeType {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'image/jpeg';
    }
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'fileSize': fileSize,
    'extension': extension,
  };

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      fileName: json['fileName'] ?? '',
      filePath: '',
      fileSize: json['fileSize'] ?? 0,
      extension: json['extension'] ?? '',
    );
  }

  @override
  List<Object?> get props => [fileName, filePath, fileSize, extension];
}

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final double? confidence;
  final String? category;
  final Map<String, dynamic>? metadata;
  final bool hasAttachments;
  final List<String> attachmentNames;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.confidence,
    this.category,
    this.metadata,
    this.hasAttachments = false,
    this.attachmentNames = const [],
  });

  @override
  List<Object?> get props => [
        id,
        text,
        isUser,
        timestamp,
        suggestions,
        confidence,
        category,
        metadata,
        hasAttachments,
        attachmentNames,
      ];

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<String>? suggestions,
    double? confidence,
    String? category,
    Map<String, dynamic>? metadata,
    bool? hasAttachments,
    List<String>? attachmentNames,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      suggestions: suggestions ?? this.suggestions,
      confidence: confidence ?? this.confidence,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      attachmentNames: attachmentNames ?? this.attachmentNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'suggestions': suggestions,
      'confidence': confidence,
      'category': category,
      'metadata': metadata,
      'hasAttachments': hasAttachments,
      'attachmentNames': attachmentNames,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      suggestions: json['suggestions']?.cast<String>(),
      confidence: json['confidence']?.toDouble(),
      category: json['category'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      hasAttachments: json['hasAttachments'] ?? false,
      attachmentNames: json['attachmentNames'] != null
          ? List<String>.from(json['attachmentNames'])
          : const [],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'hasAttachments': hasAttachments,
      'attachmentNames': attachmentNames,
    };
  }

  /// Create from Firestore document
  factory ChatMessage.fromFirestore(String docId, Map<String, dynamic> data) {
    return ChatMessage(
      id: docId,
      text: data['text'] ?? '',
      isUser: data['role'] == 'user',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      hasAttachments: data['hasAttachments'] ?? false,
      attachmentNames: data['attachmentNames'] != null
          ? List<String>.from(data['attachmentNames'])
          : const [],
    );
  }
}

class AIResponse extends Equatable {
  final String text;
  final List<String> suggestions;
  final double confidence;
  final String category;
  final Map<String, dynamic> metadata;

  const AIResponse({
    required this.text,
    required this.suggestions,
    required this.confidence,
    required this.category,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        text,
        suggestions,
        confidence,
        category,
        metadata,
      ];

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'suggestions': suggestions,
      'confidence': confidence,
      'category': category,
      'metadata': metadata,
    };
  }

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      text: json['text'],
      suggestions: (json['suggestions'] as List<dynamic>).cast<String>(),
      confidence: json['confidence'].toDouble(),
      category: json['category'],
      metadata: json['metadata'],
    );
  }
}
