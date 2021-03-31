import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  var tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Döviz Çevirici",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: tabController,
          tabs: [
            Tab(
              icon: Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 30,
              ),
              child: Text(
                "Döviz Kurları",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.calculate,
                color: Colors.white,
                size: 30,
              ),
              child: Text(
                "Para Birimi Çevirici",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          Currencies(),
          Calculate(),
        ],
        controller: tabController,
      ),
    );
  }
}

class Currencies extends StatefulWidget {
  @override
  _CurrenciesState createState() => _CurrenciesState();
}

class _CurrenciesState extends State<Currencies> {
  var currencies;

  _get() async {
    var response =
        await http.get(Uri.https("api.genelpara.com", "/embed/doviz.json"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Bağlanımaladı.Hata kodu ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    _get().then((data) {
      currencies = data;
    });
    return Container(
      child: FutureBuilder(
        future: _get(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: (currencies.keys).toList().length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  elevation: 15,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "${(currencies.keys).toList()[index]} / TRY",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "SATIŞ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "${(currencies[(currencies.keys).toList()[index]]["satis"]).replaceAll('.',',')}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              "ALIŞ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "${(currencies[(currencies.keys).toList()[index]]["alis"]).replaceAll('.',',')}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        double.parse(currencies[(currencies.keys)
                                        .toList()[index]]["degisim"]
                                    .replaceAll(',', '.')) >
                                0
                            ? Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                                size: 30,
                              )
                            : Icon(
                                Icons.arrow_downward,
                                color: Colors.red,
                                size: 30,
                              )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator.adaptive());
          }
        },
      ),
    );
  }
}

class Calculate extends StatefulWidget {
  @override
  _CalculateState createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> {
  var currencies;
  var currenciesList;
  final formKey = GlobalKey<FormState>();
  double amount = 0;
  String from = "TRY";
  String to = "USD";

  _get() async {
    var response =
        await http.get(Uri.https("api.genelpara.com", "/embed/doviz.json"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Bağlanımaladı.Hata kodu ${response.statusCode}");
    }
  }


  @override
  Widget build(BuildContext context) {
    _get().then((data) {
      currencies = data;

      currenciesList = List.from(currencies.keys);
      currenciesList.insert(0, "TRY");
    });
    return Container(
        child: FutureBuilder(
            future: _get(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                return Form(
                    key: formKey,
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(25),
                          child: TextFormField(
                            onSaved: (i) => amount = double.parse(i),
                            initialValue: "0",
                            validator: (amount) {
                              if (double.parse(amount) < 0) {
                                return "Uygun bir tutar girin.";
                              } else if (amount.isEmpty) {
                                return "Bir tutar girin";
                              } else {
                                return null;
                              }
                            },
                            autovalidateMode: AutovalidateMode.always,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Tutar girin",
                              labelText: "Tutar girin",
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DropdownButton(
                                onChanged: (selected) {
                                  setState(() {
                                    from = selected;
                                  });
                                },
                                value: from,
                                items: List.generate(
                                    currenciesList.length,
                                    (index) => DropdownMenuItem(
                                          child:
                                              Text("${currenciesList[index]}"),
                                          value: currenciesList[index],
                                        ))),
                            Icon(
                              Icons.arrow_right_alt,
                              color: Colors.red,
                            ),
                            DropdownButton(
                                onChanged: (selected) {
                                  setState(() {
                                    to = selected;
                                  });
                                },
                                value: to,
                                items: List.generate(
                                    currenciesList.length,
                                    (index) => DropdownMenuItem(
                                          child:
                                              Text("${currenciesList[index]}"),
                                          value: currenciesList[index],
                                        ))),
                          ],
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              calculate(context);
                            },
                            child: Text("Çevir"),
                          ),
                        ),
                      ],
                    ));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  void calculate(BuildContext context) {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      double value = 0;
      if (from == "TRY" && to == "TRY") {
        value = amount;
      } else if (from == "TRY" && to != "TRY") {
        value = amount / double.parse(currencies[to]["satis"]);
      } else if (from != "TRY" && to == "TRY") {
        value = amount * double.parse(currencies[from]["satis"]);
      } else {
        value = (amount * double.parse(currencies[from]["satis"])) /
            double.parse(currencies[to]["satis"]);
      }

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Çevirme sonucu"),
              content: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "$amount ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(
                      text: "$from ",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(
                      text: "${value.toStringAsFixed(4)}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(
                      text: " $to ",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            );
          });
    }
  }
}
