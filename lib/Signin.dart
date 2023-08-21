import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loginpage/Type.dart';
import 'package:loginpage/signup.dart';
import 'package:loginpage/HomePage.dart';
import 'dart:convert';
import 'package:loginpage/devicePage.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? authToken;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String username = usernameController.text;
      String password = passwordController.text;

      try {
        // Send the user data to the server
        http.Response response = await loginUser(username, password);
        // Print the status code from the response
        print('Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 202) {
          // Parse the response JSON
          Map<String, dynamic> responseData = json.decode(response.body);
          String? token = responseData['access_token'];

          if (token != null) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You logged in successfully')),
            );

            // Navigate to the MyTypePage with the token
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyTypePage(token: token),
              ),
            );
          } else {
            // Show error message if token is not present
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error logging in')),
            );
          }
        } else {
          // Handle other status codes if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to log in')),
          );
        }
      } catch (e) {
        // Show error message if something went wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting the form: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ),
              ),
              const Text("If you don't have an account, click here:"),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the signup.dart page when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MySignupPage(),
                    ),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<http.Response> loginUser(String username, String password) async {
  final url = Uri.parse(
      'http://196.179.229.162:8000/v0.1/users/login/token'); // Replace with the actual login endpoint
  final body = {
    'username': username,
    'password': password,
  };
  final headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  http.Response response = await http.post(url, headers: headers, body: body);
  return response;
}
