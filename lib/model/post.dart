class Sentiment {
  late double negative;
  late double neutral;
  late double positive;

  Sentiment(
      {required this.negative, required this.neutral, required this.positive});

  factory Sentiment.fromJson(Map<String, dynamic> json) {
    final negative = json['negative'] ?? 0.0;
    final neutral = json['neutral'] ?? 0.0;
    final positive = json['positive'] ?? 0.0;
    return Sentiment(
      negative: negative as double,
      neutral: neutral as double,
      positive: positive as double,
    );
  }
}

abstract class Post {
  late String userid;
  late String content;
  late DateTime date;
  late Sentiment sentiment;
}
