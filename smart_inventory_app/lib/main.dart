import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const MyApp(),
    ),
  );
}

////////////////////////////////////////////////////////////////
/// PRODUCT MODEL
////////////////////////////////////////////////////////////////

class Product {
  String id;
  String name;
  String category;
  int quantity;
  int minThreshold;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minThreshold,
  });
}

////////////////////////////////////////////////////////////////
/// STOCK RECORD MODEL
////////////////////////////////////////////////////////////////

class StockRecord {
  final String id;
  final String productId;
  final int amount;
  final bool isIn;
  final DateTime date;

  StockRecord({
    required this.id,
    required this.productId,
    required this.amount,
    required this.isIn,
    required this.date,
  });
}

////////////////////////////////////////////////////////////////
/// PROVIDER
////////////////////////////////////////////////////////////////

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];

  final List<StockRecord> _records = [];

  List<Product> get products => _products;

  List<StockRecord> get records => _records;

  ////////////////////////////////////////////////////////////////
  /// ADD PRODUCT
  ////////////////////////////////////////////////////////////////

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////
  /// DELETE PRODUCT
  ////////////////////////////////////////////////////////////////

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////
  /// STOCK IN
  ////////////////////////////////////////////////////////////////

  void stockIn(String productId, int amount) {
    final product = _products.firstWhere(
      (e) => e.id == productId,
    );

    product.quantity += amount;

    _records.insert(
      0,
      StockRecord(
        id: DateTime.now().toString(),
        productId: productId,
        amount: amount,
        isIn: true,
        date: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////
  /// STOCK OUT
  ////////////////////////////////////////////////////////////////

  void stockOut(String productId, int amount) {
    final product = _products.firstWhere(
      (e) => e.id == productId,
    );

    if (product.quantity >= amount) {
      product.quantity -= amount;

      _records.insert(
        0,
        StockRecord(
          id: DateTime.now().toString(),
          productId: productId,
          amount: amount,
          isIn: false,
          date: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////
  /// LOW STOCK COUNT
  ////////////////////////////////////////////////////////////////

  int get lowStockCount {
    return _products
        .where(
          (p) => p.quantity <= p.minThreshold,
        )
        .length;
  }
}

////////////////////////////////////////////////////////////////
/// MAIN APP
////////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Smart Inventory App',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const HomeScreen(),
    );
  }
}

////////////////////////////////////////////////////////////////
/// HOME SCREEN
////////////////////////////////////////////////////////////////

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  ////////////////////////////////////////////////////////////////
  /// ADD PRODUCT DIALOG
  ////////////////////////////////////////////////////////////////

  void showAddProductDialog() {

    TextEditingController nameController =
        TextEditingController();

    TextEditingController categoryController =
        TextEditingController();

    TextEditingController quantityController =
        TextEditingController();

    TextEditingController thresholdController =
        TextEditingController();

    final provider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(

          title: const Text("Add Product"),

          content: SingleChildScrollView(
            child: Column(
              children: [

                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Product Name",
                  ),
                ),

                TextField(
                  controller:
                      categoryController,
                  decoration:
                      const InputDecoration(
                    labelText: "Category",
                  ),
                ),

                TextField(
                  controller:
                      quantityController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText: "Quantity",
                  ),
                ),

                TextField(
                  controller:
                      thresholdController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Minimum Threshold",
                  ),
                ),
              ],
            ),
          ),

          actions: [

            ElevatedButton(
              onPressed: () {

                provider.addProduct(
                  Product(
                    id: DateTime.now()
                        .toString(),

                    name:
                        nameController.text,

                    category:
                        categoryController
                            .text,

                    quantity: int.parse(
                      quantityController
                          .text,
                    ),

                    minThreshold:
                        int.parse(
                      thresholdController
                          .text,
                    ),
                  ),
                );

                Navigator.pop(context);
              },

              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////////
  /// STOCK UPDATE DIALOG
  ////////////////////////////////////////////////////////////////

  void showStockDialog(
    Product product,
    bool isIn,
  ) {

    TextEditingController qtyController =
        TextEditingController();

    final provider =
        Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(

          title: Text(
            isIn
                ? "Stock In"
                : "Stock Out",
          ),

          content: TextField(
            controller: qtyController,

            keyboardType:
                TextInputType.number,

            decoration:
                const InputDecoration(
              labelText:
                  "Enter Quantity",
            ),
          ),

          actions: [

            ElevatedButton(
              onPressed: () {

                int qty = int.parse(
                  qtyController.text,
                );

                //////////////////////////////////////////////////
                /// STOCK IN
                //////////////////////////////////////////////////

                if (isIn) {

                  provider.stockIn(
                    product.id,
                    qty,
                  );

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        "$qty items added",
                      ),
                    ),
                  );
                }

                //////////////////////////////////////////////////
                /// STOCK OUT
                //////////////////////////////////////////////////

                else {

                  if (product.quantity >=
                      qty) {

                    provider.stockOut(
                      product.id,
                      qty,
                    );

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          "$qty items sold",
                        ),
                      ),
                    );
                  }

                  else {

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Not enough stock",
                        ),
                      ),
                    );
                  }
                }

                Navigator.pop(context);
              },

              child: const Text(
                "Confirm",
              ),
            ),
          ],
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////////
  /// BUILD
  ////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<ProductProvider>(
      context,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Smart Inventory App",
        ),

        actions: [

          IconButton(
            icon:
                const Icon(Icons.history),

            onPressed: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),

      //////////////////////////////////////////////////////////////
      /// BODY
      //////////////////////////////////////////////////////////////

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            ////////////////////////////////////////////////////////
            /// DASHBOARD CARD
            ////////////////////////////////////////////////////////

            Card(
              color: Colors.blue,

              child: ListTile(

                title: const Text(
                  "Total Products",

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                subtitle: Text(
                  provider.products.length
                      .toString(),

                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            ////////////////////////////////////////////////////////
            /// LOW STOCK CARD
            ////////////////////////////////////////////////////////

            Card(
              color: Colors.orange,

              child: ListTile(

                title: const Text(
                  "Low Stock Products",

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                subtitle: Text(
                  provider.lowStockCount
                      .toString(),

                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ////////////////////////////////////////////////////////
            /// PRODUCT LIST
            ////////////////////////////////////////////////////////

            Expanded(

              child: provider.products.isEmpty

                  ? const Center(
                      child: Text(
                        "No Products Added",
                      ),
                    )

                  : ListView.builder(

                      itemCount:
                          provider.products
                              .length,

                      itemBuilder:
                          (context, index) {

                        final product =
                            provider.products[
                                index];

                        ////////////////////////////////////////////////////
                        /// STOCK COLOR
                        ////////////////////////////////////////////////////

                        Color stockColor =
                            Colors.green;

                        if (product.quantity <=
                                product
                                    .minThreshold &&
                            product.quantity >
                                0) {

                          stockColor =
                              Colors.orange;
                        }

                        if (product.quantity ==
                            0) {

                          stockColor =
                              Colors.red;
                        }

                        ////////////////////////////////////////////////////
                        /// PRODUCT CARD
                        ////////////////////////////////////////////////////

                        return Card(

                          elevation: 4,

                          child: ListTile(

                            title: Text(
                              product.name,
                            ),

                            subtitle: Text(
                              "${product.category} | Qty: ${product.quantity}",
                            ),

                            trailing: Row(

                              mainAxisSize:
                                  MainAxisSize
                                      .min,

                              children: [

                                //////////////////////////////////////////////////
                                /// STOCK OUT
                                //////////////////////////////////////////////////

                                IconButton(

                                  icon:
                                      const Icon(
                                    Icons
                                        .remove_circle,
                                    color:
                                        Colors.red,
                                  ),

                                  onPressed: () {

                                    showStockDialog(
                                      product,
                                      false,
                                    );
                                  },
                                ),

                                //////////////////////////////////////////////////
                                /// STOCK IN
                                //////////////////////////////////////////////////

                                IconButton(

                                  icon:
                                      const Icon(
                                    Icons
                                        .add_circle,
                                    color: Colors
                                        .green,
                                  ),

                                  onPressed: () {

                                    showStockDialog(
                                      product,
                                      true,
                                    );
                                  },
                                ),

                                //////////////////////////////////////////////////
                                /// STOCK STATUS
                                //////////////////////////////////////////////////

                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor:
                                      stockColor,
                                ),

                                //////////////////////////////////////////////////
                                /// DELETE
                                //////////////////////////////////////////////////

                                IconButton(

                                  icon:
                                      const Icon(
                                    Icons.delete,
                                  ),

                                  onPressed: () {

                                    provider
                                        .deleteProduct(
                                      product.id,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      //////////////////////////////////////////////////////////////
      /// ADD BUTTON
      //////////////////////////////////////////////////////////////

      floatingActionButton:
          FloatingActionButton(

        child: const Icon(Icons.add),

        onPressed: () {

          showAddProductDialog();
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// HISTORY SCREEN
////////////////////////////////////////////////////////////////

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<ProductProvider>(
      context,
    );

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Stock History"),
      ),

      body: provider.records.isEmpty

          ? const Center(
              child: Text(
                "No Stock History",
              ),
            )

          : ListView.builder(

              itemCount:
                  provider.records.length,

              itemBuilder:
                  (context, index) {

                final record =
                    provider.records[index];

                final product =
                    provider.products
                        .firstWhere(
                  (p) =>
                      p.id ==
                      record.productId,
                );

                return ListTile(

                  leading: Icon(

                    record.isIn
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,

                    color: record.isIn
                        ? Colors.green
                        : Colors.red,
                  ),

                  title: Text(
                    product.name,
                  ),

                  subtitle: Text(
                    "${record.isIn ? "Stock In" : "Stock Out"} | Qty: ${record.amount}",
                  ),
                );
              },
            ),
    );
  }
}