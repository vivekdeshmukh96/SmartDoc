enum DocumentStatus {
  pending,
  approved,
  rejected,
  resubmission, // Added for more detailed flow
}

class Document {
  final String id;
  final String name;
  final String category;
  final String fileType;
  final DocumentStatus status;
  final String uploadedByUserId;
  final String uploadedDate;
  final String? verifiedByUserId;
  final String? verificationDate;
  final String? comments;
  final String? downloadUrl;

  Document({
    required this.id,
    required this.name,
    required this.category,
    required this.fileType,
    this.status = DocumentStatus.pending,
    required this.uploadedByUserId,
    required this.uploadedDate,
    this.verifiedByUserId,
    this.verificationDate,
    this.comments,
    this.downloadUrl,
  });

  factory Document.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Document(
      id: documentId,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      fileType: data['fileType'] ?? '',
      status: DocumentStatus.values.firstWhere(
            (e) => e.toString() == 'DocumentStatus.${data['status']}',
        orElse: () => DocumentStatus.pending,
      ),
      uploadedByUserId: data['uploadedByUserId'] ?? '',
      uploadedDate: data['uploadedDate'] ?? '',
      verifiedByUserId: data['verifiedByUserId'],
      verificationDate: data['verificationDate'],
      comments: data['comments'],
      downloadUrl: data['downloadUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'fileType': fileType,
      'status': status.name,
      'uploadedByUserId': uploadedByUserId,
      'uploadedDate': uploadedDate,
      'verifiedByUserId': verifiedByUserId,
      'verificationDate': verificationDate,
      'comments': comments,
      'downloadUrl': downloadUrl,
    };
  }

  Document copyWith({
    String? id,
    String? name,
    String? category,
    String? fileType,
    DocumentStatus? status,
    String? uploadedByUserId,
    String? uploadedDate,
    String? verifiedByUserId,
    String? verificationDate,
    String? comments,
    String? downloadUrl,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      fileType: fileType ?? this.fileType,
      status: status ?? this.status,
      uploadedByUserId: uploadedByUserId ?? this.uploadedByUserId,
      uploadedDate: uploadedDate ?? this.uploadedDate,
      verifiedByUserId: verifiedByUserId ?? this.verifiedByUserId,
      verificationDate: verificationDate ?? this.verificationDate,
      comments: comments ?? this.comments,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }
}