import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/logic/Bloc/google_auth/google_auth_bloc.dart';
import 'package:save_earth/route/convert_route.dart';

class LoginAndRegisterPage extends StatefulWidget {
  const LoginAndRegisterPage({super.key});

  @override
  _LoginAndRegisterState createState() => _LoginAndRegisterState();
}

class _LoginAndRegisterState extends State<LoginAndRegisterPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/image/authbg.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ListView(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo
                  Image.asset(
                    "assets/image/applogo.png",
                    height: 210,
                  ),
                  Center(
                    child: Text(
                      "Save Earth",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login/Register Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLogin = true;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "เข้าสู่ระบบ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isLogin
                                          ? Colors.green.shade900
                                          : Colors.black54,
                                    ),
                                  ),
                                  if (isLogin)
                                    Container(
                                      height: 2,
                                      width: 60,
                                      color: Colors.green.shade900,
                                      margin: EdgeInsets.only(top: 4),
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLogin = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "ลงทะเบียน",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: !isLogin
                                          ? Colors.green.shade900
                                          : Colors.black54,
                                    ),
                                  ),
                                  if (!isLogin)
                                    Container(
                                      height: 2,
                                      width: 60,
                                      color: Colors.green.shade900,
                                      margin: EdgeInsets.only(top: 4),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        isLogin
                            ? Column(
                          children: [
                            const SizedBox(height: 16),

                            // Username Field
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "username",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Password Field
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "password",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        )
                            : Column(
                          children: [
                            const SizedBox(height: 16),

                            // Username Field
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "email",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "username",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Password Field
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "password",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Password Field
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "confirm password",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                        // Login Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, (Routes.mainApp).toStringPath());
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
                          child:  Text(
                            isLogin?"เข้าสู่ระบบ":"ลงทะเบียน",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Google Login Button
                        ElevatedButton(
                          onPressed: () {
                            context.read<GoogleAuthBloc>().add(GoogleSignInRequested());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.green.shade900),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 40,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/image/google_icon.png",
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "ดำเนินการด้วย google",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
