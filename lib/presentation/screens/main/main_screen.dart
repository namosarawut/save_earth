import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:save_earth/constants/constants.dart';
import 'package:save_earth/data/local_storage_helper.dart';
import 'package:save_earth/data/model/favorite_model.dart';
import 'package:save_earth/data/model/item_model.dart';
import 'package:save_earth/data/model/user_model.dart';
import 'package:save_earth/logic/Bloc/add_favorite/add_favorite_bloc.dart';
import 'package:save_earth/logic/Bloc/auth/auth_bloc.dart';
import 'package:save_earth/logic/Bloc/create_request/create_request_bloc.dart';
import 'package:save_earth/logic/Bloc/delete_favorite/delete_favorite_bloc.dart';
import 'package:save_earth/logic/Bloc/get_favorites/get_favorites_bloc.dart';
import 'package:save_earth/logic/Bloc/item/item_bloc.dart';
import 'package:save_earth/logic/Bloc/search_data/searh_data_bloc.dart';
import 'package:save_earth/route/convert_route.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppState();
}

class _MainAppState extends State<MainAppScreen> {
  int tapIndex = 0;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;
  List<String>? allItems;
  final List<String> categories = [
    "เฟอร์นิเจอร์",
    "เครื่องใช้ไฟฟ้า",
    "เสื้อผ้า",
    "หนังสือ",
    "ของใช้ในบ้าน",
    "ของเล่น",
    "ของใช้ส่วนตัว"
  ];

  List<String> filteredItems = [];
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      log("🔍 Selected File: ${pickedFile.path}");
      String? mimeType = lookupMimeType(pickedFile.path); // ตรวจสอบ MIME type
      log("📌 MIME Type: $mimeType");

      if (mimeType == "image/jpeg" ||
          mimeType == "image/png" ||
          mimeType == "image/jpg") {
        final user = await LocalStorageHelper.getUser(); // โหลดข้อมูล user

        if (user == null) {
          log("⚠️ User is null. Cannot update profile.");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("⚠️ ไม่สามารถอัพเดทโปรไฟล์ได้ กรุณาลองใหม่")));
          return;
        }

        // อัปเดตโปรไฟล์ผ่าน Bloc
        context.read<AuthBloc>().add(UpdateUserProfile(
              userId: user.userId,
              firstName: user.firstName?.isEmpty ?? true ? "" : user.firstName!,
              lastName: user.lastName?.isEmpty ?? true ? "" : user.lastName!,
              phoneNumber:
                  user.phoneNumber?.isEmpty ?? true ? "" : user.phoneNumber!,
              profileImage: File(pickedFile.path),
            ));

        // อัปเดต UI
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ อัพเดทรูปโปรไฟล์เรียบร้อย")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ โปรดเลือกไฟล์ JPEG หรือ PNG เท่านั้น")));
      }
    }
  }

  UserModel? user;

  Future<void> getUserData() async {
    final newUser = await LocalStorageHelper.getUser(); // ✅ โหลดข้อมูลก่อน
    if (!mounted) return; // ✅ ป้องกัน setState() หลังจาก widget ถูก dispose

    setState(() {
      user = newUser; // ✅ อัปเดต state เฉพาะใน setState()
    });

    log("user name: ${user}");
  }

  void initApp() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        context.read<ItemBloc>().add(LoadUniqueItemNames());
        _fetchFavorites();
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

        context.read<SearchDataBloc>().add(SearchItems(
              latitude: position.latitude,
              longitude: position.longitude,
            ));
      } catch (e) {
        if (!mounted) return;
        log("🚨 Error getting location: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ เกิดข้อผิดพลาดในการดึงตำแหน่ง")),
        );
      }
    });
  }

  void _fetchFavorites() async {
    final user = await LocalStorageHelper.getUser();
    if (user != null) {
      context.read<GetFavoritesBloc>().add(FetchFavoritesByUserId(user.userId));
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    initApp();
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
      log("Error getting location: $e");
      return;
    }

    // ส่ง event ไปที่ Bloc
    context.read<SearchDataBloc>().add(SearchItems(
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
    log("Location : ${position.latitude}, ${position.longitude}");

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // เมื่อได้ตำแหน่งล่าสุดแล้ว ให้เลื่อนแผนที่ไปที่ตำแหน่งนั้น
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_currentPosition != null) {
          _mapController.move(_currentPosition!, _currentZoom);
        }
      }
    });
  }

  void showRequestDialog(BuildContext context, ItemModel marker) {
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
                    _submitRequest(marker,context);
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
    bool isFavorite = false;
    bool isItemFavorite(List<FavoriteModel> favdata, int inputId) {
      return favdata.any((favorite) => favorite.item.itemId == inputId);
    }

    void removeFavorite(int itemId) async {
      final user = await LocalStorageHelper.getUser();
      if (user != null) {
        context
            .read<DeleteFavoriteBloc>()
            .add(DeleteFavoriteItem(userId: user.userId, itemId: itemId));
      } else {
        setState(() {
          isFavorite = true;
        });
      }
    }

    void addFavorite(int itemId) async {
      final user = await LocalStorageHelper.getUser();
      if (user != null) {
        context.read<AddFavoriteBloc>().add(
              AddFavoriteItem(userId: user.userId, itemId: itemId),
            );
      } else {
        setState(() {
          isFavorite = false;
        });
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BlocConsumer<GetFavoritesBloc, GetFavoritesState>(
          listener: (context, getFavoritesState) {
            if (getFavoritesState is GetFavoritesLoaded) {
              log("FavData : ${getFavoritesState.favorites[0].item.itemId}");
              if (isItemFavorite(getFavoritesState.favorites, marker.itemId)) {
                setState(() {
                  isFavorite = true;
                });
              } else {
                setState(() {
                  isFavorite = false;
                });
              }
            }
          },
          builder: (context, state) {
            return BlocConsumer<AddFavoriteBloc, AddFavoriteState>(
              listener: (context, addFavoriteState) {
                if (addFavoriteState is AddFavoriteSuccess) {
                  setState(() {
                    isFavorite = true;
                  });
                } else if (addFavoriteState is AddFavoriteError) {
                  setState(() {
                    isFavorite = false;
                  });
                }
                // TODO: implement listener
              },
              builder: (context, addFavoriteState) {
                return BlocConsumer<DeleteFavoriteBloc, DeleteFavoriteState>(
                  listener: (context, deleteFavoriteState) {
                    // TODO: implement listener
                    if (deleteFavoriteState is DeleteFavoriteSuccess) {
                      setState(() {
                        isFavorite = false;
                      });
                    } else if (deleteFavoriteState is DeleteFavoriteError) {
                      setState(() {
                        isFavorite = true;
                      });
                    }
                  },
                  builder: (context, deleteFavoriteState) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Container(
                          width: MediaQuery.of(context).size.width - 16,
                          padding: EdgeInsets.all(16.0),
                          child: ListView(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  "$saveEarthBaseUrl${marker.imageUrl}",
                                  width: MediaQuery.of(context).size.width - 8,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    marker.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0xffD9D9D9),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  marker.description,
                                  softWrap: true,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
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

                              // ✅ ปุ่ม Favorite และปุ่มส่งคำขอ
                              Row(
                                children: [
                                  // ✅ ปุ่ม "ส่งคำขอ"
                                  Expanded(
                                    flex: 3, // 75% ของปุ่มส่งคำขอ
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showRequestDialog(context, marker);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade900,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: const Text(
                                        "ส่งคำขอ",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // ✅ ปุ่ม "เพิ่มในรายการโปรด"
                                  Expanded(
                                    flex: 1, // 25% ของปุ่มส่งคำขอ
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (isFavorite) {
                                          removeFavorite(marker.itemId);
                                        } else {
                                          addFavorite(marker.itemId);
                                        }
                                        setState(() {
                                          isFavorite = !isFavorite;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFavorite
                                            ? Colors.green.shade900
                                            : Colors.green.shade300,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
  void _showWarningTOUpdateProfileDialog(BuildContext context, String fagType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            height: 145,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "กรุณาอัพเดทข้อมูลส่วนตัวของคุณก่อนทำรายการ?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton(context, "ปิด", Colors.grey, () {
                      if(fagType == "create"){
                        Navigator.of(context).pop();
                      }else{
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }

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

  void _submitRequest(ItemModel marker, BuildContext context) async {
    final user = await LocalStorageHelper.getUser();
    if (user != null) {
      if(user.firstName != null) {
        Navigator.pop(context);
        context.read<CreateRequestBloc>().add(
          SubmitRequest(
            itemId: marker.itemId,
            userId: user.userId,
            reason: reasonController.text,
          ),
        );
      }else{
        reasonController.clear();
        _showWarningTOUpdateProfileDialog(context,"request");
      }
    }
  }

  int? itemIdCash;

  void _submitRequestOnFav(FavoriteModel requestListItem) async {
    final user = await LocalStorageHelper.getUser();
    if (user != null) {
      if(user.firstName != null) {
        setState(() {
          itemIdCash = requestListItem.item.itemId;
        });
        context.read<CreateRequestBloc>().add(
          SubmitRequest(
            itemId: requestListItem.item.itemId,
            userId: user.userId,
            reason: reasonController.text,
          ),
        );
        reasonController.clear();
        Navigator.pop(context);
        Navigator.pop(context);
      }else{
        reasonController.clear();
        _showWarningTOUpdateProfileDialog(context,"request");
      }
    }
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

  void showRequestDialogOnFav(
      BuildContext context, FavoriteModel requestListItem) {
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
                    _submitRequestOnFav(requestListItem);
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

  void showItemDetailsOnFav(FavoriteModel requestListItem) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width - 16,
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  "${saveEarthBaseUrl}${requestListItem.item.imageUrl}",
                  width: MediaQuery.of(context).size.width - 8,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    requestListItem.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xffD9D9D9),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  requestListItem.item.description,
                  softWrap: true,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "หมวดหมู่: ${requestListItem.item.category}",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              SizedBox(height: 10),
              Text("ลงประกาศเมื่อ: ${requestListItem.item.createdAt}"),
              SizedBox(height: 40),

              // ✅ ปุ่ม Favorite และปุ่มส่งคำขอ
              Row(
                children: [
                  // ✅ ปุ่ม "ส่งคำขอ"
                  Expanded(
                    flex: 1, // 75% ของปุ่มส่งคำขอ
                    child: ElevatedButton(
                      onPressed: () {
                        showRequestDialogOnFav(context, requestListItem);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "ส่งคำขอ",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
          return BlocConsumer<SearchDataBloc, SearchDataState>(
            listener: (context, searchDataState) {
              if (searchDataState is SearchItemListLoaded) {
                if (searchDataState.items.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _mapController.move(
                          LatLng(searchDataState.items[0].latitude,
                              searchDataState.items[0].longitude),
                          _currentZoom);
                    }
                  });
                }
              }
            },
            builder: (context, searchDataState) {
              if (searchDataState is SearchItemError) {
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
              } else if (searchDataState is SearchItemListLoaded) {
                return Scaffold(
                  body: tapIndex == 0
                      ? buildSearhScreen(context, searchDataState)
                      : tapIndex == 1
                          ? buildFAVScreen(context)
                          : tapIndex == 2
                              ? buildProfileScreen(context)
                              : SizedBox.shrink(),
                  bottomNavigationBar: BottomNavigationBar(
                    onTap: (i) {
                      log("Tap Index: ${i}");
                      if(i==1){
                        _fetchFavorites();
                      }
                      setState(() {
                        tapIndex = i;
                      });
                    },
                    currentIndex: tapIndex,
                    selectedItemColor: Color(0xff598E0A),
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
              } else {
                log("searchDataState : ${searchDataState is SearchItemListLoaded}");
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
              }
            },
          );
        } else {
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

  Stack buildSearhScreen(
      BuildContext context, SearchItemListLoaded searchDataState) {
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
              markers: searchDataState.items.map((marker) {
                return Marker(
                  point: LatLng(marker.latitude, marker.longitude),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      _fetchFavorites();
                      _showMarkerDetails(marker);
                    },
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
          child: Column(
            children: [
              Container(
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
              SizedBox(
                height: 8,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  return GestureDetector(
                    // onTap: () => _onCategorySelected(category),
                    onTap: () async {
                      Position position = await Geolocator.getCurrentPosition();
                      log("position : ${position.latitude.toString()}");
                      context.read<SearchDataBloc>().add(GetItemsByCategory(
                          category: category,
                          latitude: position.latitude.toString(),
                          longitude: position.longitude.toString()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
        BlocConsumer<CreateRequestBloc, CreateRequestState>(
          listener: (context, createRequestState) {
            if (createRequestState is CreateRequestSuccess) {
              reasonController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ส่งคำร้องขอของท่านเรียบร้อยแล้ว")),
              );
              Navigator.pop(context);
            } else if (createRequestState is CreateRequestError) {
              reasonController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ส่งคำร้องขอของท่าน ล้มเหลว")),
              );
            }
          },
          builder: (context, createRequestState) {
            if (createRequestState is CreateRequestLoading) {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black45,
                child: Center(
                  child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      )),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        )
      ],
    );
  }

  Widget buildFAVScreen(BuildContext context) {
    void removeFavorite(int itemId) async {
      final user = await LocalStorageHelper.getUser();
      if (user != null) {
        context
            .read<DeleteFavoriteBloc>()
            .add(DeleteFavoriteItem(userId: user.userId, itemId: itemId));
      }
    }

    return BlocConsumer<GetFavoritesBloc, GetFavoritesState>(
      listener: (context, getFavoritesState) {
        // TODO: implement listener
      },
      builder: (context, getFavoritesState) {
        if (getFavoritesState is GetFavoritesLoading) {
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
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          CircularProgressIndicator(
                            color: Colors.green,
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (getFavoritesState is GetFavoritesLoaded) {
          return Stack(
            children: [
              Container(
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
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Order List
                      Expanded(
                        child: ListView.builder(
                          itemCount: getFavoritesState.favorites.length,
                          itemBuilder: (context, index) {
                            final requestListItem =
                                getFavoritesState.favorites[index];
                            // final requestCount = order["requests"].length;
                            return Dismissible(
                              key: Key(requestListItem.item.name),
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
                                log("${requestListItem.item.name} ถูกลบ!");
                                removeFavorite(requestListItem.item.itemId);
                              },
                              child: Card(
                                elevation: 1,
                                color: requestListItem.item.status == "available" ? Colors.white : Colors.white30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  title: Text(requestListItem.item.name,
                                      style: TextStyle(fontSize: 16)),
                                  trailing:
                                      Icon(requestListItem.item.status == "available"?Icons.arrow_forward_ios:Icons.clear, size: 16),
                                  onTap: () {
                                    if(requestListItem.item.status == "available"){
                                      showItemDetailsOnFav(requestListItem);
                                    }

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
              ),
              BlocConsumer<DeleteFavoriteBloc, DeleteFavoriteState>(
                listener: (context, deleteFavoriteState) {
                  fetchFavorites() async {
                    final user = await LocalStorageHelper.getUser();
                    if (user != null) {
                      context
                          .read<GetFavoritesBloc>()
                          .add(FetchFavoritesByUserId(user.userId));
                    }
                  }

                  if (deleteFavoriteState is DeleteFavoriteSuccess) {
                    fetchFavorites();
                  }
                  // TODO: implement listener
                },
                builder: (context, deleteFavoriteState) {
                  if (deleteFavoriteState is DeleteFavoriteLoading) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black38,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              BlocConsumer<CreateRequestBloc, CreateRequestState>(
                listener: (context, createRequestState) {
                  if (createRequestState is CreateRequestSuccess) {
                    removeFavorite(itemIdCash!);
                  }
                  // TODO: implement listener
                },
                builder: (context, createRequestState) {
                  if (createRequestState is CreateRequestLoading) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black38,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              )
            ],
          );
        } else {
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
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 50,
                          ),
                          const Text("เกิดข้อผิดพลาด",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.green.shade900),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 40),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "ลองอีกครั้ง",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Order List
                ],
              ),
            ),
          );
        }
      },
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
                                  "${saveEarthBaseUrl}${user!.profileImageUrl}"),
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
                              Navigator.pushNamed(context, Routes.editProfile.toStringPath())
                                  .then((_) {
                                getUserData(); // ✅ อัปเดตข้อมูลเมื่อกลับจาก Edit Profile
                              });
                            },
                          ),
                          _buildMenuItem(
                            "รายการ สิ่งของ",
                            () {
                              Navigator.pushNamed(
                                  context, (Routes.myItemList).toStringPath());
                            },
                          ),
                          _buildMenuItem(
                            "สร้างสิ่งของของฉัน",
                            () async {
                              final user = await LocalStorageHelper.getUser();
                              if (user != null) {
                                if(user.firstName != null) {
                                  Navigator.pushNamed(context,
                                      (Routes.createMyItem).toStringPath());
                                }else{
                                  _showWarningTOUpdateProfileDialog(context,"create");
                                }
                              }

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
}
