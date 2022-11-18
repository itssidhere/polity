import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var query = '';
  @override
  Widget build(BuildContext context) {
    //create a fancy search bar in between
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          Lottie.asset('assets/search.json', height: 250, width: 250),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.mic),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                labelText: 'Calculate the sentiment of a text',
              ),
              onSubmitted: (val) async {
                //send a post request to the backend
                query = val;
                var response = await _getPrediction(val);

                //show the result in a dialog
                showDialog(
                    context: context,
                    builder: (context) {
                      var positive = response['prediction']['positive'];
                      var negative = response['prediction']['negative'];

                      //round the values to 2 decimal places
                      positive = double.parse(positive.toStringAsFixed(2));
                      negative = double.parse(negative.toStringAsFixed(2));

                      //change it to a percentage
                      positive = positive * 100;
                      negative = negative * 100;

                      //show a syncfusion pie chart
                      return AlertDialog(
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Close')),
                        ],
                        title: Text(
                          '${query}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        content: Container(
                          height: 300,
                          width: 300,
                          child: SfCircularChart(
                            legend: Legend(
                              isVisible: true,
                              overflowMode: LegendItemOverflowMode.wrap,
                            ),
                            title: ChartTitle(text: 'Positive vs Negative'),
                            series: <CircularSeries>[
                              DoughnutSeries<Map<String, dynamic>, String>(
                                  dataSource: <Map<String, dynamic>>[
                                    {'score': positive, 'label': 'Positive'},
                                    {'score': negative, 'label': 'Negative'}
                                  ],
                                  xValueMapper:
                                      (Map<String, dynamic> sentiment, _) =>
                                          sentiment['label'],
                                  yValueMapper:
                                      (Map<String, dynamic> sentiment, _) =>
                                          sentiment['score'],

                                  // ignore: prefer_const_constructors
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true))
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
          )
        ],
      ),
    ));
  }
}

Future<dynamic> _getPrediction(String text) async {
  //send a post request to the backend
  //get the response
  //display the response
  var dio = Dio();
  var url = 'http://127.0.0.1:5000/prediction';

  var response = await dio.post(
    url,
    data: jsonEncode({
      'query': text,
    }),
  );

  return jsonDecode(response.toString());
}
