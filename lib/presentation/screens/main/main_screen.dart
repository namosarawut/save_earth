import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:save_earth/data/local_storage_helper.dart';
import 'package:save_earth/data/model/item_model.dart';
import 'package:save_earth/data/model/user_model.dart';
import 'package:save_earth/logic/Bloc/auth/auth_bloc.dart';
import 'package:save_earth/logic/Bloc/item/item_bloc.dart';
import 'package:save_earth/route/convert_route.dart';



class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainAppScreen> {
  int tapIndex = 0;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;
  List<String>? allItems;
  final List<Map<String, dynamic>> myFavoriteList = [
    {
      "favorite_id": 501,
      "item": {
        "item_id": 77,
        "name": "ตู้เย็นเก่า",
        "image_url":
            "https://c.pxhere.com/photos/03/7e/toys_teddy_bear_plush_bear_plush_old_bear-778203.jpg!d",
        "category": "เครื่องใช้ไฟฟ้า",
        "description": "ตู้เย็นยังใช้งานได้แต่มีรอยขีดข่วนเล็กน้อย",
        "latitude": 13.7563,
        "longitude": 100.5018,
        "status": "available",
        "created_at": "2025-01-29T08:30:00Z",
        "posted_by": {
          "user_id": 301,
          "username": "jane_doe",
          "contact": {
            "first_name": "Jane",
            "last_name": "Doe",
            "phone_number": "+66987654321"
          }
        }
      },
      "added_at": "2025-02-01T10:15:00Z"
    },
    {
      "favorite_id": 502,
      "item": {
        "item_id": 88,
        "name": "โต๊ะไม้เก่า",
        "image_url":
            "https://c.pxhere.com/photos/03/7e/toys_teddy_bear_plush_bear_plush_old_bear-778203.jpg!d",
        "category": "เฟอร์นิเจอร์",
        "description": "โต๊ะไม้เก่าสภาพดี ไม่ได้ใช้แล้ว",
        "latitude": 13.7363,
        "longitude": 100.5238,
        "status": "available",
        "created_at": "2025-01-30T09:15:00Z",
        "posted_by": {
          "user_id": 302,
          "username": "alice_wonder",
          "contact": {
            "first_name": "Alice",
            "last_name": "Wonderland",
            "phone_number": "+66678901234"
          }
        }
      },
      "added_at": "2025-02-01T11:20:00Z"
    },
    {
      "favorite_id": 503,
      "item": {
        "item_id": 99,
        "name": "ตุ๊กตาหมี",
        "image_url":
            "https://c.pxhere.com/photos/03/7e/toys_teddy_bear_plush_bear_plush_old_bear-778203.jpg!d",
        "category": "ของใช้ส่วนตัว",
        "description": "ตุ๊กตาหมีนุ่มนิ่ม สภาพดี",
        "latitude": 13.7451,
        "longitude": 100.5392,
        "status": "taken",
        "created_at": "2025-01-28T14:45:00Z",
        "posted_by": {
          "user_id": 303,
          "username": "bob_marley",
          "contact": {
            "first_name": "Bob",
            "last_name": "Marley",
            "phone_number": "+66543210987"
          }
        }
      },
      "added_at": "2025-02-01T12:00:00Z"
    }
  ];
  List<String> filteredItems = [];
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("🔍 Selected File: ${pickedFile.path}");
      String? mimeType = lookupMimeType(pickedFile.path); // ตรวจสอบ MIME type
      print("📌 MIME Type: $mimeType");

      if (mimeType == "image/jpeg" || mimeType == "image/png" || mimeType == "image/jpg") {
        final user = await LocalStorageHelper.getUser(); // โหลดข้อมูล user

        if (user == null) {
          print("⚠️ User is null. Cannot update profile.");
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("⚠️ ไม่สามารถอัพเดทโปรไฟล์ได้ กรุณาลองใหม่"))
          );
          return;
        }

        // อัปเดตโปรไฟล์ผ่าน Bloc
        context.read<AuthBloc>().add(UpdateUserProfile(
          userId: user.userId,
          firstName: user.firstName?.isEmpty ?? true ? "" : user.firstName!,
          lastName: user.lastName?.isEmpty ?? true ? "" : user.lastName!,
          phoneNumber: user.phoneNumber?.isEmpty ?? true ? "" : user.phoneNumber!,
          profileImage: File(pickedFile.path),
        ));

        // อัปเดต UI
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ อัพเดทรูปโปรไฟล์เรียบร้อย"))
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ โปรดเลือกไฟล์ JPEG หรือ PNG เท่านั้น"))
        );
      }
    }
  }


  UserModel? user;

  Future<void> getUserData() async {
    user = await LocalStorageHelper.getUser();
  }

  void initApp() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        context.read<ItemBloc>().add(LoadUniqueItemNames());

        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ กรุณาเปิด GPS เพื่อใช้ฟีเจอร์นี้")),
          );
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.deniedForever) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("⚠️ คุณต้องเปิดสิทธิ์ GPS ใน Settings")),
            );
            return;
          }
        }

        Position position = await Geolocator.getCurrentPosition();

        // ✅ ตรวจสอบว่า Widget ยังอยู่ใน Tree ก่อนเรียกใช้ context
        if (!mounted) return;

        context.read<ItemBloc>().add(SearchItems(
          latitude: position.latitude,
          longitude: position.longitude,
        ));

      } catch (e) {
        if (!mounted) return;
        print("🚨 Error getting location: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ เกิดข้อผิดพลาดในการดึงตำแหน่ง")),
        );
      }
    });
  }



  @override
  void initState() {
    super.initState();
    initApp();
    getUserData();
    _getCurrentLocation();
    _searchController.addListener(() {
      filterSearchResults();
    });
  }

  void filterSearchResults() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        filteredItems = allItems!
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      } else {
        filteredItems.clear(); // ล้างรายการถ้าไม่มีการพิมพ์ข้อความ
      }
    });
  }

  void _searchItem(int index) async {
    // กำหนดค่าค้นหา
    final String searchText = filteredItems[index];

    // ดึงตำแหน่งปัจจุบัน
    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting location: $e");
      return;
    }

    // ส่ง event ไปที่ Bloc
    context.read<ItemBloc>().add(SearchItems(
          name: searchText.isEmpty ? null : searchText,
          latitude: position.latitude,
          longitude: position.longitude,
        ));

    // อัปเดต UI
    setState(() {
      _searchController.text = searchText;
      filteredItems.clear();
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    print("Location : ${position.latitude}, ${position.longitude}");

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // เมื่อได้ตำแหน่งล่าสุดแล้ว ให้เลื่อนแผนที่ไปที่ตำแหน่งนั้น
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, _currentZoom);
    }
  }

  void showRequestDialog(BuildContext context, ItemModel marker) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // มุมโค้ง 20
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "เหตุผลการร้องขอ สิ่งของ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "เหตุผลที่ท่านขอรับสิ่งของชิ้นนี้",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด Dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800], // สีเขียวเข้ม
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "ส่งคำขอ",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMarkerDetails(ItemModel marker) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width - 16,
          padding: EdgeInsets.all(16.0),
          child: ListView(
            // mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // กำหนดมุมโค้ง 20
                child: Image.network(
                  "http://192.168.1.153:8080${marker.imageUrl}",
                  width: MediaQuery.of(context).size.width - 8,
                  height: 200, // ความสูง 16:9
                  fit: BoxFit.cover, // ครอบคลุมพื้นที่โดยไม่เสียอัตราส่วน
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(marker.name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xffD9D9D9)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        marker.description,
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              // Text(marker.description),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "หมวดหมู่: ${marker.category}",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              SizedBox(height: 10),
              Text("ลงประกาศเมื่อ: ${marker.createdAt}"),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, (Routes.mainApp).toStringPath());
                  showRequestDialog(context, marker);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 80,
                  ),
                ),
                child: Text(
                  "ส่งคำขอ",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            height: 300,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "คุณแน่ใจหรือไม่ว่าต้องการ ออกจากระบบ",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton(context, "ยกเลิก", Colors.grey, () {
                      Navigator.of(context).pop();
                    }),
                    _buildDialogButton(context, "ใช่", Colors.green.shade900,
                        () {
                      log("logout");
                      context.read<AuthBloc>().add(LogoutUser());
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (Navigator.canPop(context)) {
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              (Routes.loginAndRegister).toStringPath(),
                              (route) => false);
                        } else {
                          Navigator.pushReplacementNamed(
                              context,
                              (Routes.loginAndRegister)
                                  .toStringPath()); // ถ้าไม่มี Route ให้ใช้ Replacement
                        }
                      });
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemBloc, ItemState>(
      listener: (context, itemState) {
        if (itemState is ItemNamesLoaded) {
          allItems = itemState.itemNames;
        }
        // TODO: implement listener
      },
      builder: (context, itemState) {
        if (itemState is ItemLoading) {
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Color(0xff598E0A),
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              )),
            ),
          );
        } else if (itemState is ItemNamesLoaded) {
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Color(0xff598E0A),
              child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
            ),
          );
        } else if (itemState is ItemListLoaded){
          return Scaffold(
            body: tapIndex == 0
                ? buildSearhScreen(context, itemState)
                : tapIndex == 1
                ? buildFAVScreen(context)
                : tapIndex == 2
                ? buildProfileScreen(context)
                : SizedBox.shrink(),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (i) {
                log("Tap Index: ${i}");
                setState(() {
                  tapIndex = i;
                });
              },
              currentIndex: tapIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: "Favorite",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: "Account",
                ),
              ],
            ),
          );
        }else{
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Color(0xff598E0A),
              child: Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  )),
            ),
          );
        }
      },
    );
  }

  Stack buildSearhScreen(BuildContext context, ItemListLoaded itemState) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition ?? LatLng(13.8588517, 101.99559),
            initialZoom: _currentZoom,
            onPositionChanged: (pos, bool hasGesture) {
              setState(() {
                _currentZoom = pos.zoom;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              // ไม่มี subdomain
              userAgentPackageName: 'com.example.save_earth',
            ),
            if (_currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition!,
                    width: 50,
                    height: 50,
                    child:
                        Icon(Icons.my_location, color: Colors.blue, size: 40),
                  ),
                ],
              ),
            MarkerLayer(
              markers: itemState.items.map((marker) {
                return Marker(
                  point: LatLng(marker.latitude, marker.longitude),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => _showMarkerDetails(marker),
                    child: Icon(
                      Icons.location_on,
                      color: marker.status == "available"
                          ? Colors.green
                          : Colors.red,
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          top: 40,
          left: 24,
          right: 24,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for what you want",
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                border: InputBorder.none,
                // contentPadding: EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ),
        ),
        Positioned(
          top: 75,
          left: 32,
          right: 32,
          child: filteredItems.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredItems[index]),
                        onTap: () async {
                          _searchItem(index);
                        },
                      );
                    },
                  ),
                )
              : Container(),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.85,
          left: MediaQuery.of(context).size.width * 0.85,
          child: GestureDetector(
            onTap: () {
              _getCurrentLocation();
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.my_location,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showRequestDialogOnFav(
      BuildContext context, Map<String, dynamic> requestListItem) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // มุมโค้ง 20
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "เหตุผลการร้องขอ สิ่งของ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "เหตุผลที่ท่านขอรับสิ่งของชิ้นนี้",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด Dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800], // สีเขียวเข้ม
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "ส่งคำขอ",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showItemDetailsOnFav(Map<String, dynamic> requestListItem) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width - 16,
          padding: EdgeInsets.all(16.0),
          child: ListView(
            // mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // กำหนดมุมโค้ง 20
                child: Image.network(
                  requestListItem['item']['image_url'],
                  width: MediaQuery.of(context).size.width - 8,
                  height: 200, // ความสูง 16:9
                  fit: BoxFit.cover, // ครอบคลุมพื้นที่โดยไม่เสียอัตราส่วน
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(requestListItem['item']['name'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xffD9D9D9)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        requestListItem['item']['description'],
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              // Text(marker.description),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "หมวดหมู่: ${requestListItem['item']['category']}",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              SizedBox(height: 10),
              Text("ลงประกาศเมื่อ: ${requestListItem['item']['created_at']}"),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, (Routes.mainApp).toStringPath());
                  showRequestDialogOnFav(context, requestListItem);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 80,
                  ),
                ),
                child: Text(
                  "ส่งคำขอ",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFAVScreen(BuildContext context) {
    return Container(
      color: Color(0xffF1F4F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                const Center(
                  child: Text(
                    "รายการ ถูกใจของฉัน",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Order List
            Expanded(
              child: ListView.builder(
                itemCount: myFavoriteList.length,
                itemBuilder: (context, index) {
                  final requestListItem = myFavoriteList[index];
                  // final requestCount = order["requests"].length;
                  return Dismissible(
                    key: Key(requestListItem["item"]["name"]),
                    // ต้องใช้ Key ที่ไม่ซ้ำกัน
                    direction: DismissDirection.endToStart,
                    // สไลด์จากขวาไปซ้าย
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      // ใส่โค้ดลบรายการที่นี่
                      print("${requestListItem["item"]["name"]} ถูกลบ!");
                    },
                    child: Card(
                      elevation: 1,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(requestListItem["item"]["name"],
                            style: TextStyle(fontSize: 16)),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          showItemDetailsOnFav(requestListItem);
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildProfileScreen(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 600,
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(color: Color(0xffF1F4F9)),
              ),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade900, Colors.green.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 24,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : user!.profileImageUrl == null
                              ? AssetImage("assets/image/profile.jpeg")
                                  as ImageProvider
                              : NetworkImage(
                                  "http://192.168.1.153:8080${user!.profileImageUrl}"),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 216, 0, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          user!.firstName == null || user!.firstName == ""
                              ? user!.username
                              : "${user!.firstName} ${user!.lastName}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          user!.email,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        const Text(
                          "การจัดการ",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Management Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            "แก้ไขบัญชี",
                            () {
                              context
                                  .read<AuthBloc>()
                                  .add(GetUserById(user!.userId));
                              Navigator.pushNamed(
                                  context, (Routes.editProfile).toStringPath());
                            },
                          ),
                          _buildMenuItem(
                            "รายการ order",
                            () {
                              Navigator.pushNamed(
                                  context, (Routes.myItemList).toStringPath());
                            },
                          ),
                          _buildMenuItem(
                            "สร้างสิ่งของของฉัน",
                            () {
                              Navigator.pushNamed(context,
                                  (Routes.createMyItem).toStringPath());
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Logout Button
                    TextButton(
                      onPressed: () {
                        _showLogoutConfirmDialog(context);
                      },
                      child: const Text(
                        "ออกจากระบบ",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, VoidCallback? onTap) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
