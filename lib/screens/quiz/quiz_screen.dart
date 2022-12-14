import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:quizu/const/colors.dart';
import 'package:quizu/const/images.dart';
import 'package:quizu/const/text_style.dart';
import 'package:quizu/models/myscore.dart';
import 'package:quizu/repository/api_services.dart';
import 'package:quizu/repository/sql/sql_score.dart';
import 'package:quizu/screens/result/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var currentQuestionIndex = 0;
  List<MyScore> list = [];
  String? token;
  // int seconds = 60;

  Duration myDuration = const Duration(minutes: 2);
  SharedPreferences? share;

  Timer? timer;
  // late Future quiz;

  int points = 0;

  var isLoaded = false;

  var optionsList = [];

  var optionsColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  @override
  void initState() {
    fecthData();
    super.initState();
    // initshared();
    // quiz = APIService.getQuiz1(token!);

    startTimer1();
  }

  fecthData() async {
    SharedPreferences.getInstance().then((share) {
      setState(() {
        token = share.getString('token');
        // name = share.getString('name');
      });
    });
  }

  void addItem(MyScore item) {
    // Insert an item into the top of our list, on index zero
    list.add(item);
    saveData();
  }

  void saveData() {
    List<String> stringList =
        list.map((item) => jsonEncode(item.toJson())).toList();

    share!.setStringList('list', stringList);
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  resetColors() {
    optionsColor = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];
  }

  gotoNextQuestion() {
    setState(() {
      isLoaded = false;
      currentQuestionIndex++;
      resetColors();
      seconds = 120;
      myDuration = const Duration(minutes: 2);
      timer!.cancel();
      startTimer1();
    });
  }

  gotoNextReuslt() {
    setState(() {
      isLoaded = false;
      // currentQuestionIndex++;
      // resetColors();
      // seconds = 120;
      // myDuration = const Duration(minutes: 2);
      // timer!.cancel();
      startTimer1();
      _showMyDialog();
    });
  }

  void startTimer1() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {setCountDown()});
  }

  int seconds = 120;
  void setCountDown() {
    const reduceSecondsBy = 1;

    seconds = myDuration.inSeconds - reduceSecondsBy;
    setState(() {
      if (seconds < 0) {
        seconds--;
      } else if (seconds == 0) {
        if (currentQuestionIndex != 29) {
          gotoNextQuestion();
        }
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  bool _isLoading = false;

  ssndResult(score) async {
    setState(() {
      _isLoading = true;
    });

    await APIService.updatescore(context, score, token!);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final second = strDigits(myDuration.inSeconds.remainder(60));

    return Scaffold(
        backgroundColor: purple,
        body: SafeArea(
            child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [purple, deepPurple],
                )),
                child: FutureBuilder(
                  future: APIService.getQuiz1(token!),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data;

                      if (isLoaded == false) {
                        List it = [
                          'a: ${data[currentQuestionIndex]['a']} ',
                          "b: ${data[currentQuestionIndex]['b']}",
                          "c: ${data[currentQuestionIndex]['c']}",
                          "d: ${data[currentQuestionIndex]['d']}"
                        ];
                        optionsList = it;
                        optionsList.shuffle();
                        isLoaded = true;
                      }
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: data != null
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                color: lightgrey, width: 2),
                                          ),
                                          child: IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(
                                                CupertinoIcons.xmark,
                                                color: Colors.white,
                                                size: 28,
                                              )),
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            normalText(
                                                color: seconds <= 30
                                                    ? Colors.red
                                                    : Colors.green,
                                                size: 24,
                                                text: "$minutes:$second"),
                                            SizedBox(
                                              width: 80,
                                              height: 80,
                                              child: CircularProgressIndicator(
                                                value: seconds / 120,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        seconds <= 30
                                                            ? Colors.red
                                                            : Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Lottie.asset(ideas,
                                        width: 145,
                                        height: 150,
                                        fit: BoxFit.fill),
                                    const SizedBox(height: 20),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: normalText(
                                            color: lightgrey,
                                            size: 18,
                                            text:
                                                "Question ${currentQuestionIndex + 1} of ${data.length}")),
                                    const SizedBox(height: 20),
                                    normalText(
                                        color: Colors.white,
                                        size: 20,
                                        text: data[currentQuestionIndex]
                                            ['Question']),
                                    const SizedBox(height: 20),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: optionsList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var list = optionsList
                                          ..sort((a, b) => a.compareTo(b));
                                        var ite = list[index];
                                        var answer = data[currentQuestionIndex]
                                            ['correct'];

                                        return GestureDetector(
                                          onTap: () {
                                            if (currentQuestionIndex ==
                                                data.length - 1) {
                                              setState(() {
                                                gotoNextReuslt();
                                                ssndResult(points);
                                                String now = DateFormat(
                                                        "hh:mm:ss a yyyy-MM-dd")
                                                    .format(DateTime.now());

                                                SqliteService.createItem(
                                                    MyScore(
                                                  score: points.toString(),
                                                  time: now.toString(),
                                                ));
                                              });
                                            } else {
                                              setState(() {
                                                if (answer.toString() ==
                                                    ite.toString()[0]) {
                                                  optionsColor[index] =
                                                      Colors.green;
                                                  points = points + 1;
                                                } else {
                                                  optionsColor[index] =
                                                      Colors.red;
                                                }

                                                if (currentQuestionIndex <
                                                    data.length - 1) {
                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 1), () {
                                                    gotoNextQuestion();
                                                  });
                                                } else {
                                                  timer!.cancel();
                                                  //here you can do whatever you want with the results
                                                }
                                              });
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 20),
                                            alignment: Alignment.center,
                                            width: size.width - 100,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: optionsColor[index],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: headingText(
                                              color: purple,
                                              size: 18,
                                              text:
                                                  optionsList[index].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _isLoading
                                        ? const CircularProgressIndicator()
                                        : currentQuestionIndex ==
                                                data.length - 1
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  _showMyDialog();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.deepOrange,
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0)),
                                                    minimumSize: Size(
                                                        size.width / 0.2, 50)),
                                                child: const Text(
                                                  'show Result',
                                                  style: TextStyle(
                                                    fontFamily: "quick_bold",
                                                    fontSize: 18,
                                                    color: Colors.grey,
                                                  ),
                                                ))
                                            : TextButton(
                                                onPressed: () {
                                                  gotoNextQuestion();
                                                },
                                                child: const Text(
                                                  'Skip',
                                                  style: TextStyle(
                                                    fontFamily: "quick_bold",
                                                    fontSize: 18,
                                                    color: Colors.grey,
                                                  ),
                                                )),
                                    const SizedBox(height: 30),
                                  ],
                                )
                              : Container(),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      );
                    }
                  },
                ))));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          contentPadding: const EdgeInsets.all(12.0),
          title: normalText(text: 'Finish quiz'),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          content: const SingleChildScrollView(
            child: Text('A result will be displayed after the finish quiz'),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                elevation: 0,
              ),
              child: normalText(
                  text: 'Show Result', size: 14, color: Colors.green),
              onPressed: () {
                ssndResult(points).whenComplete(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(points: points),
                      ));
                });
                String now =
                    DateFormat("hh:mm:ss a yyyy-MM-dd").format(DateTime.now());
                SqliteService.createItem(MyScore(
                  score: points.toString(),
                  time: now.toString(),
                ));
              },
            ),
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
