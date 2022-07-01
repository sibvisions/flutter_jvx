import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: //Center(child: CircularProgressIndicator.adaptive()),
            Stack(
      children: [
        Container(
          decoration:
              const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/bg.png'), fit: BoxFit.cover)),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Center(
                child: Image.asset(
                  'assets/images/ss.png',
                  width: 135,
                ),
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const <Widget>[
              Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator()),
              Padding(padding: EdgeInsets.only(top: 100), child: Text('Loading...'))
            ],
          )
        ])
      ],
    ));
  }
}
