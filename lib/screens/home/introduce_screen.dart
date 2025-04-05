import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    // var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    // var appYellow = const Color(0xFFFFE30F);
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
          'Intro',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: const [Icon(Icons.info_outline), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(appColor, appGreenColor, greyMedium1Color),
            const SizedBox(height: 16),
            _buildQuestionSection(width),
            const SizedBox(height: 20),
            _buildTopRatedSection(appColor),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(appColor),
    );
  }

  Widget _buildProfileCard(appColor, appColorGreen, greyMedium1Color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2.0,
            spreadRadius: 1.0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: appColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Salvi',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('23k Mint',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: appColorGreen, size: 16),
                        Text(' 4.9', style: TextStyle(color: appColorGreen)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Text('Professional Listener',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const Text(
            "Namaste! I'm Nirali and speak Hindi. When I'm not whipping up delicious treats in the kitchen.",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          const Text('Expertise',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildChips(
              ['Empathy', 'Compassion', 'Problem-Solving', 'Loneliness'],
              greyMedium1Color),
          const SizedBox(height: 10),
          const Text('Language',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hindi',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 1.2)),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "🔊 Play",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChips(List<String> labels, greyMedium1Color) {
    return Wrap(
      spacing: 10.0,
      children: labels
          .map((label) => Chip(
              // surfaceTintColor: greyMedium1Color.,
              // backgroundColor: greyMedium1Color,
              side: BorderSide.none,
              label: Text(label)))
          .toList(),
    );
  }

  Widget _buildQuestionSection(width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What can you ask me?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildQuestionTile('How to manage mental health/peace?', width),
        _buildQuestionTile('How to manage mental health/peace?', width),
        _buildQuestionTile('How to manage mental health/peace?', width),
      ],
    );
  }

  Widget _buildQuestionTile(String question, width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(question, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildTopRatedSection(appColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Rated',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 128,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildTopRatedCard(appColor);
            },
          ),
        )
      ],
    );
  }

  Widget _buildTopRatedCard(appColor) {
    return Container(
      width: 152,
      margin: const EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 1.0,
              offset: Offset(0, 1))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 26, backgroundColor: appColor),
              const SizedBox(width: 6),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nirali', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('23k Minutes',
                      style: TextStyle(color: Colors.grey, fontSize: 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.green, size: 14),
                      Text(' 4.9', style: TextStyle(color: Colors.green)),
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.black.withOpacity(0.4), width: 1.1)),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "🔊 Play",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(appColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.black.withOpacity(0.4), width: 1.1)),
            child: const Center(
              child: Text('₹9/min',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: appColor,
                borderRadius: BorderRadius.circular(8),
                // border: Border.all(
                //     color: blackColor, width: 1.1),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    Text(
                      " Call Now",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
