import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {

  final Product product;

  ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final scaffold =  ScaffoldMessenger.of(context);

    return ListTile(
       leading: CircleAvatar(
         backgroundImage: NetworkImage(product.imageUrl),
       ),
       title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: (){
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                  arguments: product
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context){

                        return AlertDialog(
                          title: Text('Excluir Produto'),
                          content: Text('Deseja realmente excluír?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Não')
                            ),
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Sim')
                            )
                          ],
                        );
                      }
                  ).then((value) async {
                    if(value){
                      try{
                        await Provider.of<Products>(context, listen: false).deleteProduct(product.id);
                      } on HttpException catch(error){
                        scaffold.showSnackBar(
                          SnackBar(
                              content: Text(error.toString()),
                          )
                        );
                      }
                    }
                  });

              },
            )
          ],
        ),
      ),
    );
  }
}
