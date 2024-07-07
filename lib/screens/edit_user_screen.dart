import 'package:flutter/material.dart';
import 'package:restapipractice/models/user_model.dart';
import 'package:restapipractice/services/user_service.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  EditUserScreen(this.user);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone;
  }

  void _updateUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
      try {
        User updatedUser = await _userService.updateUser(User(
          id: widget.user.id,
          name: name,
          email: email,
          phone: phone,
        ));
        Navigator.pop(context, updatedUser);
      } catch (e) {
        print('Failed to update user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateUser,
              child: Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
