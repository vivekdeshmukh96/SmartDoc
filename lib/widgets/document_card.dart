import 'package:collegeapplication/widgets/status_badge.dart';
import 'package:flutter/material.dart';

import '../models/document.dart';
import '../utils/icon_map.dart'; // Import the icon map

class DocumentCard extends StatelessWidget {
  final Document document;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DocumentCard({
    super.key,
    required this.document,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                getIconForCategory(document.category), // Use the icon map
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${document.category}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 8),
                    StatusBadge(status: document.status),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}