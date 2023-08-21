import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Signin.dart';

class MySignupPage extends StatefulWidget {
  const MySignupPage({Key? key}) : super(key: key);

  @override
  State<MySignupPage> createState() => _MySignupPageState();
}

class _MySignupPageState extends State<MySignupPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController groupController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String username = usernameController.text;
      String email = emailController.text;
      String firstName = firstnameController.text;
      String lastName = lastnameController.text;
      String password = passwordController.text;
      String group = groupController.text;

      try {
        // Send the user data to the server
        http.Response response = await createAlbum(
          username,
          email,
          firstName,
          lastName,
          password,
          group,
        );
        // Print the status code from the response
        print('Status Code: ${response.statusCode}');

        // Check if the POST request was successful
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Print a success message
          print('You created an account successfully!');
          // Show a Snackbar for user feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You created an account successfully!')),
          );
          // Navigate to the MyLoginPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MyLoginPage(title: 'Login page')),
          );
        } else {
          // Handle other status codes if necessary
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      } catch (e) {
        // Show error message if something went wrong
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting the form')),
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
          title: const Text("Sign up"),
        ),
        body: SingleChildScrollView(
          child: Form(
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
                        border: OutlineInputBorder(),
                        labelText: "username",
                      ),
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
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: firstnameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "First name",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: lastnameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Last name",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
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
                        border: OutlineInputBorder(),
                        labelText: "Password",
                      ),
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: groupController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "group",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your group';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
                  const Text("If you already have an account, click here:"),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the signup.dart page when the button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyLoginPage(title: 'Login page')),
                      );
                    },
                    child: const Text('Log in'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

Future<http.Response> createAlbum(String username, String email,
    String firstName, String lastName, String password, String group) async {
  http.Response response = await http.post(
    Uri.parse('http://196.179.229.162:8000/v0.1/users/create'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "username": username,
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
      "group": group,
    }),
  );
  return response;
}
