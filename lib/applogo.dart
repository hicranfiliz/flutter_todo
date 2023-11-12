import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CommonLogo extends StatelessWidget {
  const CommonLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.network(
          "https://picsum.photos/200/300",
          width: 100,
        ),
        "To - Do App".text.xl2.italic.make(),
        "Make a List Of Your Task".text.light.white.wider.lg.make()
      ],
    );
  }
}
