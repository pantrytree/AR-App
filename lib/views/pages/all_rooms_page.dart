import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/room_category_model.dart';
import 'furniture_catalogue_page.dart';
import '../../utils/colors.dart';

class AllRoomsPage extends StatelessWidget {
  const AllRoomsPage({super.key});

  final List<RoomCategory> rooms = const [
    RoomCategory(name: 'Living Room', icon: Icons.weekend, color: AppColors.greyLavenderOpaque),
    RoomCategory(name: 'Bedroom', icon: Icons.bed, color: AppColors.greyLavenderOpaque),
    RoomCategory(name: 'Office', icon: Icons.work, color: AppColors.greyLavenderOpaque),
    RoomCategory(name: 'Kitchen', icon: Icons.kitchen, color: AppColors.greyLavenderOpaque),
    RoomCategory(name: 'Dining Room', icon: Icons.dining, color: AppColors.greyLavenderOpaque),
    RoomCategory(name: 'Bathroom', icon: Icons.bathtub, color: AppColors.greyLavenderOpaque),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getAppBarBackground(context),
        elevation: 0,
        title: Text(
          'All Rooms',
          style: TextStyle(
            color: AppColors.getAppBarForeground(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.getAppBarForeground(context),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // Match furniture catalog aspect ratio
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildRoomCard(context, room);
          },
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomCategory room) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FurnitureCataloguePage(
              initialRoom: _convertRoomNameToCategory(room.name),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reduced image section height
            Container(
              height: 100, // Reduced from 120
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      room.icon,
                      size: 35, // Reduced from 40
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_getRoomItemCount(room.name)}+',
                        style: GoogleFonts.inter(
                          fontSize: 9, // Reduced from 10
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLightPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Reduced content section height
            Container(
              height: 85, // Reduced from 110
              padding: const EdgeInsets.all(10), // Reduced from 12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: GoogleFonts.inter(
                          fontSize: 13, // Reduced from 14
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // Reduced from 4
                      Text(
                        '${_getRoomItemCount(room.name)} items',
                        style: GoogleFonts.inter(
                          fontSize: 11, // Reduced from 12
                          color: AppColors.getSecondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12, // Reduced from 14
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 2), // Reduced from 4
                          Text(
                            'Popular items',
                            style: GoogleFonts.inter(
                              fontSize: 11, // Reduced from 12
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2), // Reduced from 4
                      SizedBox(
                        height: 18, // Reduced from 20
                        child: Wrap(
                          spacing: 3, // Reduced from 4
                          runSpacing: 3, // Reduced from 4
                          children: _getRoomPopularItems(room.name).map((item) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.getCardBackground(context),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: AppColors.getSecondaryTextColor(context).withOpacity(0.3)),
                            ),
                            child: Text(
                              item,
                              style: GoogleFonts.inter(
                                fontSize: 9, // Reduced from 10
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                          )).toList(),
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
    );
  }

  int _getRoomItemCount(String roomName) {
    switch (roomName.toLowerCase()) {
      case 'living room':
        return 24;
      case 'bedroom':
        return 18;
      case 'office':
        return 15;
      case 'kitchen':
        return 12;
      case 'dining room':
        return 10;
      case 'bathroom':
        return 8;
      default:
        return 0;
    }
  }

  List<String> _getRoomPopularItems(String roomName) {
    switch (roomName.toLowerCase()) {
      case 'living room':
        return ['Sofa', 'TV Stand', 'Coffee Table'];
      case 'bedroom':
        return ['Bed', 'Wardrobe', 'Dresser'];
      case 'office':
        return ['Desk', 'Chair', 'Bookshelf'];
      case 'kitchen':
        return ['Cabinet', 'Stool', 'Table'];
      case 'dining room':
        return ['Dining Table', 'Chair', 'Sideboard'];
      case 'bathroom':
        return ['Cabinet', 'Stool', 'Shelves'];
      default:
        return ['Furniture'];
    }
  }

  String _convertRoomNameToCategory(String roomName) {
    switch (roomName.toLowerCase()) {
      case 'living room':
        return 'living room';
      case 'bedroom':
        return 'bedroom';
      case 'office':
        return 'office';
      case 'kitchen':
        return 'kitchen';
      case 'dining room':
        return 'dining';
      case 'bathroom':
        return 'bathroom';
      default:
        return 'all';
    }
  }
}