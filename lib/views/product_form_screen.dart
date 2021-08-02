import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if(_formData.isEmpty){
      final product = ModalRoute.of(context).settings.arguments as Product;
      if(product != null){
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['description'] = product.description;
        _formData['price'] = product.price;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlController.text =  _formData['imageUrl'];
      }else{
        _formData['price'] = '';
      }
    }
  }

  void _updateImage(){
    if(isValidImageUrl(_imageUrlController.text)){
      setState(() {});
    }
  }

  bool isValidImageUrl(String url){

    bool startWithHttp = url.toLowerCase().startsWith('http://');
    bool startWithHttps = url.toLowerCase().startsWith('https://');
    bool endsWithPng = url.toLowerCase().endsWith('.png');
    bool endsWithJpg = url.toLowerCase().endsWith('.jpg');
    bool endsWithJpeg = url.toLowerCase().endsWith('.jpeg');

    return (startWithHttp || startWithHttps) && (endsWithPng || endsWithJpg || endsWithJpeg);
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImage);
    _imageUrlFocusNode.dispose();
  }

  Future<void> _saveForm() async {

    var isValid = _formKey.currentState.validate();

    if(!isValid){
      return;
    }

    _formKey.currentState.save();

    final product = Product(
      id: _formData['id'],
      title: _formData['title'],
      price: _formData['price'],
      description: _formData['description'],
      imageUrl: _formData['imageUrl']
    );

    setState(() {
      _isLoading = true;
    });

    final products = Provider.of<Products>(context, listen: false);
      try{
        if(_formData['id'] == null) {
          await products.addProduct(product);
        }else {
          await products.updateProduct(product);
        }
        Navigator.of(context).pop();
      }catch(error){
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Ocorreu um erro!'),
              content: Text('Ocorreu um erro para salvar o produto!'),
              actions: [
                TextButton(
                  child: Text('Fechar'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            )
        );
      }finally{
        setState(() {
          _isLoading = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            'Formulário Produto'
        ),
        actions: [
          IconButton(
              onPressed: (){
                _saveForm();
              },
              icon: Icon(Icons.save)
          )
        ],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _formData['title'],
                decoration: InputDecoration(
                  labelText: 'Título'
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) => _formData['title'] = value,
                validator: (value){
                  bool isEmpty = value.trim().isEmpty;
                  bool isInvalid = value.trim().length < 3;

                  if(isEmpty){
                    return 'Informe um título válido';
                  }else if(isInvalid){
                    return 'Informe um título no mínimo com 3 caracteres';
                  }else{
                    return null;
                  }
                },
              ),
              TextFormField(
                initialValue: _formData['price'].toString(),
                decoration: InputDecoration(
                    labelText: 'Preço'
                ),
                textInputAction: TextInputAction.next,
                focusNode: _priceFocusNode,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true
                ),
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) => _formData['price'] = double.parse(value),
                validator: (value){
                    bool isEmpty = value.trim().isEmpty;
                    var newPrice = double.tryParse(value);
                    bool isInvalid = newPrice == null || newPrice <= 0;

                    if(isEmpty || isInvalid){
                      return 'Informe um preço válido';
                    }

                    return null;
                },
              ),
              TextFormField(
                initialValue: _formData['description'],
                decoration: InputDecoration(
                    labelText: 'Descrição'
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value) => _formData['description'] = value,
                validator: (value){
                  bool isEmpty = value.trim().isEmpty;
                  bool isInvalid = value.trim().length < 10;

                  if(isEmpty){
                    return 'Informe uma descrição válido';
                  }else if(isInvalid){
                    return 'Informe uma descrição no mínimo com 10 caracteres';
                  }else{
                    return null;
                  }
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'URL da Imagem'
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      focusNode: _imageUrlFocusNode,
                      controller: _imageUrlController,
                      onFieldSubmitted: (_){
                        _saveForm();
                      },
                      onSaved: (value) => _formData['imageUrl'] = value,
                      validator: (value){
                        bool isEmpty = value.trim().isEmpty;
                        bool isInvalid = !isValidImageUrl(value);

                        if(isEmpty || isInvalid){
                          return 'Informe uma URL válida';
                        }else{
                          return null;
                        }
                      },
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.only(
                      top: 8,
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _imageUrlController.text.isEmpty
                        ? Text('Informe a URL')
                        : SizedBox.expand(
                          child: FittedBox(
                      child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                      ),
                    ),
                        ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
