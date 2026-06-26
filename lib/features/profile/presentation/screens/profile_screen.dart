import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _exampleProfiles = [
    {
      'name': 'Jane Doe',
      'email': 'jane.doe@example.com',
      'createdAt': '2025-09-12',
    },
    {
      'name': 'John Smith',
      'email': 'john.smith@example.com',
      'createdAt': '2025-10-01',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _exampleProfiles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final profile = _exampleProfiles[index];
          return Card(
            child: ListTile(
              title: Text(profile['name'] as String),
              subtitle: Text(profile['email'] as String),
              trailing: Text(
                profile['createdAt'] as String,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}
