import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/product_item.dart';

class ProductsScreen extends StatelessWidget {

  Future<void> _refreshProducts(BuildContext context) async {
    return Provider.of<Products>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = productsData.items;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Gerenciar Produtos'),
        actions: [
          IconButton(
              onPressed: (){
                  Navigator.of(context).pushNamed(
                      AppRoutes.PRODUCT_FORM
                  );
              },
              icon: const Icon(Icons.add)
          )
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child:  Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
              itemCount: productsData.itemsCount,
              itemBuilder: (ctx, index) => Column(
                children: [
                   ProductItem(products[index]),
                   Divider()
                ],
              ),
          ),
        ),
      ),
    );
  }
}
