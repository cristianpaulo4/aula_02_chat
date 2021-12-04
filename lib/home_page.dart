import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hasura_connect/hasura_connect.dart';

class HomePage extends StatefulWidget {
  final String usuario;
  const HomePage({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();

  HasuraConnect hasuraConnect = HasuraConnect(
    "https://aula-02-chat.herokuapp.com/v1/graphql",
  );

  String doQuery = """
    subscription listaDeMensagem {
      mensagens(order_by: {id: desc}) {
        id
        usuario
        mensagem
      }
    }
  """;

  StreamController<List> _mensagem = StreamController.broadcast();

  @override
  void initState() {
    _listaMesagem();
    super.initState();
  }

  _listaMesagem() async {
    Snapshot snapshot = await hasuraConnect.subscription(doQuery);
    snapshot.listen((data) {
      var listMesagem = data['data']['mensagens'];
      _mensagem.add(
        listMesagem,
      );
    }).onError((err) {
      print(err);
    });
  }

  _enviarMesagem(String msg) async {
    String docQuery = """
      mutation enviarMensagem {
        insert_mensagens(objects: {usuario: "${widget.usuario}", mensagem: "$msg"}) {
          affected_rows
        }
      }
    """;

    await hasuraConnect.mutation(docQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, ${widget.usuario}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: StreamBuilder<List>(
                stream: _mensagem.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    reverse: true,
                    itemBuilder: (context, i) {
                      var msg = snapshot.data!.elementAt(i);

                      return _balaoMsg(
                        msg["mensagem"],
                        msg["usuario"],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Digite sua mensagem...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _enviarMesagem(controller.text);
                      controller.clear();
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balaoMsg(String msg, String usuario) {
    bool usuarioLogado = usuario == widget.usuario;

    return Container(
      margin: const EdgeInsets.all(10),
      width: 250,
      child: Align(
        alignment: usuarioLogado ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: usuarioLogado
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                usuario,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: usuarioLogado ? Colors.teal.shade800 : Colors.teal.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
