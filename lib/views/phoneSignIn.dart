import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/helper/theme.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/chatrooms.dart';
import 'package:chatapp/views/forgot_password.dart';
import 'package:chatapp/views/signin.dart';
import 'package:chatapp/views/signup.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_linkedin/linkedloginflutter.dart';



class PhoneSignIn extends StatefulWidget {
  final Function toggleView;
  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController otpEditingController =  TextEditingController();

  PhoneSignIn(this.toggleView);

  @override
  _PhoneSignInState createState() => _PhoneSignInState();
}

class _PhoneSignInState extends State<PhoneSignIn> {

  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController otpEditingController =  TextEditingController();
  TextEditingController userNameEditingController = TextEditingController();

  Future<bool> loginUser(String phone, String userName, BuildContext context) async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    DatabaseMethods databaseMethods = new DatabaseMethods();
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 120),
        verificationCompleted: (AuthCredential credential) async{
          Navigator.of(context).pop();

          AuthResult result = await _auth.signInWithCredential(credential);

          FirebaseUser user = result.user;

          if(user != null){
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ChatRoom()));
          }else{
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception){
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Enter the OTP"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: otpEditingController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async{
                        final code = otpEditingController.text.trim();
                        AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: code);

                        AuthResult result = await _auth.signInWithCredential(credential);

                        FirebaseUser user = result.user;

                        if(user != null){
                          Map<String,String> userDataMap = {
                            "userName" : userNameEditingController.text,
                            "userPhoneNo" : phoneEditingController.text
                          };
                        /// ADD check condition
                        if(databaseMethods.isUserRegistered(userName) == false) {
                          print("New User");
                          databaseMethods.addUserInfo(userDataMap);
                        }
                          HelperFunctions.saveUserLoggedInSharedPreference(true);
                          HelperFunctions.saveUserNameSharedPreference(userNameEditingController.text);

                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => ChatRoom()));
                        }else{
                          print("Error");
                        }
                      },
                    )
                  ],
                );
              }
          );
        },
        codeAutoRetrievalTimeout: null
    );
  }

  AuthService authService = new AuthService();

  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;


  phoneSignIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
    }
  }

  Future<FirebaseUser> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = new GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount =
    await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    AuthResult result = await _auth.signInWithCredential(credential);
    FirebaseUser userDetails = result.user;

    if (result == null) {
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
        child: Center(child: CircularProgressIndicator()),
      )
          : Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Spacer(),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: simpleTextStyle(),
                    controller: userNameEditingController,
                    decoration: textFieldInputDecoration("User Name"),
                  ),
                  TextFormField(
                    validator: (val) {
                      return RegExp(
                          r"^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$")
                          .hasMatch(val)
                          ? null
                          : "Please Enter Correct Phone Number";
                    },
                    controller: phoneEditingController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("Enter Phone Number"),
                  ),

                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),

            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                 final phone = phoneEditingController.text.trim();
                 final userName = userNameEditingController.text.trim();
                 loginUser(phone, userName, context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff007EF4),
                        const Color(0xff2A75BC)
                      ],
                    )),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Sign In",
                  style: biggerTextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>SignIn(widget.toggleView)));
              },
              child : Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Sign In with Email",
                  style:
                  TextStyle(fontSize: 17, color: CustomTheme.textColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Or Sign In with ",
                    style: simpleTextStyle(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    signInWithGoogle(context);
                       /// GOOGLE
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xff007EF0),
                            const Color(0xff2A75BC)
                          ],
                        )),
                    width: MediaQuery.of(context).size.width/2.4,
                    child: Text(
                      "Google",
                      style: biggerTextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: 14,),
                GestureDetector(
                  onTap: () {
                      /// LINKEDIN
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xff007EF4),
                            const Color(0xff2A75BC)
                          ],
                        )),
                    width: MediaQuery.of(context).size.width/2.4,
                    child: Text(
                      "LinkedIn",
                      style: biggerTextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have account? ",
                  style: simpleTextStyle(),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>SignUp(widget.toggleView)));
                  },
                  child: Text(
                    "Register now",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 90,
            )
          ],
        ),
      ),
    );
  }
}
