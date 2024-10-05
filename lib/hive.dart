import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
class homepage extends StatefulWidget {
  const homepage({super.key,});
  @override
  State<homepage> createState() => _homepageState();
}
class _homepageState extends State<homepage> {
  static List<Map<String,dynamic>>_bandul=[];
  final TextEditingController _gblar = TextEditingController();
  final TextEditingController _monthlar = TextEditingController();
  final TextEditingController _pricelar = TextEditingController();
  final TextEditingController _typelar = TextEditingController();
Future<void> _createitem(Map<String,dynamic>newitem)async{
  await _bandlebox.add(newitem);
  refresh();
  setState(() {
  });
}
  void _saveItem(int? itemKey) {
    if (_gblar.text.isEmpty ||
        _monthlar.text.isEmpty ||
        _pricelar.text.isEmpty ||
        _typelar.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill the list'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (itemKey == null) {
      _createitem({
        "gb": _gblar.text,
        "price": _pricelar.text,
        "type": _typelar.text,
        "month": _monthlar.text,
      });
    } else {
      _updata(itemKey, {
        "gb": _gblar.text.trim(),
        "price": _pricelar.text.trim(),
        "type": _typelar.text.trim(),
        "month": _monthlar.text.trim(),
      });
    }
    _monthlar.text = "";
    _gblar.text = "";
    _pricelar.text = "";
    _typelar.text = "";

    Navigator.of(context).pop();
}
Future<void> _delete(int itemkey)async{
  await _bandlebox.delete(itemkey);
  refresh();
}
Future<void> _updata(int itemkey,Map<String,dynamic>item)async{
  await _bandlebox.put(itemkey,item);
  refresh();
  setState(() {

  });
}
@override
  void initState() {
    super.initState();
    refresh();
  }
final _bandlebox=Hive.box("bundel_box");
 void refresh(){
   final data=_bandlebox.keys.map((key){
     final item=_bandlebox.get(key);
     return {"key":key,"gb":item["gb"],"price":item["price"],"type":item["type"],"month":item["month"]};
   }).toList();
   setState(() {
     _bandul=data.reversed.toList();
   });
 }

  void _showform(BuildContext ctx, int? itemKye) async {
   if(itemKye !=null){
     final exist=_bandul.firstWhere((_element)=>_element["key"]==itemKye);
     _gblar.text=exist['gb'];
     _monthlar.text=exist['month'];
     _pricelar.text=exist['price'];
     _typelar.text=exist['type'];
   }
    showDialog(context:ctx , builder:(context) {
      return SingleChildScrollView(
        child: AlertDialog(
        title: Text("Add bandle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _gblar,
                decoration: InputDecoration(hintText: "GB"),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _pricelar,
                decoration: InputDecoration(hintText: "Price"),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _typelar,
                decoration: InputDecoration(hintText: "Wirless or cable"),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _monthlar,
                decoration: InputDecoration(hintText: "Month"),
              ),
              SizedBox(
                height: 20,
              ),
             Row(
               children: [
                 ElevatedButton(
                   onPressed: () {
                    _saveItem(itemKye);
                   },
                   child: Text("Save"),
                 ),
                 ElevatedButton(onPressed:(){
                   setState(() {
                     Navigator.of(context).pop();
                   });
                 }, child: Text("Cancel"))
               ],
             )
            ],
          ),
        ),
      );
    },);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: ()=>_showform(context,null),
      child:Icon(Icons.add)
        ,),
      appBar: AppBar(
        title: Text("Bundel List"),
      ),
      body:ListView.builder(
        itemCount: _bandul.length,
        itemBuilder:(context, index) {
          final list=_bandul[index];
        return Card(
          child: ListTile(
          title: Row(children: [Text("GB: ${list["gb"].toString()}"),SizedBox(width: 20,),Text("Month: ${list["month"].toString()}")],),
            subtitle:Row(children: [Text("Type: ${list["type"]}"),SizedBox(width: 20,),Text("Price: ${list["price"].toString()}")],),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed:(){
                  _showform(context,list["key"]);
                }, icon:Icon(Icons.edit,color: Colors.black,)),
                IconButton(onPressed:(){
                  setState(() {
                    _delete(list['key']);
                  });
                }, icon:Icon(Icons.delete,color: Colors.black,)),
              ],
            ),
          ),
        );
      },),
    );
  }
}
