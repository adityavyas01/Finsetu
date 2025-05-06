import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _selectedFilter = '1 Month';
  String _selectedSortBy = 'Date (Latest)';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showCustomDatePicker = false;

  final List<String> _filterOptions = ['Today', 'Yesterday', '7 Days', '1 Month', '1 Year', 'Custom', 'All'];
  final List<String> _sortOptions = ['Date (Latest)', 'Date (Oldest)', 'Amount (High-Low)', 'Amount (Low-High)', 'Category'];

  final List<Map<String, dynamic>> _allTransactions = [
    {
      'name': 'Netflix Subscription',
      'date': DateTime.now(),
      'amount': '- ₹ 649',
      'icon': Icons.video_library,
      'isExpense': true,
      'category': 'Entertainment',
      'description': 'Monthly premium plan subscription',
    },
    {
      'name': 'Salary Deposit',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'amount': '+ ₹ 32,500',
      'icon': Icons.account_balance,
      'isExpense': false,
      'category': 'Income',
      'description': 'Monthly salary deposit from TechCorp Inc.',
    },
    {
      'name': 'Grocery Store',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'amount': '- ₹ 1,250',
      'icon': Icons.shopping_basket,
      'isExpense': true,
      'category': 'Food & Groceries',
      'description': 'Grocery shopping at Big Basket',
    },
    {
      'name': 'Amazon Order',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'amount': '- ₹ 2,499',
      'icon': Icons.shopping_cart,
      'isExpense': true,
      'category': 'Shopping',
      'description': 'Bluetooth headphones purchase',
    },
    {
      'name': 'Electricity Bill',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'amount': '- ₹ 1,850',
      'icon': Icons.electric_bolt,
      'isExpense': true,
      'category': 'Utilities',
      'description': 'Monthly electricity bill payment',
    },
    {
      'name': 'Freelance Work',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'amount': '+ ₹ 15,000',
      'icon': Icons.work,
      'isExpense': false,
      'category': 'Income',
      'description': 'Website development project payment',
    },
    {
      'name': 'Restaurant Dinner',
      'date': DateTime.now().subtract(const Duration(days: 11)),
      'amount': '- ₹ 1,850',
      'icon': Icons.restaurant,
      'isExpense': true,
      'category': 'Dining Out',
      'description': 'Dinner with family at La Pino\'z Pizza',
    },
    {
      'name': 'Mobile Recharge',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'amount': '- ₹ 499',
      'icon': Icons.mobile_friendly,
      'isExpense': true,
      'category': 'Utilities',
      'description': 'Mobile recharge for 3 months plan',
    },
    {
      'name': 'Gym Membership',
      'date': DateTime.now().subtract(const Duration(days: 22)),
      'amount': '- ₹ 2,499',
      'icon': Icons.fitness_center,
      'isExpense': true,
      'category': 'Health & Fitness',
      'description': 'Monthly premium membership renewal',
    },
    {
      'name': 'Investment Dividend',
      'date': DateTime.now().subtract(const Duration(days: 29)),
      'amount': '+ ₹ 5,500',
      'icon': Icons.trending_up,
      'isExpense': false,
      'category': 'Investment',
      'description': 'Quarterly dividend payout from mutual funds',
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _applyFilter(_selectedFilter);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _showCustomDatePicker = filter == 'Custom';

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      switch (filter) {
        case 'Today':
          _filteredTransactions = _allTransactions.where((txn) {
            DateTime txnDate = txn['date'] as DateTime;
            return txnDate.year == now.year &&
                txnDate.month == now.month &&
                txnDate.day == now.day;
          }).toList();
          break;
        case 'Yesterday':
          DateTime yesterday = startOfDay.subtract(const Duration(days: 1));
          _filteredTransactions = _allTransactions.where((txn) {
            DateTime txnDate = txn['date'] as DateTime;
            return txnDate.year == yesterday.year &&
                txnDate.month == yesterday.month &&
                txnDate.day == yesterday.day;
          }).toList();
          break;
        case '7 Days':
          DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
          _filteredTransactions = _allTransactions.where((txn) {
            return (txn['date'] as DateTime).isAfter(sevenDaysAgo);
          }).toList();
          break;
        case '1 Month':
          DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
          _filteredTransactions = _allTransactions.where((txn) {
            return (txn['date'] as DateTime).isAfter(oneMonthAgo);
          }).toList();
          break;
        case '1 Year':
          DateTime oneYearAgo = DateTime(now.year - 1, now.month, now.day);
          _filteredTransactions = _allTransactions.where((txn) {
            return (txn['date'] as DateTime).isAfter(oneYearAgo);
          }).toList();
          break;
        case 'Custom':
          if (_startDate != null && _endDate != null) {
            _applyCustomDateFilter();
          } else {
            _filteredTransactions = _allTransactions;
          }
          break;
        default:
          _filteredTransactions = _allTransactions;
      }
    });
  }

  void _applyCustomDateFilter() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _filteredTransactions = _allTransactions.where((txn) {
          DateTime txnDate = txn['date'] as DateTime;
          return txnDate.isAfter(_startDate!) && txnDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      });
    }
  }

  void _applySorting() {
    setState(() {
      switch (_selectedSortBy) {
        case 'Date (Latest)':
          _filteredTransactions.sort((a, b) =>
              (b['date'] as DateTime).compareTo(a['date'] as DateTime));
          break;
        case 'Date (Oldest)':
          _filteredTransactions.sort((a, b) =>
              (a['date'] as DateTime).compareTo(b['date'] as DateTime));
          break;
        case 'Amount (High-Low)':
          _filteredTransactions.sort((a, b) {
            double amountA = double.parse((a['amount'] as String)
                .replaceAll(RegExp(r'[^0-9.]'), ''));
            double amountB = double.parse((b['amount'] as String)
                .replaceAll(RegExp(r'[^0-9.]'), ''));
            return amountB.compareTo(amountA);
          });
          break;
        case 'Amount (Low-High)':
          _filteredTransactions.sort((a, b) {
            double amountA = double.parse((a['amount'] as String)
                .replaceAll(RegExp(r'[^0-9.]'), ''));
            double amountB = double.parse((b['amount'] as String)
                .replaceAll(RegExp(r'[^0-9.]'), ''));
            return amountA.compareTo(amountB);
          });
          break;
        case 'Category':
          _filteredTransactions.sort((a, b) =>
              (a['category'] as String).compareTo(b['category'] as String));
          break;
      }
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE8FA7A),
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
        if (_startDate != null && _endDate != null) {
          _applyCustomDateFilter();
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE8FA7A),
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        if (_startDate != null && _endDate != null) {
          _applyCustomDateFilter();
        }
      });
    }
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
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: darkSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: primaryTextColor),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                _selectedSortBy = value;
                _applySorting();
              });
            },
            itemBuilder: (context) => _sortOptions
                .map((option) => PopupMenuItem<String>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            _getSortIcon(option),
                            color: _selectedSortBy == option ? accentColor : primaryTextColor,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            option,
                            style: TextStyle(
                              color: _selectedSortBy == option ? accentColor : primaryTextColor,
                              fontWeight: _selectedSortBy == option ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (_selectedSortBy == option)
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Icon(Icons.check, size: 16, color: accentColor),
                            ),
                        ],
                      ),
                    ))
                .toList(),
            color: const Color(0xFF202020),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) => _buildFilterChip(filter, accentColor)).toList(),
              ),
            ),
          ),
          
          if (_showCustomDatePicker)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startDate == null
                                  ? 'Start Date'
                                  : DateFormat('MMM dd, yyyy').format(_startDate!),
                              style: TextStyle(
                                color: _startDate == null ? secondaryTextColor : primaryTextColor,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: accentColor, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endDate == null
                                  ? 'End Date'
                                  : DateFormat('MMM dd, yyyy').format(_endDate!),
                              style: TextStyle(
                                color: _endDate == null ? secondaryTextColor : primaryTextColor,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: accentColor, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${_filteredTransactions.length} transactions',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    if (_selectedFilter != 'All') 
                      Text(
                        ' • $_selectedFilter',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                Text(
                  'Sorted by: $_selectedSortBy',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_outlined, size: 48, color: secondaryTextColor),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Try a different time period',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      final isExpense = transaction['isExpense'] as bool;
                      
                      final DateTime transactionDate = transaction['date'] as DateTime;
                      final String formattedDate = DateFormat('MMM dd, yyyy').format(transactionDate);
                      final String formattedTime = DateFormat('hh:mm a').format(transactionDate);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // Show transaction details in a bottom sheet
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => _buildTransactionDetailsSheet(context, transaction),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          transaction['icon'] as IconData,
                                          color: primaryTextColor,
                                          size: 22,
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    transaction['category'] as String,
                                                    style: TextStyle(
                                                      color: secondaryTextColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                    color: secondaryTextColor,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        transaction['amount'] as String,
                                        style: TextStyle(
                                          color: isExpense ? Colors.red : Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        transaction['description'] as String,
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color accentColor) {
    final isSelected = _selectedFilter == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
      child: GestureDetector(
        onTap: () => _applyFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(
              colors: [Color(0xFFE8FA7A), Color(0xFFAADF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
            color: isSelected ? null : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : accentColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getSortIcon(String sortOption) {
    switch (sortOption) {
      case 'Date (Latest)':
        return Icons.arrow_downward;
      case 'Date (Oldest)':
        return Icons.arrow_upward;
      case 'Amount (High-Low)':
        return Icons.attach_money;
      case 'Amount (Low-High)':
        return Icons.money_off;
      case 'Category':
        return Icons.category;
      default:
        return Icons.sort;
    }
  }

  Widget _buildTransactionDetailsSheet(BuildContext context, Map<String, dynamic> transaction) {
    final DateTime transactionDate = transaction['date'] as DateTime;
    final String formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(transactionDate);
    final String formattedTime = DateFormat('hh:mm a').format(transactionDate);
    final bool isExpense = transaction['isExpense'] as bool;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: isExpense ? Colors.red : Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transaction['name'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transaction['amount'] as String,
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Category', transaction['category'] as String),
          _buildDetailRow('Date', formattedDate),
          _buildDetailRow('Time', formattedTime),
          _buildDetailRow('Description', transaction['description'] as String),
          _buildDetailRow('Status', 'Completed'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text(
                    "Download Receipt",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8FA7A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
