/// Saved page from the in-app browser.
class WebBookmark {
  const WebBookmark({
    required this.url,
    required this.title,
    required this.createdAt,
  });

  final String url;
  final String title;
  final DateTime createdAt;

  WebBookmark copyWith({String? title}) => WebBookmark(
    url: url,
    title: title ?? this.title,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'url': url,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WebBookmark.fromJson(Map<String, dynamic> json) => WebBookmark(
    url: json['url'] as String? ?? '',
    title: json['title'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
