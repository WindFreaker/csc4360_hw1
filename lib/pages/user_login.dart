import 'package:csc4360_hw1/widgets/custom_forms.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '', _password  = '';

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomTextFormField(
                  label: 'Email address',
                  icon: Icons.email,
                  onSaved: (String? value) {
                    _email = (value == null) ? "" : value;
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email.';
                    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  label: 'Password',
                  icon: Icons.password,
                  onSaved: (String? value) {
                    _password = (value == null) ? "" : value;
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password.';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {

                    // updates the values of _email and _password
                    _formKey.currentState!.save();

                    if (_formKey.currentState!.validate()) {
                      print('Form is valid, processing data...');

                      try {

                        final newUser = await _auth.signInWithEmailAndPassword(
                          email: _email,
                          password: _password,
                        );

                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

                      } on FirebaseAuthException catch(error) {
                        if (error.code == 'wrong-password' || error.code == 'user-not-found') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Incorrect email or password'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Okay'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          print(error);
                        }
                      }

                    } else {
                      print('Form is not valid!');
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
