import 'package:customer/hive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
class Myapp extends StatefulWidget {
  const Myapp({super.key});
  @override
  State<Myapp> createState() => _MyappState();
}
class _MyappState extends State<Myapp> {
  Database? _database;
  List<Map<String, dynamic>> bundelItems = [];
  List<Map<String, dynamic>> customer = [];
  TextEditingController gbcontroller = TextEditingController();
  TextEditingController monthcontroller = TextEditingController();
  bool _searching = false;
  TextEditingController searchlar = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadbandle();
  }
  Future<void> _initDatabase() async {
    String path = await getDatabasesPath();
    _database = await openDatabase(
      "$path/customer.db",
      onCreate: (db, version) {
       return db.execute(
            "CREATE TABLE customer(id INTEGER PRIMARY KEY, name TEXT, lastname TEXT, number TEXT, address TEXT, type TEXT, bundle TEXT, price TEXT,serialnumber TEXT )");
      },
      version: 1,
    );
    _refreash();
    _loadbandle();
  }
  void _loadbandle(){
    final box = Hive.box("bundel_box");
    final data = box.keys.map((key) {
      final item = box.get(key);
      return {
        "key": key,
        "gb": item["gb"],
        "price": item["price"],
        "type": item["type"],
        "month": item["month"],
      };
    }).toList();

    setState(() {
      bundelItems = data.reversed.toList();
    });
  }
  Future<void> _refreash() async {
    final custom = await _database!.query("customer");
    setState(() {
      customer = custom;
    });
  }
  Future<void> _addcustomer(
    TextEditingController namelar,
    TextEditingController lastlar,
    TextEditingController numberlar,
    TextEditingController adresslar,
    TextEditingController typelar,
    TextEditingController bundellar,
    TextEditingController pricelar,
    TextEditingController idler,
  ) async {
    final String name = namelar.text.trim();
    final String lastname = lastlar.text.trim();
    final String number = numberlar.text.trim();
    final String address = adresslar.text.trim();
    final String type = typelar.text.trim();
    final String bundel = bundellar.text.trim();
    final String price = pricelar.text.trim();
    final String iid = idler.text.trim();
    if (name.isEmpty ||
        lastname.isEmpty ||
        number.isEmpty ||
        address.isEmpty ||
        type.isEmpty ||
        bundel.isEmpty ||
        iid.isEmpty ||
        price.isEmpty) {
      return;
    }
    await _database!.insert('customer',
        {'name': name,
      'lastname': lastname,
      'number': number,
      'address': address,
      'type': type,
      'bundle': bundel,
      'price': price,
      'serialnumber': iid
    });
    _refreash();
  }
  Future<void> _delete(int id) async {
    await _database!.delete('customer', where: 'id=?',whereArgs: [id]);
    _refreash();
  }
  Future<void> _update(
      int id,
      String name,
      String lastname,
      String number,
      String address,
      String type,
      String bundel,
      String price,
      String iid) async {
    await _database!.update(
        'customer',
        {
          'name': name,
          'lastname': lastname,
          'number': number,
          'address': address,
          'type': type,
          'bundle': bundel,
          'price': price,
          'serialnumber': iid
        },
        where: "id=?",
        whereArgs: [id]);
    _refreash();
  }

  Future<void> _callcustomer(String number) async {
    final Uri launcher = Uri(scheme: 'tel', path: number);
    await launchUrl(launcher);
  }
  Future<void> _searchcustomer(String query) async {
    final custom = await _database!.query(
      'customer',
      where: 'name LIKE ? OR lastname LIKE ? OR number LIKE ? OR serialnumber LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
    setState(() {
      customer = custom;
    });
  }

  void _showdialog({Map<String, dynamic>? custom}) {
    final namelar = TextEditingController(text: custom?['name'] ?? "");
    final lastlar = TextEditingController(text: custom?['lastname'] ?? "");
    final numberlar = TextEditingController(text: custom?['number']?.toString() ?? "");
    final adresslar = TextEditingController(text: custom?['address'] ?? "");
    final typelar = TextEditingController(text: custom?['type'] ?? "");
    final bundellar = TextEditingController(text: custom?['bundle']?.toString() ?? "");
    final pricelar = TextEditingController(text: custom?['price']?.toString() ?? "");
    final idelar = TextEditingController(text: custom?['serialnumber']?.toString() ?? "");
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title:
                Text(custom == null ? 'Add new Customer' : 'Edit the Customer'),
            content: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: idelar,
                    decoration: InputDecoration(labelText: 'ID'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    controller: namelar,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    controller: lastlar,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    controller: adresslar,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: numberlar,
                    decoration: InputDecoration(labelText: 'Number'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    controller: bundellar,
                    decoration:
                        InputDecoration(labelText: 'select bundal bandel'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: pricelar,
                    decoration: InputDecoration(labelText: 'Price of bandel'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextFormField(
                    controller: typelar,
                    decoration: InputDecoration(
                        labelText: 'Type of bandel,Wirless or Cable'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("❌")),
              TextButton(
                  onPressed: () async {
                    final String name = namelar.text.trim();
                    final String lastname = lastlar.text.trim();
                    final String number = numberlar.text.trim();
                    final String bundel = bundellar.text.trim();
                    final String price = pricelar.text.trim();
                    final String type = typelar.text.trim();
                    final String address = adresslar.text.trim();
                    final String iid = idelar.text.trim();
                    if (name.isEmpty ||
                        lastname.isEmpty ||
                        number.isEmpty ||
                        bundel.isEmpty ||
                        price.isEmpty ||
                        type.isEmpty ||
                        iid.isEmpty ||
                        address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("please fill the profil"),
                      ));
                      return;
                    }
                    if (custom == null) {
                      await _addcustomer(namelar, lastlar, numberlar, adresslar, typelar, bundellar, pricelar, idelar);
                    } else {
                      await _update(custom['id'], name, lastname, number, address, type, bundel, price, iid);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('✅'))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Colors.blue,
                width: double.infinity,
                height: 250,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: CircleAvatar(
                        backgroundImage:AssetImage('photo/qais.jpg'),
                        radius: 70,
                      ),
                    ),
                    Text(" QN Internet Service Company",style: TextStyle(fontSize: 20,color: Colors.white),)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt_1_sharp),
                    TextButton(onPressed:(){
                      _showdialog();
                    }, child:Text("Add Customer")),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Icon(Icons.add_card),
                    TextButton(onPressed:(){
                      setState(() {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => homepage(),));
                      });
                    }, child:Text("Add Bundel")),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                //در ورژن بعدی حالت تنظیمات فعال میگردد
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    TextButton(onPressed:(){
                      setState(() {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => homepage(),));
                      });
                    }, child:Text("Setting")),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: _searching
              ? TextFormField(
                  controller: searchlar,
                  decoration: InputDecoration(
                    hintText: 'Search',
                  ),
                  onChanged: (value) {
                    _searchcustomer(value);
                  },
                )
              : Text(
                  "Customer List",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (_searching) {
                    _searching = false;
                    searchlar.clear();
                  } else {
                    _searching = true;
                  }
                });
              },
              icon: Icon(Icons.search),
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(
              icon: Icon(Icons.people),
              text: "Customer",
            ),
            Tab(
              icon: Icon(Icons.book),
              text: "Bundel",
            ),
          ]),
        ),
        body: TabBarView(children: [
          ListView.builder(
            itemCount: customer.length,
            itemBuilder: (context, index) {
              final custom = customer[index];
              return Card(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(" ID: ${custom['serialnumber']}"),
                      Text(" Name: ${custom['name']}"),
                    ],
                  ),
                  subtitle: Text(" Number: ${custom['number'].toString()}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => _callcustomer(custom['number']),
                          icon: Icon(
                            Icons.call,
                            color: Colors.blue,
                          )),
                      IconButton(
                          onPressed: () => _showdialog(custom: custom),
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          )),
                      IconButton(
                          onPressed: () => _delete(custom['id']),
                          icon: Icon(
                            Icons.delete,
                            color: Colors.blue,
                          ))
                    ],
                  ),
                ),
              );
            },
          ),

          Center(
            child: ListView.builder(
              itemCount: bundelItems.length,
              itemBuilder: (context, index) {
                final item = bundelItems[index];
                return Card(
                  color: Colors.black,
                  child: ListTile(
                    title: Row(
                      children: [
                        Text("GB: ${item["gb"].toString()}",style: TextStyle(fontSize: 15,color: Colors.white),),
                        SizedBox(width: 20,),
                        Text("Month: ${item["month"].toString()}",style: TextStyle(fontSize: 15,color: Colors.white),),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text("Type: ${item["type"]}",style: TextStyle(fontSize: 15,color: Colors.white),),
                        SizedBox(width: 20,),
                        Text("Price: ${item["price"].toString()}",style: TextStyle(fontSize: 15,color: Colors.white),),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Expanded(
          //     child:ListView.builder(
          //       itemCount:homepage.items.length,
          //       itemBuilder:(context, index) {
          //
          //     },))
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showdialog(),
          child: Icon(Icons.person_add_alt_1_sharp,),
        ),
      ),
    );
  }
}
