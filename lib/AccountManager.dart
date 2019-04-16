import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import "package:hex/hex.dart";
import 'Class.dart';
import 'Assignment.dart';
import 'GradingCategory.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountManager{
  static const NewSessURL = "https://portal.mcpsmd.org/public/home.html";
  static const LoginURL = "https://portal.mcpsmd.org/guardian/home.html";
  static const ClassesBaseURL = "https://portal.mcpsmd.org/guardian/prefs/gradeByCourseSecondary.json";
  static const TermURL = "https://portal.mcpsmd.org/guardian/prefs/termsData.json";
  static const CategoryURL = "https://portal.mcpsmd.org/guardian/prefs/assignmentGrade_CategoryDetail.json";
  static const AssignmentInfoURL = "https://portal.mcpsmd.org/guardian/prefs/assignmentGrade_AssignmentDetail.json";
  static const ClassDetailURL = "https://portal.mcpsmd.org/guardian/prefs/assignmentGrade_CourseDetail.json";

  var StudentNumber = "";
  var StudentId = "";
  var password;
  var termname = null;
  var accounts = new Map<String, String>();
  var dio;
  var cookieJar;

  AccountManager(){
    dio= new Dio();
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<String> Login(String StudentId, String Password) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (!(result.isNotEmpty && result[0].rawAddress.isNotEmpty)) {
        return "Cannot connect to internet";
      }
    } on SocketException catch (_) {
      return "Cannot connect to internet";
    }

    this.password = Password;
    this.StudentId = StudentId;

    var form = new Map<String, String>();

    var psval = "";

    {
      Response resp = await dio.get(NewSessURL);
      var doc = parse(resp.data.toString());

      List<Element> inputs = doc.getElementById("LoginForm").children;

      for(Element input in inputs){
        if(input.attributes.containsKey("type") && input.attributes["type"]=="hidden"){
          form[input.attributes["name"]] = input.attributes["value"];
          if(input.attributes["name"] == "contextData"){
            psval = input.attributes["value"];
          }
        }
      }
    }

    form["account"] = StudentId;
    form["ldappassword"] = Password;

    String b64pw = base64.encode(md5.convert(utf8.encode(Password)).bytes).replaceAll("=", " ").trim();

    var hmac_md5 = Hmac(md5, utf8.encode(psval));
    form["pw"] =  HEX.encode(hmac_md5.convert(utf8.encode(b64pw)).bytes);

    form["dbpw"] = HEX.encode(hmac_md5.convert(utf8.encode(Password.toLowerCase())).bytes);

    var resp;
    try {
      resp = await dio.post(LoginURL, data: form,
          options: new Options(contentType: ContentType.parse(
              "application/x-www-form-urlencoded")));
    }on DioError catch(error) {
      if (error.response.statusCode == 302) {
        resp = await dio.get(error.response.headers.value("location"));
      }
    }
    if(int.tryParse(StudentId) != null){
      String body = resp.data.toString();

      var pattern = new RegExp("\\s?root.studentId\\s?=\\s?parseInt\\(('|\")(\\d+)('|\")\\);");

      var match = pattern.firstMatch(body);
      if (match != null) {
        StudentNumber = match.group(2);
        return "true";
      }
    }else{
      String body = resp.data.toString();

      var pattern = new RegExp("\\s?<a href=(\"|')javascript:switchStudent\\((\\d+)\\);(\"|')>(.+)<\\/a>");

      var matches = pattern.allMatches(body);

      if(matches.length>0){
        for(var match in matches){
          accounts[match.group(4)] = match.group(2);
        }
        return "Multiple Accounts";
      }

    }

    return "Login failed!";
  }
  Future<String> ReLogin(){
    return Login(StudentId, password);
  }

  String currentSchool(){
    List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(LoginURL));
    for (var cookie in cookies){
      if(cookie.name == "currentSchool"){
        return cookie.value;
      }
    }
  }

  Future<List<dynamic>> loadClasses() async {
    var url = ClassesBaseURL + "?schoolid=" + currentSchool() + "&student_number=" + StudentId + "&studentId=" + StudentNumber;
    String json = (await dio.get(url)).data.toString();
    return (jsonDecode(json).map((var model)=>Class.fromJson(model)).toList());
  }

  Future<Class> loadClassDetails(String secid) async{
    String url = ClassDetailURL + "?secid=" + secid + "&schoolid=" + currentSchool() + "&student_number=" + StudentId + "&termid=" + await loadTerm();
    String json = (await dio.get(url)).data.toString();
    return Class.fromJson(jsonDecode(json));
  }

  Future<String> loadTerm() async{
    if (this.termname != null){
      return this.termname;
    }

    String url = TermURL + "?schoolid=" + currentSchool();
    String json = (await dio.get(url)).data.toString();
    List<dynamic> terms = jsonDecode(json);

    int max = 0;
    String termname = "";

    for(var term in terms){
      if(term["termname"] != null && int.parse(term["termname"].substring(2)) > max){
        max = int.parse(term["termname"].substring(2));
        termname = term["termname"];
      }
    }

    this.termname = termname;
    return termname;
  }

  Future<List<dynamic>> loadCategories(String secid) async{
    String url = CategoryURL + "?secid=" + secid + "&student_number=" + StudentId + "&schoolid=" + currentSchool() + "&termid=" + await loadTerm();
    String json = (await dio.get(url)).data.toString();
    return (jsonDecode(json).map((var model)=>GradingCategory.fromJson(model)).toList());
  }

  Future<List<dynamic>> loadAssignments(String secid) async{
    String url = AssignmentInfoURL + "?secid=" + secid + "&student_number=" + StudentId + "&schoolid=" + currentSchool() + "&termid=" + await loadTerm();
    String json = (await dio.get(url)).data.toString();
    return (jsonDecode(json).map((var model)=>Assignment.fromJson(model)).toList());
  }

  Future logout() async{
    accounts = new Map<String, String>();
    await dio.get(LoginURL + "?ac=logoff");
  }

  Future saveAccount(String StudentId, String Password) async{
    var storage = FlutterSecureStorage();
    
    await storage.write(key: "StudentId", value: StudentId);
    await storage.write(key: "Password", value: Password);
  }

  Future deleteAccount() async{
    var storage = FlutterSecureStorage();
    await storage.deleteAll();
  }

  Future<List<dynamic>> getAccount() async {
    var storage = new FlutterSecureStorage();
    return [await storage.read(key: "StudentId"), await storage.read(key: "Password")];
  }

  List<String> getStudentNames(){
    return accounts.keys.toList();
  }

  Future setActiveAccount(String name) async {
    //TO-DO
  }
}