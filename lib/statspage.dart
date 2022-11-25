import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:polity/model/post.dart';
import 'package:polity/model/twitter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  var selected_social = 'twitter';
  var input_keywords = <String>[];
  var total_negative = 0;
  var total_positive = 0;
  var scrollController = ScrollController();
  @override
  void initState() {
    loadAsset();
    super.initState();
  }

  Future<List<Tweets>> getDataFromTwitter({required String keyword}) async {
    var url = 'http://127.0.0.1:5000/twitter?query=${keyword}';
    var response = await Dio().get(url);
    var data = <Tweets>[];

    for (var i = 0; i < response.data['tweets'].length; i++) {
      data.add(Tweets.fromJson(response.data['tweets'][i]));
    }

    return data;

    // print(response.data['tweets'][0]);

    // return [];
  }

  Future<void> loadAsset() async {
    //load the json file
    tableData = await getDataFromTwitter(keyword: 'ndp');

    //drop the first element of each of the sublist
    for (var element in tableData) {
      if (element.sentiment.negative > element.sentiment.positive) {
        total_negative += 1;
      } else {
        total_positive += 1;
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
                          value: 'Twitter',
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
                            'Twitter',
                            'Facebook',
                            'Instagram',
                            'Reddit'
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
                      DataColumn(label: Text('Positive')),
                      DataColumn(label: Text('Negative')),
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
        DataCell(Text(data[index].userid.toString())),
        DataCell(Text(data[index].sentiment.positive.toString())),
        DataCell(Text(data[index].sentiment.negative.toString())),
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
