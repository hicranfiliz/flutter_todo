import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  late String _userEmail;
  TextEditingController _todoTitle = TextEditingController();
  TextEditingController _todoDesc = TextEditingController();
  List? items;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    // get userId and userEmail
    userId = jwtDecodedToken['_id'];
    _userEmail = jwtDecodedToken['email'];
    getToDoList(userId);
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
          getToDoList(userId);
        } else {
          print("Something Went Wrong");
        }
      } catch (e) {
        print("Bağlanti hatasi: $e");
      }
    }
  }

  void getToDoList(userId) async {
    var reqBody = {"userId": userId};
    Dio dio = Dio();
    try {
      var response = await dio.get(getTodoList,
          options: Options(headers: {"Content-Type": "application/json"}),
          data: reqBody);

      print('HTTP durum kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        //var items = jsonResponse['success'];
        var uploadedItems = jsonResponse['success'];

        // UI güncellemek için setState()
        setState(() {
          // Kullanıcı arayüzünü güncellemek için items'i kullanın
          items = uploadedItems;
        });
      } else {
        print('Hata: ${response.statusCode}');
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }

  void deleteItem(id) async {
    var reqBody = {"id": id};

    var response = await http.post(Uri.parse(deleteTodo),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getToDoList(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 60.0, left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.list, size: 30)),
                const SizedBox(height: 10),
                const Text('5 Task', style: TextStyle(fontSize: 20)),
                Text(
                  _userEmail,
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
          Expanded(
              child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: items == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: items!.length,
                      itemBuilder: (context, int index) {
                        return Slidable(
                          key: const ValueKey(0),
                          endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(onDismissed: () {}),
                              children: [
                                SlidableAction(
                                    backgroundColor: Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: "Delete",
                                    onPressed: (BuildContext context) {
                                      print('${items![index]['_id']}');
                                      deleteItem('${items![index]['_id']}');
                                    })
                              ]),
                          child: Card(
                            borderOnForeground: false,
                            child: ListTile(
                              leading: Icon(Icons.task),
                              title: Text('${items![index]['title']}'),
                              subtitle: Text('${items![index]['desc']}'),
                              trailing: Icon(Icons.arrow_back),
                            ),
                          ),
                        );
                      }),
            ),
          ))
        ],
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
