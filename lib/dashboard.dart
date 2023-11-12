import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// check token work or not
class Dashboard extends StatefulWidget {
  // first cerate token variable::
  final token;
  const Dashboard({super.key, required this.token});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String email;
  @override
  void initState() {
    super.initState();
    try {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      email = jwtDecodedToken['email'];
    } catch (e) {
      // Decode hatası gibi hataları işleyin, örneğin, geçersiz token formatı
      print('Token çözme hatası: $e');
      // Hata sayfasına yönlendirmek veya farklı bir şekilde işlemek isteyebilirsiniz
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(email)],
        ),
      ),
    );
  }
}
