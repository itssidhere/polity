import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:polity/model/post.dart';
import 'package:polity/model/reddit.dart';
import 'package:polity/model/twitter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BarChartData {
  BarChartData(this.x, this.y);
  final String x;
  final int y;
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  var tableData = <Post>[];
  var order_map = <int, int>{};
  // one week old timestamp
  var from = DateTime.now().subtract(const Duration(days: 7));
  var to = DateTime.now();
  var selected_social = 'reddit';
  var input_keywords = <String>['elon musk', 'tesla', 'bitcoin'];
  var total_negative = 0;
  var total_positive = 0;
  var scrollController = ScrollController();
  var loading = false.obs;

  Map<DateTime, int> negative_line = <DateTime, int>{};
  Map<DateTime, int> positive_line = <DateTime, int>{};

  var negativeChartData = <BarChartData>[];
  var positiveChartData = <BarChartData>[];
  @override
  void initState() {
    loadAsset(keyword: input_keywords[0]);
    super.initState();
  }

  Future<List<Post>> getDataFromAPI(
      {required String keyword, int limit = 20}) async {
    //add second argument to the url limit to 1000

    var data = <Post>[];
    if (selected_social == "twitter") {
      var url = 'http://127.0.0.1:5000/twitter?query=${keyword}&limit=${limit}';
      var response = await Dio().get(url);

      for (var i = 0; i < response.data['tweets'].length; i++) {
        data.add(Tweets.fromJson(response.data['tweets'][i]));
      }
    } else {
      var url = 'http://127.0.0.1:5000/reddit?query=${keyword}&limit=${limit}';
      var response = await Dio().get(url);

      for (var i = 0; i < response.data['reddits'].length; i++) {
        data.add(Reddits.fromJson(response.data['reddits'][i]));
      }
    }

    return data;
  }

  Future<void> loadAsset({String keyword = 'elon musk'}) async {
    //load the json file
    loading.value = true;
    tableData = await getDataFromAPI(keyword: keyword);
    loading.value = false;

    setState(() {
      tableData.sort((a, b) => b.date.compareTo(a.date));
    });

    //drop the first element of each of the sublist
    for (var element in tableData) {
      if (element.sentiment.negative > element.sentiment.positive) {
        total_negative += 1;
      } else {
        total_positive += 1;
      }
    }

    for (var i = 0; i < 5; i++) {
      int randomNegative = Random().nextInt(100) + 1;
      int randomPositive = Random().nextInt(100) + 1;

      var randomKeyword = 'keyword $i';

      negativeChartData
          .add(BarChartData('Negative ' + randomKeyword, randomNegative));
      positiveChartData
          .add(BarChartData('Positive ' + randomKeyword, randomPositive));
    }

    negative_line.clear();
    positive_line.clear();

    // get all the dates from from to to range and set them to 0 in negative_line and positive_line
    var date = from;
    while (date.isBefore(to)) {
      var d = DateTime(date.year, date.month, date.day);
      negative_line[d] = 0;
      positive_line[d] = 0;
      date = date.add(const Duration(days: 1));
    }

    // fill negative_line and positive_line

    for (var i = 0; i < tableData.length; i++) {
      var d = tableData[i].date;
      var date = DateTime(d.year, d.month, d.day);
      var sentiment = tableData[i].sentiment;

      if (sentiment.negative > sentiment.positive) {
        negative_line[date] = (negative_line[date] ?? 0) + 1;
        positive_line[date] = (positive_line[date] ?? 0);
      } else {
        positive_line[date] = (positive_line[date] ?? 0) + 1;
        negative_line[date] = (negative_line[date] ?? 0);
      }
    }

    setState(() {
      for (var i = 0; i < 4; i++) {
        order_map[i] = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //create a flutter table
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.50,
              width: MediaQuery.of(context).size.width,
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      'POLITY IQ',
                      style: Get.textTheme.headlineMedium!
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        "Welcome to Polity IQ. Polity's proprietary AI sentiment analysis engine will help you understand the public's opinion on a topic of your choice. Use Polity IQ to run a modern, smarter, and more efficient campaign.",
                        style: Get.textTheme.titleMedium!
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),
                    //learn more button
                    ElevatedButton(
                      onPressed: () async {},
                      child: const Text('Methodology and FAQ'),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Text(
                        'You are currently viewing the data from twitter for the last ${to.difference(from).inDays} days',
                        style: Get.textTheme.bodyText1!
                            .copyWith(color: Colors.white)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //show drop down menu for social media
                        DropdownButton<String>(
                          value: selected_social.toUpperCase(),
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style:
                              const TextStyle(color: Colors.deepPurpleAccent),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selected_social = newValue.toLowerCase();
                              });
                            }
                          },
                          items: <String>[
                            'Twitter'.toUpperCase(),
                            'Facebook'.toUpperCase(),
                            'Instagram'.toUpperCase(),
                            'Reddit'.toUpperCase()
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          width: 20,
                        ),

                        //from date picker
                        TextButton(
                          onPressed: () async {
                            //show date picker
                            var date = await showDatePicker(
                                context: context,
                                initialDate: from,
                                firstDate: DateTime(2020),
                                lastDate: to.subtract(const Duration(days: 7)));

                            if (date != null) {
                              setState(() {
                                from = date;
                              });
                            }
                          },
                          child: Text(DateFormat.yMMMMEEEEd().format(from)),
                        ),
                        //show a white dash between the two dates
                        Text(
                          ' - ',
                          style: Get.textTheme.headlineLarge!
                              .copyWith(color: Colors.white),
                        ),
                        //to date picker
                        TextButton(
                          onPressed: () async {
                            //show date picker
                            var date = await showDatePicker(
                                context: context,
                                initialDate: to,
                                firstDate: DateTime(2022),
                                lastDate: DateTime.now());
                            if (date != null) {
                              if (date.difference(from) >=
                                  const Duration(days: 7)) {
                                setState(() {
                                  to = date;
                                });
                              } else {
                                Get.snackbar('Error',
                                    'The date range should be atleast 7 days');
                              }
                            }
                          },
                          child: Text(DateFormat.yMMMMEEEEd().format(to)),
                        ),
                      ],
                    ),

                    SizedBox(
                      width: Get.width * 0.5,
                      child: Row(children: <Widget>[
                        const Expanded(
                            child: const Divider(
                          color: Colors.white54,
                        )),
                        Text("HISTORY", style: TextStyle(color: Colors.white)),
                        Expanded(
                            child: Divider(
                          color: Colors.white54,
                        )),
                      ]),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //show chips of the keywords with a delete button
                    Container(
                      height: 50,
                      child: Wrap(
                        spacing: 8.0,
                        children: [
                          for (var keyword in input_keywords)
                            Chip(
                              label: Text(keyword),
                              deleteButtonTooltipMessage: 'Search Again',
                              deleteIcon: const Icon(Icons.history),
                              onDeleted: () {
                                setState(() {
                                  loadAsset(keyword: keyword);
                                });
                              },
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //show a search bar
            Container(
              padding: const EdgeInsets.all(8.0),
              width: Get.width * 0.3,
              child: TextField(
                onSubmitted: (value) {
                  setState(() {
                    loadAsset(keyword: value);
                    input_keywords.add(value);
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      selected_social == 'twitter'
                          ? FontAwesomeIcons.twitter
                          : selected_social == 'facebook'
                              ? FontAwesomeIcons.facebook
                              : selected_social == 'instagram'
                                  ? FontAwesomeIcons.instagram
                                  : FontAwesomeIcons.reddit,
                    ),
                    suffixIcon: Icon(Icons.search),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    hintText: 'Search a candidate, issue, policy or topic'),
              ),
            ),

            SizedBox(
              height: 20,
            ),
            Obx(
              () => loading.value ? CircularProgressIndicator() : Container(),
            ),
            //show a sf pie chart with positive, negative sentiments
            SfCircularChart(
              title: ChartTitle(
                  text: 'Distribution of Sentiments',
                  textStyle: Get.textTheme.titleMedium!
                      .copyWith(decoration: TextDecoration.underline)),
              margin: const EdgeInsets.all(10),
              legend: Legend(
                  isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                PieSeries<Map, String>(
                    dataSource: [
                      {'Positive': total_positive},
                      {'Negative': total_negative},
                    ],
                    xValueMapper: (Map sentiment, _) => sentiment.keys.first,
                    yValueMapper: (Map sentiment, _) => sentiment.values.first,
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside))
              ],
            ),
            const SizedBox(
              height: 20,
            ),

            //show a sf line chart using negative_line and positive_line

            SfCartesianChart(
              title: ChartTitle(
                  text: 'Sentiment Trend over time ( Double tap to zoom )',
                  textStyle: Get.textTheme.titleMedium!
                      .copyWith(decoration: TextDecoration.underline)),
              margin: const EdgeInsets.all(32),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enableSelectionZooming: true,
                  enableMouseWheelZooming: true),
              primaryXAxis: DateTimeAxis(
                  name: 'Date',
                  majorGridLines: const MajorGridLines(width: 0),
                  intervalType: DateTimeIntervalType.days,
                  dateFormat: DateFormat.d()),
              series: <ChartSeries>[
                LineSeries<DateTime, DateTime>(
                    dataSource: negative_line.keys.toList()
                      ..sort((a, b) => a
                          .difference(b)
                          .inDays), //sort the dates in ascending order
                    xValueMapper: (DateTime sentiment, _) => sentiment,
                    yValueMapper: (DateTime sentiment, _) =>
                        negative_line[sentiment],
                    name: 'Negative',
                    color: Colors.red),
                LineSeries<DateTime, DateTime>(
                    dataSource: positive_line.keys.toList()
                      ..sort((a, b) => a.difference(b).inDays),
                    xValueMapper: (DateTime sentiment, _) => sentiment,
                    yValueMapper: (DateTime sentiment, _) =>
                        positive_line[sentiment],
                    name: 'Positive',
                    color: Colors.green),
              ],
            ),

            SizedBox(
              height: 20,
            ),

            //create a bar chat using negativeChartData and positiveChartData
            SfCartesianChart(
              title: ChartTitle(
                  text: 'Most trending keywords',
                  textStyle: Get.textTheme.titleMedium!
                      .copyWith(decoration: TextDecoration.underline)),
              margin: const EdgeInsets.all(32),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enableSelectionZooming: true,
                  enableMouseWheelZooming: true),
              series: <ChartSeries>[
                ColumnSeries<BarChartData, String>(
                    dataSource: negativeChartData,
                    xValueMapper: (BarChartData sentiment, _) => sentiment.x,
                    yValueMapper: (BarChartData sentiment, _) => sentiment.y,
                    name: 'Negative',
                    color: Colors.red),
                ColumnSeries<BarChartData, String>(
                    dataSource: positiveChartData,
                    xValueMapper: (BarChartData sentiment, _) => sentiment.x,
                    yValueMapper: (BarChartData sentiment, _) => sentiment.y,
                    name: 'Positive',
                    color: Colors.green),
              ],
              primaryXAxis: CategoryAxis(),
            ),

            ExpansionTile(
              leading: Icon(Icons.info_outline),
              title: const Text('Detailed Stats'),
              subtitle: const Text('Click to view the detailed stats'),
              onExpansionChanged: (value) {
                if (value) {
                  setState(() {
                    //add a callback after 3 seconds
                    Future.delayed(const Duration(seconds: 1), () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.ease);
                      });
                    });
                  });
                }
              },
              children: [
                if (tableData.isNotEmpty)
                  PaginatedDataTable(
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('UID')),
                      DataColumn(label: Text('Positive')),
                      DataColumn(label: Text('Negative')),
                      DataColumn(label: Text('Content'))
                    ],
                    source: TweetDataTableSource(tableData),
                  ),
              ],
            ),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class TweetDataTableSource extends DataTableSource {
  TweetDataTableSource(this.data);

  final List<Post> data;

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(data[index].date.toString())),
        DataCell(TextButton(
            onPressed: () {
              launchUrlString(data[index].url.toString());
            },
            child: Text(data[index].uid.toString()))),
        DataCell(Text(data[index].sentiment.positive.toString())),
        DataCell(Text(data[index].sentiment.negative.toString())),
        DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Text(data[index].content.toString()),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
