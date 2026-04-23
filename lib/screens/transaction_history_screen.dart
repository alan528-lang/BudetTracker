import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TransactionHistoryScreen(),
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  double baseIncome = 0;

  List<Map<String, dynamic>> transactions = [];

  bool selectionMode = false;
  Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showBaseIncomeDialog();
    });
  }

  // 🧠 Time Ago
  String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 365) {
      int years = (diff.inDays / 365).floor();
      return years == 1 ? "من سنة" : "من $years سنين";
    } else if (diff.inDays >= 30) {
      int months = (diff.inDays / 30).floor();
      return months == 1 ? "من شهر" : "من $months شهور";
    } else if (diff.inDays >= 1) {
      return diff.inDays == 1 ? "من يوم" : "من ${diff.inDays} أيام";
    } else if (diff.inHours >= 1) {
      return "من ${diff.inHours} ساعة";
    } else if (diff.inMinutes >= 1) {
      return diff.inMinutes == 1
          ? "من دقيقة"
          : "من ${diff.inMinutes} دقايق";
    } else {
      return "لسه حالاً";
    }
  }

  Color getBalanceColor() {
    if (balance < 0) return Colors.redAccent;
    if (balance == 0) return Colors.white;
    return Colors.greenAccent;
  }

  double get balance {
    double total = baseIncome;

    for (var tx in transactions) {
      if (tx["type"] == "income") {
        total += tx["amount"];
      } else {
        total -= tx["amount"];
      }
    }
    return total;
  }

  void addTransaction(String type, double amount, String category) {
    setState(() {
      transactions.add({
        "id": DateTime.now().toString(),
        "type": type,
        "amount": amount,
        "category": category,
        "date": DateTime.now(),
      });
    });
  }

  // 🧠 SELECT ALL / UNSELECT ALL
  void toggleSelectAll() {
    setState(() {
      if (selectedIds.length == transactions.length) {
        selectedIds.clear();
      } else {
        selectedIds =
            transactions.map((tx) => tx["id"].toString()).toSet();
      }
    });
  }

  void deleteSelected() {
    setState(() {
      transactions.removeWhere(
            (tx) => selectedIds.contains(tx["id"]),
      );
      selectedIds.clear();
      selectionMode = false;
    });
  }

  // 💰 BASE INCOME
  void showBaseIncomeDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            "Enter Base Income",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Amount",
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              onPressed: () {
                setState(() {
                  baseIncome = double.parse(controller.text);
                });
                Navigator.pop(context);
              },
              child: const Text("Start"),
            ),
          ],
        );
      },
    );
  }

  void showAddDialog() {
    String type = "expense";
    final amountController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            "Add Transaction",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                value: type,
                items: const [
                  DropdownMenuItem(
                      value: "income",
                      child: Text("Income",
                          style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: "expense",
                      child: Text("Expense",
                          style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  type = value!;
                },
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              TextField(
                controller: categoryController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                addTransaction(
                  type,
                  double.parse(amountController.text),
                  categoryController.text,
                );
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),

        actions: [
          IconButton(
            icon: Icon(
              selectionMode ? Icons.close : Icons.check_box,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                selectionMode = !selectionMode;
                selectedIds.clear();
              });
            },
          ),

          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.select_all,
                  color: Colors.white),
              onPressed: toggleSelectAll,
            ),

          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.delete,
                  color: Colors.redAccent),
              onPressed: deleteSelected,
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Balance",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  "${balance.toStringAsFixed(0)} EGP",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: getBalanceColor(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isExpense = tx["type"] == "expense";
                final isSelected =
                selectedIds.contains(tx["id"]);

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      if (selectionMode)
                        Checkbox(
                          value: isSelected,
                          activeColor: Colors.greenAccent,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedIds.add(tx["id"]);
                              } else {
                                selectedIds.remove(tx["id"]);
                              }
                            });
                          },
                        ),

                      CircleAvatar(
                        backgroundColor:
                        isExpense ? Colors.red : Colors.green,
                        child: Icon(
                          isExpense
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(tx["category"],
                                style: const TextStyle(
                                    color: Colors.white)),
                            Text(getTimeAgo(tx["date"]),
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12)),
                          ],
                        ),
                      ),

                      Text(
                        "${tx["amount"]} EGP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpense
                              ? Colors.redAccent
                              : Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}