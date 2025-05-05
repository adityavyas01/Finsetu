import 'package:flutter/material.dart';
import 'package:finsetu_app/screens/split_bill_screen.dart';

class BillGroup {
  final String id;
  final String name;
  final List<Person> members;
  final String lastActivity;
  
  BillGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.lastActivity,
  });
}

class Person {
  String name;
  bool isYou;
  String? avatarUrl;
  
  Person({required this.name, this.isYou = false, this.avatarUrl});
}

class BillGroupsScreen extends StatefulWidget {
  const BillGroupsScreen({super.key});

  @override
  State<BillGroupsScreen> createState() => _BillGroupsScreenState();
}

class _BillGroupsScreenState extends State<BillGroupsScreen> {
  final _newGroupNameController = TextEditingController();
  
  // List of contacts to select from when creating a group
  final List<Person> _contacts = [
    Person(name: 'Alex'),
    Person(name: 'Taylor'),
    Person(name: 'Rishi'),
    Person(name: 'Priya'),
    Person(name: 'Neha'),
    Person(name: 'Amit'),
    Person(name: 'Sneha'),
    Person(name: 'Raj'),
    Person(name: 'Aarav'),
    Person(name: 'Meera'),
  ];
  
  // To track selected people when creating a group
  final List<Person> _selectedPeople = [];
  
  // Mock data for groups
  final List<BillGroup> _groups = [
    BillGroup(
      id: '1',
      name: 'Roommates',
      members: [
        Person(name: 'You', isYou: true),
        Person(name: 'Alex'),
        Person(name: 'Taylor'),
      ],
      lastActivity: '2 days ago',
    ),
    BillGroup(
      id: '2',
      name: 'Trip to Goa',
      members: [
        Person(name: 'You', isYou: true),
        Person(name: 'Rishi'),
        Person(name: 'Priya'),
        Person(name: 'Neha'),
      ],
      lastActivity: '1 week ago',
    ),
    BillGroup(
      id: '3',
      name: 'Dinner Group',
      members: [
        Person(name: 'You', isYou: true),
        Person(name: 'Amit'),
        Person(name: 'Sneha'),
      ],
      lastActivity: '2 weeks ago',
    ),
  ];

  @override
  void dispose() {
    _newGroupNameController.dispose();
    super.dispose();
  }

  void _showCreateGroupDialog() {
    // Reset selected people list except 'You'
    _selectedPeople.clear();
    _selectedPeople.add(Person(name: 'You', isYou: true));
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Create New Group', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _newGroupNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter group name',
                        hintStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE8FA7A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select People',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_selectedPeople.length - 1} selected', // Subtract 1 to exclude "You"
                          style: const TextStyle(
                            color: Color(0xFFE8FA7A),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Show selected people chips
                    if (_selectedPeople.length > 1) // If more than just "You"
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPeople.length,
                          itemBuilder: (context, index) {
                            final person = _selectedPeople[index];
                            if (person.isYou) return Container(); // Skip "You" in the chip display
                            
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Chip(
                                backgroundColor: const Color(0xFF333333),
                                label: Text(
                                  person.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                avatar: CircleAvatar(
                                  backgroundColor: const Color(0xFFE8FA7A),
                                  child: Text(
                                    person.name[0],
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedPeople.remove(person);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final person = _contacts[index];
                          final isSelected = _selectedPeople.any((p) => p.name == person.name);
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? const Color(0xFFE8FA7A) : Colors.grey[700],
                              child: Text(
                                person.name[0],
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              person.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Color(0xFFE8FA7A))
                              : const Icon(Icons.circle_outlined, color: Colors.grey),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedPeople.removeWhere((p) => p.name == person.name);
                                } else {
                                  _selectedPeople.add(person);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedPeople.length > 1 
                          ? 'Group will have ${_selectedPeople.length} members including you'
                          : 'Add at least one person to create a group',
                      style: TextStyle(
                        color: _selectedPeople.length > 1 ? const Color(0xFFE8FA7A) : Colors.orange,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: _selectedPeople.length > 1 && _newGroupNameController.text.trim().isNotEmpty
                      ? () {
                          final newGroup = BillGroup(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: _newGroupNameController.text,
                            members: List.from(_selectedPeople),
                            lastActivity: 'Just now',
                          );
                          
                          setState(() {
                            this.setState(() {
                              _groups.add(newGroup);
                            });
                            _newGroupNameController.clear();
                          });
                          
                          Navigator.pop(context);
                          
                          // Navigate to split bill screen with the new group
                          _navigateToSplitBill(newGroup);
                        }
                      : null,
                  child: Text(
                    'Create', 
                    style: TextStyle(
                      color: _selectedPeople.length > 1 && _newGroupNameController.text.trim().isNotEmpty
                          ? const Color(0xFFE8FA7A)
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToSplitBill(BillGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitBillScreen(group: group),
      ),
    );
  }

  void _deleteGroup(BillGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Delete ${group.name}?', style: const TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete this group and its bill history.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _groups.removeWhere((g) => g.id == group.id);
              });
              Navigator.pop(context);
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('${group.name} has been deleted'),
                    ],
                  ),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: const Color(0xFFE8FA7A),
                    onPressed: () {
                      setState(() {
                        _groups.add(group);
                        // Sort groups to restore original position
                        // This is simplified; in a real app you might want to store the index
                        _groups.sort((a, b) => a.id.compareTo(b.id));
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
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
        backgroundColor: darkSurfaceColor,
        elevation: 0,
        toolbarHeight: 80, // Increased height to add space before
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
                "Bill Split Groups",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add space after AppBar
          const SizedBox(height: 16),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              "Select a group to split bills",
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ),
          
          // Create new group button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: _showCreateGroupDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: mainGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "CREATE NEW GROUP",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Existing groups header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your Groups",
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_groups.length} groups",
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Group list
          Expanded(
            child: _groups.isEmpty
                ? const Center(
                    child: Text(
                      "You haven't created any groups yet",
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _groups.length,
                    itemBuilder: (context, index) {
                      final group = _groups[index];
                      return _buildGroupItem(
                        group: group,
                        inputFillColor: inputFillColor,
                        accentColor: accentColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem({
    required BillGroup group,
    required Color inputFillColor,
    required Color accentColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToSplitBill(group),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        group.lastActivity,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                      // Replace PopupMenuButton with a direct IconButton
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => _deleteGroup(group),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Show member avatars
                  for (int i = 0; i < (group.members.length > 4 ? 4 : group.members.length); i++)
                    Container(
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: inputFillColor, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: group.members[i].isYou ? accentColor : Colors.grey[600],
                        child: Text(
                          group.members[i].name[0].toUpperCase(),
                          style: TextStyle(
                            color: group.members[i].isYou ? Colors.black : primaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (group.members.length > 4)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: inputFillColor, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[800],
                        child: Text(
                          "+${group.members.length - 4}",
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
