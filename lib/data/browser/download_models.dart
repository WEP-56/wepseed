/// Browser / in-app download record.
enum DownloadStatus { downloading, completed, failed }

class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.savePath,
    required this.createdAt,
    this.fileSize = 0,
    this.status = DownloadStatus.downloading,
    this.progress = 0,
    this.mimeType,
  });

  final String id;
  final String url;
  final String fileName;
  final String savePath;
  final int fileSize;
  final DateTime createdAt;
  final DownloadStatus status;
  final double progress;
  final String? mimeType;

  DownloadItem copyWith({
    String? fileName,
    String? savePath,
    int? fileSize,
    DownloadStatus? status,
    double? progress,
    String? mimeType,
  }) {
    return DownloadItem(
      id: id,
      url: url,
      fileName: fileName ?? this.fileName,
      savePath: savePath ?? this.savePath,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'fileName': fileName,
    'savePath': savePath,
    'fileSize': fileSize,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'progress': progress,
    'mimeType': mimeType,
  };

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'file',
      savePath: json['savePath'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.failed,
      ),
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      mimeType: json['mimeType'] as String?,
    );
  }
}
