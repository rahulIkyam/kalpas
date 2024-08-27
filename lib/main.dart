import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kalpas/detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalpas',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  bool isLoading = true;

  List<dynamic> articles = [];
  List<dynamic> favoriteArticles = [];
  Future<void> getNewsData() async{
    String url = "https://newsapi.org/v2/everything?q=apple&from=2024-08-26&to=2024-08-26&sortBy=popularity&apiKey=1deac38c15b84d52905c1b9d96a1d9f6";
    try{
      final response = await http.get(
        Uri.parse(url),
        // headers: {
        //     "Content-Type" : "application/json"
        // }
      );
      if(response.statusCode == 200){
        setState(() {
          isLoading = false;
        });
        Map<String, dynamic> data = json.decode(response.body);
         articles = data['articles'];
        // print(articles);
        // for(var article in articles){
        //   print(article['urlToImage']);
        // }
      }else{
        print("Failed to fetch Data: ${response.statusCode}");
      }
    }catch(e){
      print('----- e ------');
      print("Error in fetching data: $e");
    }

  }
  @override
  void initState() {
    super.initState();
    getNewsData();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: TabBar(
            controller: _tabController,
            padding: const EdgeInsets.only(left: 20, right: 20),
            tabs: const [
              Tab(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.menu,color: Colors.black),
                    ),
                    Text("News",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.favorite,color: Colors.red),
                    ),
                    Text("Favs",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
                  ],
                ),
              )
            ]
        ),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(),) : TabBarView(
          controller: _tabController,
          children:  [
            buildMenuCard(),
            buildFavoriteCard(),
          ]
      ),
    );
  }


  Widget buildMenuCard(){
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        DateTime publishedDate = DateTime.parse(articles[index]['publishedAt']);
        String formattedDate = "${DateFormat("EEE, dd MM yyyy HH:mm").format(publishedDate)} GMT";
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 10),
            child: Dismissible(
              key: Key(articles[index]['author']),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {
                  favoriteArticles.add(articles[index]);
                  articles.removeAt(index);
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.favorite, color: Colors.white,),
              ),
              child: InkWell(
                onTap: () {
                  Map data = {
                    "author": articles[index]['author'] ?? "",
                    "title": articles[index]['title'] ?? "",
                    "description": articles[index]['description'] ?? "",
                    "content": articles[index]['content'] ?? "",
                    "image": articles[index]['urlToImage'] ?? "",
                    "date": formattedDate,
                    "fromTab": "MenuTab",
                  };
                  Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(data: data,),));
                },
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                        color: const Color(0xff9FB3C8).withOpacity(0.8),
                        width: 1
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(articles[index]["urlToImage"] != null)
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.network(
                                articles[index]["urlToImage"],
                                width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 50,);
                              },
                            )
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SizedBox(
                            height: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(articles[index]['author']??"",style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(articles[index]['title']??"",style: const TextStyle(fontSize: 12)),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 2),
                                      child: Icon(Icons.calendar_month, size: 12),
                                    ),
                                    Text(formattedDate, style: const TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      );
    },);
  }

  Widget buildFavoriteCard() {
    return ListView.builder(
      itemCount: favoriteArticles.length,
      itemBuilder: (context, index) {
        DateTime publishedDate = DateTime.parse(favoriteArticles[index]['publishedAt']);
        String formattedDate = "${DateFormat("EEE, dd MM yyyy HH:mm").format(publishedDate)} GMT";

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 10),
              child: InkWell(
                onTap: () {
                  Map data = {
                    "author": favoriteArticles[index]['author'] ?? "",
                    "title": favoriteArticles[index]['title'] ?? "",
                    "description": favoriteArticles[index]['description'] ?? "",
                    "content": favoriteArticles[index]['content'] ?? "",
                    "image": favoriteArticles[index]['urlToImage'] ?? "",
                    "date": formattedDate,
                    "fromTab": "FavTab",
                  };
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(data: data),
                  ));
                },
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                      color: const Color(0xff9FB3C8).withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (favoriteArticles[index]["urlToImage"] != null)
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.network(
                              favoriteArticles[index]["urlToImage"],
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 50);
                              },
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SizedBox(
                            height: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(favoriteArticles[index]['author'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(favoriteArticles[index]['title'] ?? "", style: const TextStyle(fontSize: 12)),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 2),
                                      child: Icon(Icons.calendar_month, size: 12),
                                    ),
                                    Text(formattedDate, style: const TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

