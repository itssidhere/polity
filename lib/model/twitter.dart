import 'package:polity/model/post.dart';

class Tweets extends Post {
  late String uid;
  late String content;
  late DateTime date;
  late Sentiment sentiment;
  late String url;

  Tweets(
      {required this.uid,
      required this.content,
      required this.date,
      required this.sentiment,
      required this.url});

  factory Tweets.fromJson(Map<String, dynamic> json) {
    var uid = json['uid'] ?? '';
    return Tweets(
      uid: uid,
      content: json['tweet'] as String,
      date: DateTime.parse(json['date'] as String),
      sentiment: Sentiment.fromJson(json['sentiment'] as Map<String, dynamic>),
      url: 'https://twitter.com/${uid}',
    );
  }
}
