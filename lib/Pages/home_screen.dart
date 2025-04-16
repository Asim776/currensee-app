// Your imports remain the same
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Currency? fromCurrency;
  Currency? toCurrency;
  String amount = "";
  String convertedAmount = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool _isLoading = false; // Spinner flag

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, 'login');
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  void _saveConversionToHistory() async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('conversion_history')
        .add({
      'from': fromCurrency!.code,
      'to': toCurrency!.code,
      'amount': double.tryParse(amount) ?? 0,
      'result': convertedAmount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "CurrenSee",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1FA2FF), Color(0xff12D8FA)],
                ),
              ),
              accountName: const SizedBox.shrink(),
              accountEmail: Row(
                children: [
                  const Icon(Icons.email, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    user?.email ?? "johndoe@example.com",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            ...[
              {"icon": Icons.newspaper, "title": "News", "route": 'News'},
              {"icon": Icons.help, "title": "FAQ", "route": 'faq'},
              {"icon": Icons.feedback, "title": "Feedback", "route": 'feedback'},
              {"icon": Icons.history, "title": "Conversion History", "route": 'history'},
              {"icon": Icons.history, "title": "Feedback History", "route": 'feedback_history'},
            ].map((item) => ListTile(
                  leading: Icon(item['icon'] as IconData),
                  title: Text(item['title'] as String),
                  onTap: () => Navigator.pushNamed(context, item['route'] as String),
                )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Currency Converter",
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xff4facfe), Color(0xff00f2fe)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildCurrencyPicker("From", fromCurrency, (Currency currency) {
                            setState(() => fromCurrency = currency);
                          }),
                          const SizedBox(height: 10),
                          const Icon(Icons.swap_vert, size: 32, color: Colors.white),
                          const SizedBox(height: 10),
                          _buildCurrencyPicker("To", toCurrency, (Currency currency) {
                            setState(() => toCurrency = currency);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField("Enter Amount", amount, true, fromCurrency?.symbol ?? ""),
                    const SizedBox(height: 15),

                    // Spinner integrated here
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildInputField("Converted Amount", convertedAmount, false, toCurrency?.symbol ?? ""),
                        if (_isLoading)
                          const Positioned.fill(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 4 : 3,
                  childAspectRatio: 1.4,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  List<String> buttons = [
                    "1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "Convert",
                  ];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (buttons[index] == "C") {
                          amount = "";
                          convertedAmount = "";
                        } else if (buttons[index] == "Convert") {
                          _convertCurrency();
                        } else {
                          amount += buttons[index];
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          buttons[index],
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            color: buttons[index] == "Convert" ? Colors.blueAccent : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _convertCurrency() async {
    if (fromCurrency == null || toCurrency == null || amount.isEmpty) {
      setState(() {
        convertedAmount = "Select currencies & enter amount";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      convertedAmount = "";
    });

    double? rate = await fetchExchangeRate(fromCurrency!.code, toCurrency!.code);

    if (rate == null) {
      setState(() {
        convertedAmount = "Conversion rate not available";
        _isLoading = false;
      });
      return;
    }

    double inputAmount = double.tryParse(amount) ?? 0;
    double result = inputAmount * rate;

    setState(() {
      convertedAmount = result.toStringAsFixed(2);
      _isLoading = false;
    });

    _saveConversionToHistory();
  }

  Widget _buildCurrencyPicker(
    String label,
    Currency? selectedCurrency,
    Function(Currency) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            showCurrencyPicker(
              context: context,
              showFlag: true,
              showCurrencyName: true,
              showCurrencyCode: true,
              onSelect: onSelect,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                selectedCurrency != null
                    ? Row(
                        children: [
                          Text(selectedCurrency.flag ?? ''),
                          const SizedBox(width: 10),
                          Text("${selectedCurrency.name} (${selectedCurrency.code})",
                              style: GoogleFonts.poppins()),
                        ],
                      )
                    : Text("Select Currency", style: GoogleFonts.poppins()),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String value, bool isEditable, String currencySymbol) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: !isEditable,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixText: currencySymbol,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Future<double?> fetchExchangeRate(String from, String to) async {
    String apiKey = "228a314f4231062dba1d258132514cff";
    String apiUrl = "https://api.exchangerate.host/convert?from=$from&to=$to&amount=1&access_key=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey("result")) {
          return data["result"]?.toDouble();
        }
      }
    } catch (e) {
      print("Error fetching exchange rate: $e");
    }

    return null;
  }
}
