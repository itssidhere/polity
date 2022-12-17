import 'package:polity/model/post.dart';

class Tweets extends Post {
  late String uid;
  late String content;
  late DateTime date;
  late Sentiment sentiment;

  Tweets(
      {required this.uid,
      required this.content,
      required this.date,
      required this.sentiment});

  factory Tweets.fromJson(Map<String, dynamic> json) {
    return Tweets(
      uid: json['uid'] as String,
      content: json['tweet'] as String,
      date: DateTime.parse(json['date'] as String),
      sentiment: Sentiment.fromJson(json['sentiment'] as Map<String, dynamic>),
    );
  }
}
