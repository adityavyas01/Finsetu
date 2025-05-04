import 'package:flutter/material.dart';
import 'package:finsetu_app/screens/bill_groups_screen.dart';

class SplitBillScreen extends StatefulWidget {
  final BillGroup? group;

  const SplitBillScreen({super.key, this.group});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late List<Person> _people;

  bool _isEvenSplit = true;
  bool _isItemized = false;
  List<BillItem> _billItems = [];
  
  List<Expense> _expenses = [];
  double _totalExpenseAmount = 0.0;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize bill items
    _billItems.add(BillItem(name: 'Item 1', amount: 0));

    // Initialize people from the group or with default value
    if (widget.group != null) {
      // Map the Person objects from bill_groups_screen.dart to Person objects defined in this file
      _people = widget.group!.members.map((member) => 
        Person(name: member.name, isYou: member.isYou)
      ).toList();
      // Removed default text for description
    } else {
      _people = [Person(name: 'You', isYou: true), Person(name: 'Friend 1')];
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _descriptionController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 700;

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
        backgroundColor: darkSurfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
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
                    fontSize: 18,
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
              child: Text(
                widget.group != null ? "Split with ${widget.group!.name}" : "Split Bill",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: !isWideScreen
            ? TabBar(
                controller: _tabController,
                indicatorColor: accentColor,
                tabs: const [
                  Tab(text: "ADD EXPENSE"),
                  Tab(text: "SUMMARY"),
                ],
              )
            : null,
      ),
      body: isWideScreen
          ? _buildWideScreenLayout(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor)
          : _buildMobileScreenLayout(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor),
    );
  }

  Widget _buildWideScreenLayout(
    LinearGradient mainGradient,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color inputFillColor,
  ) {
    return Row(
      children: [
        // Left panel - Input form
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add expense details and split with friends",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  // Add a note about selecting people when creating groups
                  Text(
                    "People selected when creating groups will appear here automatically",
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildExpenseForm(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor),
                ],
              ),
            ),
          ),
        ),

        // Divider
        Container(
          width: 1,
          color: Colors.grey[800],
        ),

        // Right panel - Summary
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: _buildSummarySection(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileScreenLayout(
    LinearGradient mainGradient,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color inputFillColor,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Expense Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add expense details and split with friends",
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _buildExpenseForm(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor),
            ],
          ),
        ),

        // Summary Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildSummarySection(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor),
        ),
      ],
    );
  }

  Widget _buildExpenseForm(
    LinearGradient mainGradient,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color inputFillColor,
  ) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 700;
    
    // Initialize selected payer state variable
    Person _selectedPayer = _people.firstWhere((p) => p.isYou, orElse: () => _people.first);
    
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.day}/${now.month}/${now.year}";
    final String formattedTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Amount Spent with Date and Time
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Amount field
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount Spent",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputFillColor,
                      hintText: "Enter amount",
                      hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.6), fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Date and time
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date & Time",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: secondaryTextColor, size: 16),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 14,
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
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 2. Paid For (Transaction Description)
        Text(
          "Paid For (Description)",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          style: TextStyle(color: primaryTextColor, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFillColor,
            hintText: "",
            hintStyle: TextStyle(color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.description_outlined, color: secondaryTextColor),
          ),
        ),
        const SizedBox(height: 24),

        // 3. Paid By (You or member selection) - Fixed selection
        Text(
          "Paid By",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: StatefulBuilder(
            builder: (context, setDropdownState) {
              return DropdownButtonHideUnderline(
                child: DropdownButton<Person>(
                  value: _selectedPayer,
                  dropdownColor: const Color(0xFF2A2A2A),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: secondaryTextColor),
                  items: _people.map((Person person) {
                    return DropdownMenuItem<Person>(
                      value: person,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: person.isYou ? accentColor : Colors.grey[800],
                            child: Text(
                              person.name.isNotEmpty ? person.name[0].toUpperCase() : "?",
                              style: TextStyle(
                                color: person.isYou ? Colors.black : primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            person.isYou ? "You" : person.name,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (Person? newValue) {
                    if (newValue != null) {
                      setDropdownState(() {
                        _selectedPayer = newValue;
                      });
                    }
                  },
                ),
              );
            }
          ),
        ),
        const SizedBox(height: 24),

        // 4. Split By (renamed from "Split With") and removed "Add Person" button
        Text(
          "Split",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Split options row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSplitOption(
                      icon: Icons.people_outline,
                      label: "Equally",
                      isSelected: _isEvenSplit,
                      onTap: () => setState(() {
                        _isEvenSplit = true;
                        _isItemized = false;
                      }),
                      accentColor: accentColor,
                      primaryTextColor: primaryTextColor,
                    ),
                    _buildSplitOption(
                      icon: Icons.currency_rupee,
                      label: "By Amount",
                      isSelected: !_isEvenSplit,
                      onTap: () => setState(() {
                        _isEvenSplit = false;
                        _isItemized = false;
                      }),
                      accentColor: accentColor,
                      primaryTextColor: primaryTextColor,
                    ),
                  ],
                ),
              ),
              
              // Divider
              Divider(color: Colors.grey[800], height: 1),
              
              // People selection list - removed "Add Person" button and delete icons
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "People in this split",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _people.map((person) {
                        return Chip(
                          backgroundColor: Colors.grey[850],
                          avatar: CircleAvatar(
                            backgroundColor: person.isYou ? accentColor : Colors.grey[700],
                            child: Text(
                              person.name.isNotEmpty ? person.name[0].toUpperCase() : "?",
                              style: TextStyle(
                                color: person.isYou ? Colors.black : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          label: Text(
                            person.isYou ? "You" : person.name,
                            style: TextStyle(
                              color: primaryTextColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Custom amount split (if selected)
        if (!_isEvenSplit) ...[
          const SizedBox(height: 8),
          Text(
            "Custom Split Amount",
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ..._people.map((person) {
            final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
            return _buildCustomAmountRow(
              person, 
              totalAmount, 
              inputFillColor, 
              primaryTextColor, 
              secondaryTextColor, 
              accentColor
            );
          }).toList(),
        ],
        
        const SizedBox(height: 32),
        
        // Submit button with proper expense tracking
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Validate if amount is entered
              final currentAmount = double.tryParse(_totalAmountController.text);
              if (currentAmount == null || currentAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a valid amount"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              
              final currentDescription = _descriptionController.text.isNotEmpty 
                  ? _descriptionController.text 
                  : "Untitled Expense";
              
              // Create and add a new expense to our list
              setState(() {
                // Create a new expense
                final newExpense = Expense(
                  amount: currentAmount,
                  description: currentDescription,
                  date: DateTime.now(),
                  isEvenSplit: _isEvenSplit,
                );
                
                // Add to our expenses list
                _expenses.add(newExpense);
                
                // Update the total amount
                _totalExpenseAmount += currentAmount;
                
                // Clear input fields for next expense
                _totalAmountController.clear();
                _descriptionController.clear();
                
                // Reset split type to even for next expense
                _isEvenSplit = true;
                _isItemized = false;
              });
              
              // Switch to summary tab in mobile view
              if (!isWideScreen && _tabController != null) {
                _tabController!.animateTo(1);
              }
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$currentDescription added to split!"),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: accentColor,
                    onPressed: () {
                      if (!isWideScreen && _tabController != null) {
                        _tabController!.animateTo(1);
                      }
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "ADD TO SPLIT",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
    required Color primaryTextColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : primaryTextColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : primaryTextColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomAmountRow(
    Person person, 
    double totalAmount,
    Color inputFillColor, 
    Color primaryTextColor, 
    Color secondaryTextColor,
    Color accentColor,
  ) {
    final TextEditingController amountController = TextEditingController();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: person.isYou ? accentColor : Colors.grey[700],
            child: Text(
              person.name.isNotEmpty ? person.name[0].toUpperCase() : "?",
              style: TextStyle(
                color: person.isYou ? Colors.black : primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              person.name,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: accentColor),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                fillColor: Colors.grey[850],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  child: Text(
                    "₹",
                    style: TextStyle(color: accentColor, fontSize: 16),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 0),
                hintText: "0.00",
                hintStyle: TextStyle(color: secondaryTextColor),
              ),
              onChanged: (value) {
                double amount = double.tryParse(value) ?? 0;
                setState(() {
                  person.customAmount = amount;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    LinearGradient mainGradient,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color inputFillColor,
  ) {
    final perPersonAmount = _people.isNotEmpty ? _totalExpenseAmount / _people.length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bill Summary",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Bill card
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _descriptionController.text.isNotEmpty ? _descriptionController.text : "Bill Split",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Total Amount",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹ ${_totalExpenseAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.black26, height: 32),
              const Text(
                "Split Equally Among",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${_people.length} People",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < (_people.length > 5 ? 5 : _people.length); i++)
                        Container(
                          margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: i == 0 ? Colors.black : Colors.grey[800],
                            child: Text(
                              _people[i].name.isNotEmpty ? _people[i].name[0] : "?",
                              style: TextStyle(
                                color: i == 0 ? accentColor : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_people.length > 5)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black45,
                            child: Text(
                              "+${_people.length - 5}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Per person breakdown
        Text(
          "Amount Per Person",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Each person pays",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                "₹ ${perPersonAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // If custom split, show custom amounts
        if (!_isEvenSplit) ...[
          Text(
            "Custom Split",
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._people.map((person) => _buildCustomSplitRow(person, _totalExpenseAmount, inputFillColor, primaryTextColor, secondaryTextColor)).toList(),
        ],

        const SizedBox(height: 24),

        // List all expenses
        if (_expenses.isNotEmpty) ...[
          Text(
            "Expenses",
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._expenses.map((expense) => _buildExpenseRow(expense, inputFillColor, primaryTextColor, secondaryTextColor, accentColor)),
        ],

        const SizedBox(height: 40),

        // Send request button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Split request sent!"),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "SEND SPLIT REQUEST",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSplitRow(Person person, double totalAmount, Color inputFillColor, Color primaryTextColor, Color secondaryTextColor) {
    // Default to equal split initially
    final splitPercentage = person.splitPercentage > 0 ? person.splitPercentage : (100 / _people.length);
    final amount = totalAmount * (splitPercentage / 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: person.isYou ? const Color(0xFFE8FA7A) : Colors.grey[800],
            child: Text(
              person.name.isNotEmpty ? person.name[0] : "?",
              style: TextStyle(
                color: person.isYou ? Colors.black : primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              person.name,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${splitPercentage.toStringAsFixed(0)}%",
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "₹ ${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Color(0xFFE8FA7A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(Expense expense, Color inputFillColor, Color primaryTextColor, Color secondaryTextColor, Color accentColor) {
    final formattedDate = "${expense.date.day}/${expense.date.month}/${expense.date.year}";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_outlined,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹ ${expense.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Person {
  String name;
  bool isYou;
  double splitPercentage = 0; // For percentage splits
  double customAmount = 0; // For custom amount splits

  Person({required this.name, this.isYou = false});
}

class BillItem {
  String name;
  double amount;

  BillItem({required this.name, this.amount = 0});
}

class Expense {
  final double amount;
  final String description;
  final DateTime date;
  final bool isEvenSplit;

  Expense({
    required this.amount, 
    required this.description, 
    required this.date, 
    required this.isEvenSplit
  });
}
