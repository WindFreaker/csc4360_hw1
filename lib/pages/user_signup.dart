import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc4360_hw1/widgets/custom_forms.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({Key? key}) : super(key: key);

  @override
  _UserSignUpState createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
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
                  label: 'Create your password',
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
                CustomTextFormField(
                  label: 'Verify your new password',
                  icon: Icons.check_circle_outline,
                  validator: (String? value) {
                    if (value == null || value != _password) {
                      return 'Passwords don\'t match.';
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

                        UserCredential creds = await _auth.createUserWithEmailAndPassword(
                          email: _email,
                          password: _password,
                        );

                        await FirebaseFirestore.instance.collection('hw1-users').doc(creds.user!.uid).set({
                          'firstName': '',
                          'lastName': '',
                          'registeredAt': Timestamp.now(),
                          'role': 'CUSTOMER',
                        });

                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

                      } catch (error) {
                        // TODO: display error when emails that already have accounts
                        print(error);
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
