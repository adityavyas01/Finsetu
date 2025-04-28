import 'package:flutter/material.dart';

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Person> _people = [Person(name: 'You', isYou: true), Person(name: 'Friend 1')];
  
  bool _isEvenSplit = true;
  bool _isItemized = false;
  List<BillItem> _billItems = [];
  
  TabController? _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize with one bill item
    _billItems.add(BillItem(name: 'Item 1', amount: 0));
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
              child: const Text(
                "Split Bill",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        bottom: !isWideScreen ? TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          tabs: const [
            Tab(text: "DETAILS"),
            Tab(text: "SUMMARY"),
          ],
        ) : null,
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
                    "Create Split Request",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Enter bill details and add friends to split with",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInputForm(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor),
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
        // Details Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Split Request",
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Enter bill details and add friends to split with",
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildInputForm(mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor),
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

  Widget _buildInputForm(
    LinearGradient mainGradient,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color inputFillColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bill description
        Text(
          "Description",
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
            hintText: "Dinner, Movie, etc.",
            hintStyle: TextStyle(color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.description_outlined, color: secondaryTextColor),
          ),
        ),
        const SizedBox(height: 24),
        
        // Total amount
        Text(
          "Total Amount",
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
          style: TextStyle(color: primaryTextColor, fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFillColor,
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Text(
                "₹",
                style: TextStyle(color: accentColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
            hintText: "0.00",
            hintStyle: TextStyle(color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        
        // Split type toggle
        Text(
          "Split Type",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isEvenSplit = true;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isEvenSplit ? accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Even Split",
                      style: TextStyle(
                        color: _isEvenSplit ? Colors.black : secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isEvenSplit = false;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: !_isEvenSplit ? accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Custom Split",
                      style: TextStyle(
                        color: !_isEvenSplit ? Colors.black : secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Item details toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Itemized Bill",
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: _isItemized,
              onChanged: (value) {
                setState(() {
                  _isItemized = value;
                });
              },
              activeColor: accentColor,
              activeTrackColor: accentColor.withOpacity(0.3),
            ),
          ],
        ),
        
        // Itemized bill section
        if (_isItemized) ...[
          const SizedBox(height: 16),
          ..._billItems.map((item) => _buildItemRow(item, mainGradient, accentColor, primaryTextColor, secondaryTextColor, inputFillColor)).toList(),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _billItems.add(BillItem(name: 'Item ${_billItems.length + 1}', amount: 0));
                });
              },
              icon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(Icons.add_circle_outline),
              ),
              label: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Text(
                  "Add Item",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Friends section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "People",
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _people.add(Person(name: 'Friend ${_people.length}'));
                });
              },
              icon: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Icon(Icons.person_add_alt),
              ),
              label: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => mainGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: const Text(
                  "Add Person",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._buildPeopleList(primaryTextColor, secondaryTextColor, inputFillColor, mainGradient),
      ],
    );
  }
  
  Widget _buildItemRow(
    BillItem item, 
    LinearGradient mainGradient, 
    Color accentColor, 
    Color primaryTextColor, 
    Color secondaryTextColor, 
    Color inputFillColor
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: item.name),
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintText: "Item name",
                hintStyle: TextStyle(color: secondaryTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  item.name = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextField(
              controller: TextEditingController(text: item.amount > 0 ? item.amount.toString() : ""),
              keyboardType: TextInputType.number,
              style: TextStyle(color: primaryTextColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintText: "0.00",
                hintStyle: TextStyle(color: secondaryTextColor),
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "₹",
                    style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  item.amount = double.tryParse(value) ?? 0;
                  _updateTotalFromItems();
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: secondaryTextColor),
            onPressed: () {
              setState(() {
                _billItems.remove(item);
                _updateTotalFromItems();
              });
            },
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
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    final perPersonAmount = _people.isNotEmpty ? totalAmount / _people.length : 0;
    
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
                "₹ ${totalAmount.toStringAsFixed(2)}",
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
          ..._people.map((person) => _buildCustomSplitRow(person, totalAmount, inputFillColor, primaryTextColor, secondaryTextColor)).toList(),
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

  List<Widget> _buildPeopleList(Color primaryTextColor, Color secondaryTextColor, Color inputFillColor, LinearGradient gradient) {
    return _people.map((person) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: person.isYou ? const Color(0xFFE8FA7A) : Colors.grey[800],
              child: Icon(
                Icons.person,
                size: 20,
                color: person.isYou ? Colors.black : primaryTextColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: person.name),
                style: TextStyle(color: primaryTextColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Enter name",
                  hintStyle: TextStyle(color: secondaryTextColor),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    person.name = value;
                  });
                },
              ),
            ),
            if (!_isEvenSplit)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => gradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // In a real app, show a dialog to edit the split percentage
                  },
                ),
              ),
            if (!person.isYou) 
              IconButton(
                icon: Icon(Icons.close, color: secondaryTextColor),
                onPressed: () {
                  setState(() {
                    _people.remove(person);
                  });
                },
              ),
          ],
        ),
      );
    }).toList();
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
  
  void _updateTotalFromItems() {
    if (_isItemized && _billItems.isNotEmpty) {
      double total = 0;
      for (var item in _billItems) {
        total += item.amount;
      }
      _totalAmountController.text = total.toString();
    }
  }
}

class Person {
  String name;
  bool isYou;
  double splitPercentage = 0; // For custom splits
  
  Person({required this.name, this.isYou = false});
}

class BillItem {
  String name;
  double amount;
  
  BillItem({required this.name, this.amount = 0});
}
