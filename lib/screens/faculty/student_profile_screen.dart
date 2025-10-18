import 'package:flutter/material.dart';
import 'package:smart_doc/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/document.dart' as doc;
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class StudentProfileScreen extends StatelessWidget {
  final User user;

  const StudentProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 1,
                iconTheme: const IconThemeData(color: Colors.black87),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blueAccent,
                    tabs: [
                      Tab(text: 'Details'),
                      Tab(text: 'Documents'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildDetailsTab(),
              _buildDocumentsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: (user.photoURL != null && user.photoURL!.isNotEmpty)
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: (user.photoURL == null || user.photoURL!.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: Colors.blueAccent)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user.name ?? 'N/A',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildInfoCard('Student ID', user.studentId ?? 'N/A', Icons.credit_card),
        _buildInfoCard('Year', user.year ?? 'N/A', Icons.calendar_today),
        _buildInfoCard('Section', user.section ?? 'N/A', Icons.class_),
        _buildInfoCard('Department', user.department ?? 'N/A', Icons.school),
        _buildInfoCard('Contact No', user.contactNo ?? 'N/A', Icons.phone),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .collection('documents')
          .orderBy('uploadedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No documents found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final docData = snapshot.data!.docs[index];
            final document = doc.Document.fromFirestore(
                docData.data() as Map<String, dynamic>, docData.id);
            return _buildDocumentTile(context, document);
          },
        );
      },
    );
  }

  Widget _buildDocumentTile(BuildContext context, doc.Document document) {
    DateTime? uploadedDateTime = DateTime.tryParse(document.uploadedDate);
    return InkWell(
      onTap: () async {
        if (document.downloadUrl != null && document.downloadUrl!.isNotEmpty) {
          final Uri url = Uri.parse(document.downloadUrl!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch document')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document URL is not available.')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, color: Colors.blue.shade700, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (uploadedDateTime != null)
                    Text(
                      'Uploaded ${timeago.format(uploadedDateTime)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildStatusChip(document.status),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(doc.DocumentStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case doc.DocumentStatus.approved:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        text = 'Approved';
        break;
      case doc.DocumentStatus.pending:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        text = 'Pending';
        break;
      case doc.DocumentStatus.rejected:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        text = 'Rejected';
        break;
      case doc.DocumentStatus.resubmission:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        text = 'Resubmission';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
