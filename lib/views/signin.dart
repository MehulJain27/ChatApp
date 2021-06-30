import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/helper/theme.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/chatrooms.dart';
import 'package:chatapp/views/forgot_password.dart';
import 'package:chatapp/views/phoneSignIn.dart';
import 'package:chatapp/views/signup.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_linkedin/linkedloginflutter.dart';


import 'chat.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn(this.toggleView);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService authService = new AuthService();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signInWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) async {
        if (result != null)  {
          QuerySnapshot userInfoSnapshot =
              await DatabaseMethods().getUserInfo(emailEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.documents[0].data["userName"]);
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.documents[0].data["userEmail"]);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        } else {
          setState(() {
            isLoading = false;
            //show snackbar
          });
        }
      });
    }
  }

  Future<FirebaseUser> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    DatabaseMethods databaseMethods = new DatabaseMethods();

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
      final FirebaseUser user = await _auth.currentUser();
      final uid = user.email;
      List<String> mp = uid.split('@');
       Map<String,String> userDataMap = {
         "userName" : mp[0],
         "userEmail" : uid,
       };
      HelperFunctions.saveUserLoggedInSharedPreference(true);
      HelperFunctions.saveUserNameSharedPreference(mp[0]);

      //databaseMethods.addUserInfo(userDataMap);
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
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Please Enter Correct Email";
                          },
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("email"),
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (val) {
                            return val.length > 6
                                ? null
                                : "Enter Password 6+ characters";
                          },
                          style: simpleTextStyle(),
                          controller: passwordEditingController,
                          decoration: textFieldInputDecoration("password"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Forgot Password?",
                              style: simpleTextStyle(),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      signIn();
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>PhoneSignIn(widget.toggleView)));
                       // login using phone
                    },
                  child : Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Sign In with Phone Number",
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
                          /// LINKDIN
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,0),
                    child: Row(
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
