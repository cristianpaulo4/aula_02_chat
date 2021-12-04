import 'package:chat_aula/home_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuario_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Card(
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: usuario_controller,
                    decoration: const InputDecoration(
                      label: Text("Usuário"),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      if (usuario_controller.text.isNotEmpty) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return HomePage(usuario: usuario_controller.text);
                          },
                        ));
                      }
                    },
                    label: const Text("Entrar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
