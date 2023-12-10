import 'package:flutter/material.dart';
import 'package:visualizeit/pages/base_page.dart';

import '../utils/validators.dart';

class SignInPage extends BasePage {
  const SignInPage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return const SignInPageComponent();
  }
}

class UserCredentials {
  String email = '';
  String password = '';
}

class SignInPageComponent extends StatefulWidget {
  const SignInPageComponent({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPageComponent> {
  final GlobalKey<FormState> _key = GlobalKey();
  final UserCredentials _userCredentials = UserCredentials();
  bool _validate = false;
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.all(20.0),
            child: Center(
              child: Form(
                key: _key,
                autovalidateMode: _validate ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: SizedBox(width: 350, child: _getFormUI()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getFormUI() {
    return Column(
      children: <Widget>[
        const Icon(Icons.person, color: Colors.lightBlue, size: 100.0),
        const SizedBox(height: 50.0),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: FormValidator().validateEmail,
          onSaved: (String? value) {
            _userCredentials.email = value ?? '';
          },
        ),
        const SizedBox(height: 20.0),
        TextFormField(
            autofocus: false,
            obscureText: _hidePassword,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              errorMaxLines: 2,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                child: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: FormValidator().validatePassword,
            onSaved: (String? value) {
              _userCredentials.password = value ?? '';
            }),
        const SizedBox(height: 15.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(onPressed: _sendToServer, child: const Text('Sign In')),
        ),
        TextButton(onPressed: _showForgotPasswordDialog, child: const Text('Forgot password?', style: TextStyle(color: Colors.black54))),
        TextButton(onPressed: _sendToRegistrationPage, child: const Text('Sign up', style: TextStyle(color: Colors.black54))),
      ],
    );
  }

  _sendToRegistrationPage() {
    //TODO implement registration page
    print("go to registration page");
  }

  _sendToServer() {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      //TODO implement sign in
      print("Email ${_userCredentials.email}");
      print("Password ${_userCredentials.password}");
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  Future<Null> _showForgotPasswordDialog() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please enter your Email'),
            content: TextField(
              decoration: const InputDecoration(hintText: "Email"),
              onChanged: (String value) {
                _userCredentials.email = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Ok"),
                onPressed: () async {
                  _userCredentials.email = "";
                  Navigator.pop(context);
                },
              ),
              TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
            ],
          );
        });
  }
}
