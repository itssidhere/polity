import 'package:polity/model/post.dart';

class Reddits extends Post {
  late String uid;
  late String content;
  late DateTime date;
  late Sentiment sentiment;
  late String url;

  Reddits(
      {required this.uid,
      required this.content,
      required this.date,
      required this.sentiment,
      required this.url});

  factory Reddits.fromJson(Map<String, dynamic> json) {
    return Reddits(
      uid: json['uid'] ?? '',
      content: json['body'] as String,
      date: DateTime.parse(json['date'] as String),
      sentiment: Sentiment.fromJson(json['sentiment'] as Map<String, dynamic>),
      url: json['url'] as String,
    );
  }
}
