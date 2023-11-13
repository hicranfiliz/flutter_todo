import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

// check token work or not
class Dashboard extends StatefulWidget {
  // first cerate token variable::
  final token;
  const Dashboard({super.key, required this.token});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String userId;
  TextEditingController _todoTitle = TextEditingController();
  TextEditingController _todoDesc = TextEditingController();
  @override
  void initState() {
    super.initState();
    try {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      userId = jwtDecodedToken['_id'];
    } catch (e) {
      // Decode hatası gibi hataları işleyin, örneğin, geçersiz token formatı
      print('Token cozme hatasi: $e');
      // Hata sayfasına yönlendirmek veya farklı bir şekilde işlemek isteyebilirsiniz
    }
  }

  void addTodo() async {
    if (_todoTitle.text.isNotEmpty && _todoDesc.text.isNotEmpty) {
      var reqBody = {
        "userId": userId,
        "title": _todoTitle.text,
        "desc": _todoDesc.text
      };

      Dio dio = Dio();
      try {
        Response response = await dio.post(
          addtodo,
          options: Options(
            headers: {"Content-Type": "application/json"},
          ),
          data: reqBody,
        );

        var jsonResponse = response.data;

        print(jsonResponse['status']);

        if (jsonResponse['status']) {
          _todoDesc.clear();
          _todoTitle.clear();
          Navigator.pop(context);
        } else {
          print("Something Went Wrong");
        }
      } catch (e) {
        print("Bağlanti hatasi: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(userId)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTextInputDialog(context),
        tooltip: "Add-ToDo",
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add To-Do"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _todoTitle,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "title",
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ).p4().px8(),
                TextField(
                  controller: _todoDesc,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Description",
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ).p4().px8(),
                ElevatedButton(
                    onPressed: () {
                      addTodo();
                    },
                    child: const Text("Add"))
              ],
            ),
          );
        });
  }
}
