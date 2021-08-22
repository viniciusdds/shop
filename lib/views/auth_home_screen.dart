import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/views/auth_screen.dart';
import 'package:shop/views/products_overview_screen.dart';

class AuthOrHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(context);
    return FutureBuilder(
      future: auth.tryAutoLogin(),
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
          return auth.isAuth ? ProductsOverviewScreen() : AuthScreen();
        }
      },
    );
  }
}
