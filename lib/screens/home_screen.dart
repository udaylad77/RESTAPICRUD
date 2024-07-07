import 'package:flutter/material.dart';
import 'package:restapipractice/models/user_model.dart';
import 'package:restapipractice/screens/add_user.dart';
import 'package:restapipractice/screens/edit_user_screen.dart';
import 'package:restapipractice/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<User>> futureUsers;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    futureUsers = userService.fetchUsers();
  }

  void _refreshUsers(User newUser) {
    futureUsers.then((currentUsers) {
      setState(() {
        futureUsers = Future.value([...currentUsers, newUser]);
      });
    });
  }

  Future<void> _deleteUser(User user) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${user.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed delete
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancelled delete
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        await userService.deleteUser(user.id);
        setState(() {
          futureUsers =
              userService.fetchUsers(); // Refresh user list after deletion
        });
      } catch (e) {
        print('Failed to delete user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user')),
        );
      }
    }
  }

  void _editUser(User user) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserScreen(user)),
    );

    if (updatedUser != null) {
      _refreshUsers(updatedUser); // Refresh user list after editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                User user = users[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Name: ${user.name}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editUser(
                                      user), // Navigate to edit screen
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteUser(user),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text('Email: ${user.email}',
                            style: TextStyle(fontSize: 16)),
                        Text('Phone: ${user.phone}',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load users'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newUser = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserScreen()),
          );

          if (newUser != null) {
            _refreshUsers(newUser); // Refresh user list after adding new user
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
