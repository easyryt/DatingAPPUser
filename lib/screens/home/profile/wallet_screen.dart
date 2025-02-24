import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedIndex = 1;
  final List<Map<String, dynamic>> rechargePacks = [
    {'amount': 84, 'benefit': 199, 'sale': false},
    {'amount': 199, 'benefit': 299, 'sale': true},
    {'amount': 499, 'benefit': 600, 'sale': false},
  ];

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    var appYellow = const Color(0xFFFFE30F);
    var appGreenColor = const Color(0xFF35D673);
    var greyMedium1Color = const Color(0xFFDBDBDB);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            )),
        title: const Text(
          'My Wallet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: const [Icon(Icons.info_outline), SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: Colors.white,
              gradient: LinearGradient(colors: [
                whiteColor,
                whiteColor,
                appColor,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Wallet Balance",
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                const Text("₹0.00",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      foregroundColor: appColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Transaction"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text("Select Recharge Pack",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(rechargePacks.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: selectedIndex == index
                            ? appColor
                            : Colors.grey.shade300,
                        width: 2),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade200, blurRadius: 2),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (rechargePacks[index]['sale'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Sale 30%",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      const SizedBox(height: 5),
                      Text("₹${rechargePacks[index]['amount']}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Get ₹${rechargePacks[index]['benefit']}",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: greyMedium1Color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBottomOption(Icons.verified_user, "Secure Checkout"),
                _buildBottomOption(Icons.emoji_events, "Secure Checkout"),
                _buildBottomOption(Icons.lock, "Secure Checkout"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOption(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(height: 5),
        Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
