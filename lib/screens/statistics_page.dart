import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';


class Category {
  String name;
  double amount;
  int colorValue;
  Category(
      {required this.name, required this.amount, required this.colorValue});

  Map<String, dynamic> toJson() =>
      {'name': name, 'amount': amount, 'colorValue': colorValue};
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        colorValue: json['colorValue'],
      );
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Category> myCategories = [];
  String currentInput = "0";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawList =
        myCategories.map((cat) => jsonEncode(cat.toJson())).toList();
    await prefs.setStringList('hagar_budget_dark_v1', rawList);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? rawList = prefs.getStringList('hagar_budget_dark_v1');
    setState(() {
      if (rawList != null && rawList.isNotEmpty) {
        myCategories =
            rawList.map((item) => Category.fromJson(jsonDecode(item))).toList();
      } else {
        myCategories = [
          Category(
              name: 'Shopping',
              amount: 0,
              colorValue: Colors.purpleAccent.value),
          Category(
              name: 'Food', amount: 0, colorValue: Colors.orangeAccent.value),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = myCategories.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Budget",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Total Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.purpleAccent, Colors.deepPurple]),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Text("Total Expenses",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text("\$${total.toStringAsFixed(0)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: myCategories
                      .map((cat) => PieChartSectionData(
                            value: cat.amount <= 0 ? 1 : cat.amount,
                            color: Color(cat.colorValue),
                            title: cat.name,
                            radius: 50,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Long press to delete 🗑️",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 10),
            // List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myCategories.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Color(myCategories[index].colorValue)),
                    title: Text(myCategories[index].name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: Text("\$${myCategories[index].amount}",
                        style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    onLongPress: () {
                      setState(() => myCategories.removeAt(index));
                      _saveData();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addNewCategory,
            mini: true,
            heroTag: "add",
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: _showUpdateSheet,
            label: const Text("Add Amount"),
            icon: const Icon(Icons.calculate),
            heroTag: "edit",
          ),
        ],
      ),
    );
  }

  void _addNewCategory() {
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
            controller: c,
            decoration: const InputDecoration(hintText: "Category Name")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                if (c.text.isNotEmpty) {
                  setState(() => myCategories.add(Category(
                      name: c.text,
                      amount: 0,
                      colorValue: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)]
                          .value)));
                  _saveData();
                  Navigator.pop(context);
                }
              },
              child: const Text("Add")),
        ],
      ),
    );
  }

  void _showUpdateSheet() {
    Category? selected = myCategories.isNotEmpty ? myCategories[0] : null;
    currentInput = "0";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(25),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              const Text("Update Budget",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 20),
              if (myCategories.isNotEmpty)
                DropdownButton<Category>(
                  value: selected,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2C2C2C),
                  items: myCategories
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selected = v),
                ),
              const SizedBox(height: 20),
              Text(currentInput,
                  style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.4,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    for (var i = 1; i <= 9; i++) _keyBtn("$i", setModalState),
                    _keyBtn("C", setModalState,
                        color: Colors.redAccent.withOpacity(0.2)),
                    _keyBtn("0", setModalState),
                    _keyBtn(".", setModalState),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Back"))),
                  const SizedBox(width: 15),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      if (selected != null && currentInput != "0") {
                        setState(() {
                          selected!.amount +=
                              double.tryParse(currentInput) ?? 0;
                        });
                        _saveData();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Confirm",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  )),
                ],
              )
            ],
          ),
        ),
      ),
    ).then((_) => setState(() => currentInput = "0"));
  }

  Widget _keyBtn(String v, Function setModalState, {Color? color}) {
    return InkWell(
      onTap: () => setModalState(() {
        if (v == "C") {
          currentInput = "0";
        } else {
          currentInput = currentInput == "0" ? v : currentInput + v;
        }
      }),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(v,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
