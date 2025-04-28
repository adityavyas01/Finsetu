import 'package:flutter/material.dart';
import 'package:finsetu_app/screens/split_bill_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mainGradient = LinearGradient(
      colors: [Color(0xFFE8FA7A), Color(0xFFAADF50)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const Color accentColor = Color(0xFFE8FA7A);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;
    const Color darkSurfaceColor = Colors.black;
    const Color inputFillColor = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: darkSurfaceColor,
      body: SafeArea(
        child: _buildBody(
          context,
          mainGradient,
          accentColor,
          primaryTextColor,
          secondaryTextColor,
          inputFillColor,
          _scrollController,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(mainGradient),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LinearGradient mainGradient,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color inputFillColor,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => mainGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Text(
                        "F",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => mainGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: const Text(
                      "FinSetu",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: primaryTextColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: inputFillColor,
                      child: Icon(Icons.person_outline, size: 18, color: primaryTextColor),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Welcome back!",
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's an overview of your financial health",
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: mainGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Balance",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "₹ 24,500.00",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceInfoItem("Income", "₹ 34,200", Icons.arrow_downward),
                    ),
                    Expanded(
                      child: _buildBalanceInfoItem("Expenses", "₹ 9,700", Icons.arrow_upward),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Quick Actions",
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(inputFillColor, primaryTextColor, secondaryTextColor, mainGradient),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => mainGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildRecentTransactionsList(inputFillColor, primaryTextColor, secondaryTextColor),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBalanceInfoItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.black),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(Color bgColor, Color primaryTextColor, Color secondaryTextColor, LinearGradient gradient) {
    final actions = [
      {'icon': Icons.account_balance_wallet, 'label': 'Add Money'},
      {'icon': Icons.send, 'label': 'Send Money'},
      {'icon': Icons.schedule, 'label': 'Scheduled'},
      {'icon': Icons.group_outlined, 'label': 'Split Bills'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (actions[index]['label'] == 'Split Bills') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SplitBillScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${actions[index]['label']} tapped"),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 800),
                ),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  actions[index]['icon'] as IconData,
                  color: primaryTextColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                actions[index]['label'] as String,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactionsList(Color bgColor, Color primaryTextColor, Color secondaryTextColor) {
    final transactions = [
      {
        'name': 'Netflix Subscription',
        'date': 'Today',
        'amount': '- ₹ 649',
        'icon': Icons.video_library,
        'isExpense': true
      },
      {
        'name': 'Salary Deposit',
        'date': 'Yesterday',
        'amount': '+ ₹ 32,500',
        'icon': Icons.account_balance,
        'isExpense': false
      },
      {
        'name': 'Grocery Store',
        'date': '20 Aug 2023',
        'amount': '- ₹ 1,250',
        'icon': Icons.shopping_basket,
        'isExpense': true
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction['isExpense'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction['icon'] as IconData,
                  color: primaryTextColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['name'] as String,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      transaction['date'] as String,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                transaction['amount'] as String,
                style: TextStyle(
                  color: isExpense ? Colors.red : Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(LinearGradient mainGradient) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: const Color(0xFFE8FA7A),
          unselectedItemColor: Colors.white60,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: 'Home',
              activeIcon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(Icons.home_rounded),
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics_outlined),
              label: 'Analytics',
              activeIcon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(Icons.analytics_outlined),
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.wallet_outlined),
              label: 'Wallet',
              activeIcon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(Icons.wallet_outlined),
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              label: 'Settings',
              activeIcon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(Icons.settings_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
