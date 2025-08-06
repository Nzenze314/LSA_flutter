import 'package:flutter/material.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: Container(padding: EdgeInsets.all(9),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(spacing: 9,
                children: [
                  Container(
                    width: 200,height: 160,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)),color: Colors.lightBlue),
                  ),
                  Container(
                    width: 200,height: 160,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)),color: Colors.lightBlue),
                  ),
                  Container(
                    width: 200,height: 160,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)),color: Colors.lightBlue),
                  )
                ],
              ),
            ),
            Container(
              child: Text("Featuers:",textAlign: TextAlign.center,),
            )
          ],
        ),
      ),
    );
  }
}