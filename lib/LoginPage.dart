import 'package:flutter/material.dart';
import 'main.dart';
import 'ClassesPage.dart';


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
  BuildContext context;
  bool isloading = false;

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
              TextField(controller: usernameCont,autocorrect: false, decoration: InputDecoration(hintText: "Username"),),
              SizedBox(height: 10,),
              TextField(controller:passCont, autocorrect: false, obscureText: true ,decoration: InputDecoration(hintText: "Password"),),

              SizedBox(height: 10,),
              RaisedButton(onPressed: Login,color: Theme.of(context).accentColor, textColor: Colors.white ,child: Text("Login"),),

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
    }else if (val == "MultipleAccounts"){
      setState(() {
        isloading=false;
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
    setState(() {
      isloading=true;
    });
    MyApp.Account.Login(usernameCont.text, passCont.text).then(LoginCallback);


  }

}