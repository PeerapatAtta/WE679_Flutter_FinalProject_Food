import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_aboutme/main.dart';
import 'package:my_aboutme/product_form_create.dart';
import 'package:my_aboutme/product_update.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final dio = Dio();
  final baseApi = "https://testpos.trainingzenter.com/lab_dpu/food/";
  late List productList = [];
  //Color color1 = const Color.fromARGB(255, 29, 117, 32);

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  Future<void> getProduct() async {
    try {
      await dio
          .get("${baseApi}/list/66130151_66130413?format=json",
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ))
          .then((response) {
        if (response.statusCode == 200) {
          if (mounted) {
            // เช็คว่า Widget ยังคง mounted อยู่หรือไม่
            setState(() {
              productList = response.data!;
            });
          }
        }
      });
    } catch (e) {
      if (!context.mounted) return;
    }
  }

  Future<void> productDelete(productId) async {
    try {
      await dio
          .delete("${baseApi}/update/$productId",
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ))
          .then((response) => {Navigator.pop(context, 'Cancle'), getProduct()});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    print(productList);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color2,
        title: Text('Menu'),
        shape: Border(bottom: BorderSide(color: Colors.grey[400]!, width: 2)),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductFromCreate()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color1,
                  ),
                  child: Text(
                    'Add Menu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: productList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Image.network(productList[index]["food_cover"]),
                      ListTile(
                        leading: Icon(Icons.arrow_drop_down_circle),
                        title: Text(productList[index]["food_name"]),
                        subtitle: Text(
                            'Price: ${productList[index]["food_price"]} THB'),
                      ),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              "Updated Date ${productList[index]["update_date"]}")),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text("Delete Data"),
                                content: Text(
                                    "Delete ${productList[index]["food_name"]}"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancle'),
                                      child: Text("Cancle")),
                                  TextButton(
                                      onPressed: () => {
                                            productDelete(
                                                productList[index]["food_id"])
                                          },
                                      child: Text("OK")),
                                ],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductUpdate(
                                            productId: productList[index]
                                                    ["food_id"]
                                                .toString(),
                                          )));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color1,
                            ),
                            child: Text(
                              'Update',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductDetail(
                                            productName: productList[index]
                                                ["food_name"],
                                            productCover: productList[index]
                                                ["food_cover"],
                                            productDescription:
                                                productList[index]
                                                    ["food_description"],
                                            productPrice: productList[index]
                                                ["food_price"],
                                          )));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color1,
                            ),
                            child: Text(
                              'More Detail',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: color1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: 1,
        items: bottomNavItems(),
        onTap: (index) => (),
      ),
    );
  }

  List<BottomNavigationBarItem> bottomNavItems() {
    var itemIcons = [
      Icons.home,
      Icons.coffee,
      Icons.shopping_cart,
      Icons.menu,
    ];
    var itemLabels = [
      'Home',
      'Menu',
      'Cart',
      'Setting',
    ];

    return List.generate(
        itemIcons.length,
        (index) => BottomNavigationBarItem(
              icon: Icon(itemIcons[index]),
              label: itemLabels[index],
            ));
  }
}

class ProductDetail extends StatefulWidget {
  const ProductDetail({
    super.key,
    required this.productName,
    required this.productCover,
    required this.productDescription,
    required this.productPrice,
  });
  final String productName;
  final String productCover;
  final String productDescription;
  final String productPrice;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: color2,
          title: Text(widget.productName),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.network(widget.productCover),
                  ListTile(
                    title: Text(widget.productName),
                    subtitle: Text(widget.productDescription),
                  ),
                  Text(
                    'Price: ${widget.productPrice} THB',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
