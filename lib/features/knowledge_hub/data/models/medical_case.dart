import 'package:flutter/foundation.dart';

enum CaseStatus { active, solved, ex }

class MedicalCase {
  final String id;
  final String title;
  final String description;
  final Author author;
  final List<String> documentUrls;
  final List<String> tags;
  final CaseStatus status;
  final int upvotes;
  final int commentCount;
  final int views;
  final DateTime createdAt;
  final List<CaseComment> comments;

  MedicalCase({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.documentUrls,
    required this.tags,
    required this.status,
    required this.upvotes,
    required this.commentCount,
    required this.views,
    required this.createdAt,
    this.comments = const [],
  });
}

class Author {
  final String id;
  final String name;
  final String avatarUrl;
  final String role; // e.g. "Neurologist", "Medical Student"
  final String level; // e.g. "Grandmaster", "Expert"
  final int reputation;

  Author({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.level,
    required this.reputation,
  });
}

class CaseComment {
  final String id;
  final Author author;
  final String text;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final int upvotes;

  CaseComment({
    required this.id,
    required this.author,
    required this.text,
    this.attachmentUrls = const [],
    required this.createdAt,
    required this.upvotes,
  });
}
