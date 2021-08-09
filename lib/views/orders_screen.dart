import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_widget.dart';

class OrdersScreen extends StatelessWidget {

  Future<void> _refreshProducts(BuildContext context) async {
    return Provider.of<Orders>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Meus Pedidos'),
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: FutureBuilder(
            future: Provider.of<Orders>(context, listen: false).loadOrders(),
            builder: (ctx, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                ),
                                Text(
                                  'Carregando...',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor
                                  ),
                                )
                              ],
                      )
                   );
              }else if(snapshot.error != null){
                return Center(child: Text('Ocorreu um erro: ${snapshot.error}'));
              }else{
                return Consumer<Orders>(
                  builder: (ctx, orders, child) {
                    return ListView.builder(
                        itemCount: orders.itemsCount,
                        itemBuilder: (ctx, index) {
                          return OrderWidget(orders.items[index]);
                        }
                    );
                  },
                );
              }
            },
        ),
      )
    );
  }
}
