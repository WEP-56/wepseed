/// One visit recorded by the in-app browser.
class WebHistoryItem {
  const WebHistoryItem({
    required this.url,
    required this.title,
    required this.visitedAt,
  });

  final String url;
  final String title;
  final DateTime visitedAt;

  WebHistoryItem copyWith({String? title, DateTime? visitedAt}) =>
      WebHistoryItem(
        url: url,
        title: title ?? this.title,
        visitedAt: visitedAt ?? this.visitedAt,
      );

  Map<String, dynamic> toJson() => {
    'url': url,
    'title': title,
    'visitedAt': visitedAt.toIso8601String(),
  };

  factory WebHistoryItem.fromJson(Map<String, dynamic> json) => WebHistoryItem(
    url: json['url'] as String? ?? '',
    title: json['title'] as String? ?? '',
    visitedAt:
        DateTime.tryParse(json['visitedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
