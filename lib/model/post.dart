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
      negative: double.parse((negative.toStringAsFixed(2))),
      neutral: neutral as double,
      positive: double.parse((positive.toStringAsFixed(2))),
    );
  }
}

abstract class Post {
  late String uid;
  late String content;
  late DateTime date;
  late Sentiment sentiment;
  late String url;
}
