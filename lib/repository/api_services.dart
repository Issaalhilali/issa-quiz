import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizu/data/api_const.dart';
import 'package:quizu/models/result_model.dart';
import 'package:quizu/models/topmode.dart';
import 'package:quizu/repository/const.dart';

var link = "https://opentdb.com/api.php?amount=20";
var lisn1 = "https://quizu.okoul.com/Questions";
var urlscore = "https://quizu.okoul.com/Score";

class APIService {
  getQuiz() async {
    var res = await http.get(Uri.parse(link));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());

      return data;
    }
  }

  static Future getQuiz1(String token) async {
    // List<QuizModel> result = [];
    setHeadersToken() => {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        };
    var res = await http.get(Uri.parse(lisn1), headers: setHeadersToken());

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());
      // List data = jsonDecode(res.body.toString());
      // var result = data.map((e) => QuizModel.fromJson(e)).toList();
      // print("data is loaded");
      // print()
      return data;
    } else {
      throw Exception(res.reasonPhrase);

      // return result;
    }
  }

  static Future updatescore(BuildContext context, score, String token) async {
    Map data = {"score": score};

    var body = json.encode(data);
    setHeadersToken() => {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        };
    var res = await http.post(Uri.parse(urlscore),
        body: body, headers: setHeadersToken());

    try {
      var result = ResultModel.fromJson(jsonDecode(res.body));

      if (result.success != null) {
        // Navigator.push(
        // context, MaterialPageRoute(builder: (context) => RsultScreen()));
      }
      // print()
      return result;
    } catch (e) {
      throw Exception(res.reasonPhrase);
    }
  }

//for get info user
  static Future<List<TopModel>> gettopscore(token) async {
    final url = Uri.parse(ApiCOnst.baseUrl + ApiCOnst.topScore);
    var response =
        await http.get(url, headers: ConstData.setHeadersToken(token));
    try {
      // if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map(((e) => TopModel.fromJson(e))).toList();

      // }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
