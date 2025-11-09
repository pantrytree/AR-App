//File is no longer being used as it is not part of scope for submission

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../../models/room.dart';
// import '../../services/room_service.dart';
// import 'furniture_catalogue_page.dart';
// import '../../utils/colors.dart';
//
// class AllRoomsPage extends StatefulWidget {
//   const AllRoomsPage({super.key});
//
//   @override
//   State<AllRoomsPage> createState() => _AllRoomsPageState();
// }
//
// class _AllRoomsPageState extends State<AllRoomsPage> {
//   final RoomService _roomService = RoomService();
//   List<Room> _rooms = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadRooms();
//   }
//
//   Future<void> _loadRooms() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });
//
//       final rooms = await _roomService.getRooms();
//       setState(() {
//         _rooms = rooms;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load rooms: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.getBackgroundColor(context),
//       appBar: AppBar(
//         backgroundColor: AppColors.getAppBarBackground(context),
//         elevation: 0,
//         title: Text(
//           'All Rooms',
//           style: TextStyle(
//             color: AppColors.getAppBarForeground(context),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: AppColors.getAppBarForeground(context),
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadRooms,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? _buildLoadingState()
//           : _errorMessage != null
//           ? _buildErrorState()
//           : _rooms.isEmpty
//           ? _buildEmptyState()
//           : _buildRoomsGrid(),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }
//
//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64,
//             color: AppColors.error,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Failed to load rooms',
//             style: TextStyle(
//               fontSize: 18,
//               color: AppColors.getTextColor(context),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage!,
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.getSecondaryTextColor(context),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _loadRooms,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.home_work_outlined,
//             size: 64,
//             color: AppColors.getSecondaryTextColor(context),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No rooms available',
//             style: TextStyle(
//               fontSize: 18,
//               color: AppColors.getTextColor(context),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Rooms will be available soon',
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.getSecondaryTextColor(context),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRoomsGrid() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: 0.85,
//         ),
//         itemCount: _rooms.length,
//         itemBuilder: (context, index) {
//           final room = _rooms[index];
//           return _buildRoomCard(context, room);
//         },
//       ),
//     );
//   }
//
//   Widget _buildRoomCard(BuildContext context, RoomInfo room) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FurnitureCataloguePage(
//               initialRoom: _convertRoomNameToCategory(room.name),
//             ),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.getCardBackground(context),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image section
//             Container(
//               height: 100,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               ),
//               child: Stack(
//                 children: [
//                   Center(
//                     child: Icon(
//                       room.icon,
//                       size: 35,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '${room.itemCount}+',
//                         style: GoogleFonts.inter(
//                           fontSize: 9,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Content section
//             Container(
//               height: 85,
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         room.name,
//                         style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.getTextColor(context),
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         '${room.itemCount} items',
//                         style: GoogleFonts.inter(
//                           fontSize: 11,
//                           color: AppColors.getSecondaryTextColor(context),
//                           fontWeight: FontWeight.w500,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.star,
//                             size: 12,
//                             color: AppColors.primaryPurple,
//                           ),
//                           const SizedBox(width: 2),
//                           Text(
//                             'Popular items',
//                             style: GoogleFonts.inter(
//                               fontSize: 11,
//                               color: AppColors.getTextColor(context),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 2),
//                       SizedBox(
//                         height: 18,
//                         child: Wrap(
//                           spacing: 3,
//                           runSpacing: 3,
//                           children: furnitureItem.take(3).map((item) => Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                             decoration: BoxDecoration(
//                               color: AppColors.getCardBackground(context),
//                               borderRadius: BorderRadius.circular(3),
//                               border: Border.all(color: AppColors.getSecondaryTextColor(context).withOpacity(0.3)),
//                             ),
//                             child: Text(
//                               item,
//                               style: GoogleFonts.inter(
//                                 fontSize: 9,
//                                 color: AppColors.getSecondaryTextColor(context),
//                               ),
//                             ),
//                           )).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _convertRoomNameToCategory(String roomName) {
//     switch (roomName.toLowerCase()) {
//       case 'living room':
//         return 'living room';
//       case 'bedroom':
//         return 'bedroom';
//       case 'office':
//         return 'office';
//       case 'kitchen':
//         return 'kitchen';
//       case 'dining room':
//         return 'dining';
//       case 'bathroom':
//         return 'bathroom';
//       default:
//         return roomName.toLowerCase();
//     }
//   }
// }
