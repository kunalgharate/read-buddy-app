import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // 🔷 Top Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  // I think here should be edited to made a gap on the prfile image and its labeled icons so that it would not overwrite with the battery icons and etc...
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Row(
                      children: [
                        // profile Image
                        const CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              AssetImage("assets/icons/Fiction.png"),
                        ),
                        const SizedBox(width: 16),
                        // Name & Role
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Sanglap",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Student",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //Settings Icon (top right)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.settings, color: Colors.green),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Scrollable List Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildItem(Icons.account_tree, "Admin Workflow"),
                  _buildItem(Icons.favorite_border, "My Wishlist"),
                  _buildItem(Icons.location_on_outlined, "Address"),
                  _buildItem(Icons.library_books, "My Request"),
                  _buildItem(Icons.download, "Downloads"),
                  _buildItem(Icons.emoji_events_outlined, "Rewards"),
                  _buildItem(Icons.notifications_none, "Notification"),
                  _buildItem(Icons.feedback_outlined, "Feedback"),
                  _buildItem(Icons.privacy_tip_outlined, "Privacy Policy"),
                  _buildItem(Icons.logout, "Logout",
                      iconColor: Colors.red, textColor: Colors.red),
                  SizedBox(height: 55)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 List Tile Builder
  Widget _buildItem(
    IconData icon,
    String title, {
    Color iconColor = const Color.fromRGBO(5, 46, 68, 1),
    Color textColor = const Color.fromRGBO(5, 46, 68, 1),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
        onTap: () {
          // TODO: Navigation or logic here
        },
      ),
    );
  }
}
