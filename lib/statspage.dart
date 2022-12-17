import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
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
  var tableData = <List>[];
  var order_map = <int, int>{};
  // one week old timestamp
  var from = DateTime.now().subtract(const Duration(days: 7));
  var to = DateTime.now();
  var selected_social = 'twitter';
  var input_keywords = <String>[];
  var total_negative = 0;
  var total_positive = 0;
  var scrollController = ScrollController();

  Map<DateTime, int> negative_line = <DateTime, int>{};
  Map<DateTime, int> positive_line = <DateTime, int>{};

  var negativeChartData = <BarChartData>[];
  var positiveChartData = <BarChartData>[];
  @override
  void initState() {
    loadAsset();
    super.initState();
  }

  Future<void> loadAsset() async {
    //load the json file
    var data =
        await DefaultAssetBundle.of(context).loadString('ndp_sentiments.csv');

    List<List<dynamic>> csvTable = CsvToListConverter().convert(data);

    //drop the first element of each of the sublist
    for (var element in csvTable) {
      element.removeAt(0);

      var stringDate = element[0].toString();

      //find + symbol
      var index = stringDate.indexOf('+');

      //check if + symbol is present
      if (index != -1) {
        var date = DateTime.parse(stringDate);

        element[0] = date;
      }
      var val = element.elementAt(3);
      if (val == 1.0) {
        total_positive++;
      } else {
        total_negative++;
      }
    }

    //group by date into negative_line and positive_line
    var temp = csvTable.skip(1);
    for (var element in temp) {
      var date = element[0];

      //remove the time from the date
      date = DateTime(date.year, date.month, date.day);
      var val = element.elementAt(3);
      if (val == 1.0) {
        if (positive_line.containsKey(date)) {
          positive_line[date] = positive_line[date]! + 1;
        } else {
          positive_line[date] = 1;
        }
      } else {
        if (negative_line.containsKey(date)) {
          negative_line[date] = negative_line[date]! + 1;
        } else {
          negative_line[date] = 1;
        }
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

    setState(() {
      tableData = csvTable;
      var len = csvTable[0].length;
      for (var i = 0; i < len; i++) {
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
                      'Welcome to the Stats Page',
                      style: Get.textTheme.headlineMedium!
                          .copyWith(color: Colors.white),
                    ),
                    Text('Stay updated with the latest trends on Social Media',
                        style: Get.textTheme.bodyText1!
                            .copyWith(color: Colors.white)),

                    SizedBox(
                      height: 20,
                    ),
                    //learn more button
                    ElevatedButton(
                      onPressed: () async {},
                      child: const Text('Learn More'),
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
                        Text("KEYWORDS", style: TextStyle(color: Colors.white)),
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
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  input_keywords.remove(keyword);
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
                    suffixIcon: Icon(Icons.add),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    hintText: 'Add a keyword'),
              ),
            ),

            SizedBox(
              height: 20,
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
                  dateFormat: DateFormat.yMMMMEEEEd()),
              series: <ChartSeries>[
                LineSeries<DateTime, DateTime>(
                    dataSource: negative_line.keys.toList(),
                    xValueMapper: (DateTime sentiment, _) => sentiment,
                    yValueMapper: (DateTime sentiment, _) =>
                        negative_line[sentiment] ?? 0,
                    name: 'Negative',
                    color: Colors.red),
                LineSeries<DateTime, DateTime>(
                    dataSource: positive_line.keys.toList(),
                    xValueMapper: (DateTime sentiment, _) => sentiment,
                    yValueMapper: (DateTime sentiment, _) =>
                        positive_line[sentiment] ?? 0,
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
                      ...tableData[0].asMap().entries.map((e) => DataColumn(
                          label: Row(children: [
                            Text(e.value.toString()),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (order_map[e.key] == -1) {
                                      order_map[e.key] = 1;
                                    } else if (order_map[e.key] == 1) {
                                      order_map[e.key] = 0;
                                    } else {
                                      order_map[e.key] = -1;
                                    }
                                  });
                                },
                                icon: Icon(order_map[e.key] == -1
                                    ? Icons.arrow_right
                                    : order_map[e.key] == 1
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward))
                          ]),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              var temp = tableData.skip(1).toList();
                              if (order_map[columnIndex] == 1) {
                                temp.sort((a, b) =>
                                    b[columnIndex].compareTo(a[columnIndex]));
                                order_map[columnIndex] = 0;
                              } else {
                                temp.sort((a, b) =>
                                    a[columnIndex].compareTo(b[columnIndex]));
                                order_map[columnIndex] = 1;
                              }

                              tableData = [tableData[0], ...temp];
                            });
                          })),
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

  final List<List<dynamic>> data;

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        ...data[index + 1].asMap().entries.map((e) {
          var text = e.value.toString();
          //if text is a number, make it a double
          if (e.key > 2) {
            var n = double.parse(text);
            var child;
            if (n == 1.0 || n == 0.0) {
              child = Icon(
                  n == 1
                      ? Icons.sentiment_very_satisfied
                      : Icons.sentiment_very_dissatisfied,
                  color: n == 1 ? Colors.green : Colors.red);
            } else {
              //trim the number to 2 decimal places
              text = n.toStringAsFixed(2);
              child = Text(text);
            }
            return DataCell(ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: child,
              ),
            ));
          }
          var child;
          if (e.key == 1) {
            child = TextButton(
                onPressed: () {
                  //open the tweet in a browser
                  launchUrlString('https://www.twitter.com/$text');
                },
                child: Text('@$text'));
          } else {
            child = SelectableText(text);
          }
          return DataCell(ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          ));
        }),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length - 1;

  @override
  int get selectedRowCount => 0;
}
