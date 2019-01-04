import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kuzzle/kuzzle_dart.dart';

import '../components/exiticonbutton.dart';
import '../components/loading.dart';
import '../components/serversubtitle.dart';
import '../redux/instance.dart';
import 'indexes.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool adminExists;
  bool isLoggedIn = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    login();
  }

  Future<void> login() async {
    final adminExists = await store.state.current.adminExists();
    setState(() {
      this.adminExists = adminExists;
      isLoggedIn = false;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => isLoading
      ? LoadingPage()
      : isLoggedIn
          ? IndexesPage()
          : adminExists
              ? _AdminLoginPage(
                  onLoginCallback: () {
                    setState(() {
                      isLoggedIn = true;
                    });
                  },
                )
              : _AnonymousLoginPage(
                  onLoginCallback: () {
                    setState(() {
                      isLoggedIn = true;
                    });
                  },
                );
}

class _AnonymousLoginPage extends StatelessWidget {
  _AnonymousLoginPage({@required this.onLoginCallback, Key key})
      : super(key: key);

  final TextEditingController usernameController =
      TextEditingController(text: 'admin');
  final TextEditingController passwordController =
      TextEditingController(text: 'admin');
  final TextEditingController confirmPasswordController =
      TextEditingController(text: 'admin');

  final VoidCallback onLoginCallback;

  Future<void> createAdmin() async {
    if (passwordController.text == confirmPasswordController.text) {
      // Create admin
      final credentials = Credentials(LoginStrategy.local,
          username: usernameController.text, password: passwordController.text);
      await store.state.current.security.createFirstAdmin(credentials);
      await store.state.current.login(credentials);
      onLoginCallback();
    }
  }

  Future<void> anonymous() async {
    onLoginCallback();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Admin Login'),
              ServerSubtitle(),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: createAdmin,
            ),
            ExitIconButton(),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                keyboardType: TextInputType.text,
              ),
              RaisedButton(
                child: const Text('Create Admin'),
                onPressed: createAdmin,
              ),
              RaisedButton(
                child: const Text('Login as Anonymous'),
                onPressed: anonymous,
              ),
            ],
          ),
        ),
      );
}

class _AdminLoginPage extends StatelessWidget {
  _AdminLoginPage({@required this.onLoginCallback, Key key}) : super(key: key);

  final TextEditingController usernameController =
      TextEditingController(text: 'admin');
  final TextEditingController passwordController =
      TextEditingController(text: 'admin');

  final VoidCallback onLoginCallback;

  Future<void> login() async {
    await store.state.current.login(Credentials(LoginStrategy.local,
        username: usernameController.text, password: passwordController.text));
    onLoginCallback();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Admin Login'),
              ServerSubtitle(),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: login,
            ),
            ExitIconButton(),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.text,
              ),
              RaisedButton(
                child: const Text('Login'),
                onPressed: login,
              )
            ],
          ),
        ),
      );
}
