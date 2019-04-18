import 'package:flutter/material.dart';
import 'main.dart';
import 'ClassesPage.dart';
import 'StudentsPage.dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginPageState();
  }
}

class LoginPageState extends State<StatefulWidget>{
  final usernameCont = TextEditingController();
  final passCont = TextEditingController();
  final  usernamefocus = FocusNode();
  final  passfocus = FocusNode();
  String username = null;
  String password = null;
  BuildContext context;
  bool isloading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  LoginPageState(){
    MyApp.Account.getAccount().then((var acc){
      usernameCont.text = acc[0];
      passCont.text = acc[1];
      if(acc[0] != "" && acc[1] != "" && acc[0] != null && acc[1] != null) {
        Login();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context=context;
    MyApp.setColor(context);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("MyMCPS Helper")),
      body: SafeArea(
        child:Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              SizedBox(height: 50,),
              Text("Login", style: TextStyle(fontSize: 24),),

              SizedBox(height: 80,),
              Form(
                autovalidate: _autovalidate,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(focusNode: usernamefocus, controller: usernameCont, autocorrect: false, decoration: InputDecoration(hintText: "Username"),keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, keyboardAppearance: Theme.of(context).brightness,
                      validator: (String val){
                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if(regex.hasMatch(val) || int.tryParse(val) != null){
                          return null;
                        }else{
                          return "Enter valid student id or email";
                        }
                      },
                      onSaved: (String val){
                        username = val;
                      },
                      onFieldSubmitted: (val){
                        usernamefocus.unfocus();
                        FocusScope.of(context).requestFocus(passfocus);
                        if(!_formKey.currentState.validate()) {
                          setState(() {
                            _autovalidate = true;
                          });
                        }
                      }
                    ,),
                    SizedBox(height: 10,),
                    TextFormField(focusNode: passfocus, controller: passCont, autocorrect: false, obscureText: true ,decoration: InputDecoration(hintText: "Password"), textInputAction: TextInputAction.done, keyboardAppearance: Theme.of(context).brightness,
                      validator: (String val){
                        if (val.length==0 && !passfocus.hasFocus){
                          return "Enter a password";
                        }else{
                          return null;
                        }
                      },
                      onSaved: (String val){
                        password = val;
                      },
                      onFieldSubmitted: (val){
                        passfocus.unfocus();
                        Login();
                      }
                    ),

                    SizedBox(height: 10,),
                    RaisedButton(onPressed: isloading ? (){} : Login,color: Theme.of(context).accentColor, textColor: Colors.white ,child: Text("Login"),),
                  ],
                ),
              ),

              SizedBox(height: 10,),
              isloading ? CircularProgressIndicator() : Container()
            ],
          ),
        ),
      ),
    );
  }

  void LoginCallback(var val){
    if(val == "true"){
      setState(() {
        isloading=false;
        MyApp.Account.saveAccount(usernameCont.text, passCont.text);
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new ClassesPage()));
      });
    }else if (val == "Multiple Accounts"){
      setState(() {
        isloading=false;
        MyApp.Account.saveAccount(usernameCont.text, passCont.text);
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new StudentsPage()));
      });
    }else {
      setState(() {
        isloading=false;
      });
      showDialog(context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: new Text(val),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
      );
    }
  }

  void Login(){
    if(_formKey.currentState.validate()) {
      setState(() {
        isloading = true;
      });
      MyApp.Account.Login(usernameCont.text, passCont.text).then(LoginCallback);
    }else{
      _autovalidate = true;
    }
  }

}