import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/role.dart';
import 'package:smart_doc/utils/string_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/message_box.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Role? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAddUserModal(BuildContext context) {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _selectedRole = null;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Add New User', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Role>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.assignment_ind)),
                  items: Role.values.map((role) {
                    return DropdownMenuItem<Role>(
                      value: role,
                      child: Text(role.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
                  onChanged: (role) {
                    setState(() {
                      _selectedRole = role;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _passwordController.text.isEmpty ||
                    _selectedRole == null) {
                  showMessageBox(context, 'Error', 'Please fill all fields.');
                  return;
                }
                try {
                  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'role': _selectedRole.toString().split('.').last,
                  });
                  Navigator.of(context).pop();
                  showMessageBox(context, 'Success', 'User added successfully.');
                } on FirebaseAuthException catch (e) {
                  showMessageBox(context, 'Error', e.message ?? 'An unknown error occurred.');
                } catch (e) {
                  showMessageBox(context, 'Error', e.toString());
                }
              },
              child: const Text('Add User'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteUser(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete user "$userName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(userId).delete();
                  Navigator.of(context).pop();
                  showMessageBox(context, 'Success', 'User deleted successfully.');
                } catch (e) {
                  showMessageBox(context, 'Error', e.toString());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Users',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserModal(context),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Add User', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 100, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text(
                          'No users found.',
                          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final user = (
                      id: doc.id,
                      name: doc['name'],
                      email: doc['email'],
                      role: Role.values.firstWhere((e) => e.toString() == 'Role.${doc['role']}'),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                          child: Icon(
                            _getRoleIcon(user.role),
                            color: _getRoleColor(user.role),
                            size: 28,
                          ),
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(user.email, style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(user.role.toString().split('.').last.capitalize()),
                              backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                              labelStyle: TextStyle(color: _getRoleColor(user.role), fontWeight: FontWeight.w600),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteUser(context, user.id, user.name),
                          tooltip: 'Delete User',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Color _getRoleColor(Role role) {
  switch (role) {
    case Role.student:
      return Colors.blue.shade700;
    case Role.faculty:
      return Colors.orange.shade700;
    case Role.admin:
      return Colors.red.shade700;
    default:
      return Colors.grey.shade700;
  }
}

IconData _getRoleIcon(Role role) {
  switch (role) {
    case Role.student:
      return Icons.school_outlined;
    case Role.faculty:
      return Icons.work_outline;
    case Role.admin:
      return Icons.admin_panel_settings_outlined;
    default:
      return Icons.person_outline;
  }
}
}
