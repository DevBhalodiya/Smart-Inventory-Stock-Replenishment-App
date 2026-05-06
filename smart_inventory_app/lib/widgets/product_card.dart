import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<ProductProvider>(context);

    Color stockColor = Colors.green;

    if (product.quantity <= product.minThreshold) {
      stockColor = Colors.orange;
    }

    if (product.quantity == 0) {
      stockColor = Colors.red;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),

      child: Padding(
        padding: const EdgeInsets.all(8),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "${product.category} | Qty: ${product.quantity}",
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                CircleAvatar(
                  radius: 8,
                  backgroundColor: stockColor,
                ),

                Row(
                  children: [

                    // STOCK IN
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                      ),
                      color: Colors.green,

                      onPressed: () {

                        TextEditingController
                            qtyController =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(

                              title:
                                  const Text(
                                      "Stock In"),

                              content: TextField(
                                controller:
                                    qtyController,

                                keyboardType:
                                    TextInputType
                                        .number,

                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      "Quantity",
                                ),
                              ),

                              actions: [

                                ElevatedButton(
                                  onPressed: () {

                                    int qty =
                                        int.parse(
                                      qtyController
                                          .text,
                                    );

                                    product.quantity +=
                                        qty;

                                    provider
                                        .notifyListeners();

                                    Navigator.pop(
                                        context);

                                    ScaffoldMessenger
                                            .of(
                                                context)
                                        .showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(
                                          "$qty stock added",
                                        ),
                                      ),
                                    );
                                  },
                                  child:
                                      const Text(
                                          "Add"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // STOCK OUT
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle,
                      ),
                      color: Colors.orange,

                      onPressed: () {

                        TextEditingController
                            qtyController =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(

                              title:
                                  const Text(
                                      "Stock Out"),

                              content: TextField(
                                controller:
                                    qtyController,

                                keyboardType:
                                    TextInputType
                                        .number,

                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      "Quantity",
                                ),
                              ),

                              actions: [

                                ElevatedButton(
                                  onPressed: () {

                                    int qty =
                                        int.parse(
                                      qtyController
                                          .text,
                                    );

                                    if (product
                                            .quantity >=
                                        qty) {

                                      product.quantity -=
                                          qty;

                                      provider
                                          .notifyListeners();

                                      Navigator.pop(
                                          context);

                                      ScaffoldMessenger
                                              .of(
                                                  context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(
                                            "$qty items sold",
                                          ),
                                        ),
                                      );

                                    } else {

                                      ScaffoldMessenger
                                              .of(
                                                  context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text(
                                            "Not enough stock",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child:
                                      const Text(
                                          "Remove"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // EDIT
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                    ),

                    // DELETE
                    IconButton(
                      onPressed: onDelete,
                      icon:
                          const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}