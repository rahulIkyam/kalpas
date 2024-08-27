import 'package:flutter/material.dart';
import 'package:kalpas/main.dart';

class DetailScreen extends StatefulWidget {
  final Map data;
   const DetailScreen({
    required this.data,
    super.key
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('------- from tab -----');
    print(widget.data['fromTab']);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading:  InkWell(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(),));
          },
          child: const Icon(Icons.arrow_back_ios, size: 10, color: Colors.black,),
        ),
        title: Text(widget.data['author'],style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      widget.data['image'],
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50,);
                      },
                    )
                ),
                if(widget.data['fromTab'] == "FavTab")
                  const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 24,
                      )
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text(widget.data['author'],style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 2),
              child: Text(widget.data['date'], style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
            ),
            Text(widget.data['description'], style: const TextStyle(fontSize: 14)),
            Text(widget.data['content'], style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
