import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/logic/Bloc/google_auth/google_auth_bloc.dart';
import 'package:save_earth/logic/Bloc/auth/auth_bloc.dart';
import 'package:save_earth/route/convert_route.dart';

class LoginAndRegisterPage extends StatefulWidget {
  const LoginAndRegisterPage({super.key});

  @override
  State<LoginAndRegisterPage> createState() => _LoginAndRegisterState();
}

class _LoginAndRegisterState extends State<LoginAndRegisterPage> {
  bool isLogin = true;
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  void _register() {
    final username = usernameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    context.read<AuthBloc>().add(RegisterUser(username, email, password));
  }

  void _login() {
    final username = usernameController.text;
    final password = passwordController.text;

    context.read<AuthBloc>().add(LoginUser(username, password));
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
  listener: (context, authState) {
    if (authState is AuthSuccess) {
      if(authState.message == "User registered successfully"){
        _login();
      }else if(authState.message == "Login successful" ||authState.message ==  "Google Login successful"){
        Navigator.pushReplacementNamed(context, Routes.mainApp.toStringPath());
      }

    } else if (authState is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error))
      );
    }
  },
  builder: (context, registerState) {
    return BlocConsumer<GoogleAuthBloc, GoogleAuthState>(
      listener: (context, googleAuthState) {
        if(googleAuthState is Authenticated){
          context.read<AuthBloc>().add(LoginWithGoogle(googleAuthState.user.uid, googleAuthState.user.email!));
        }else if(googleAuthState is AuthError){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(googleAuthState.error))
          );
        }
      },
      builder: (context, googleAuthState) {
        if (registerState is AuthLoading || googleAuthState is GoogleAuthLoading) {
          return Scaffold(
            body: Container(width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Color(0xff598E0A),
              child: Center(child: CircularProgressIndicator(color: Colors.white,)),),
          );
        }else {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset("assets/image/authbg.png", fit: BoxFit.cover),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ListView(
                      children: [
                        Image.asset("assets/image/applogo.png", height: 210),
                        const Center(
                          child: Text(
                            "Save Earth",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAuthBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  },
);
  }

  Widget _buildAuthBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildToggleButtons(),
            const SizedBox(height: 16),
            if (isLogin) _buildLoginForm() else _buildRegisterForm(),
            const SizedBox(height: 16),
            _buildLoginButton(),
            const SizedBox(height: 16),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildToggleButton("เข้าสู่ระบบ", true),
        _buildToggleButton("ลงทะเบียน", false),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = isSelected),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLogin == isSelected ? Colors.green.shade900 : Colors.black54,
            ),
          ),
          if (isLogin == isSelected)
            Container(
              height: 2,
              width: 60,
              color: Colors.green.shade900,
              margin: const EdgeInsets.only(top: 4),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField("username", controller: usernameController),
        const SizedBox(height: 12),
        _buildTextField("password", controller: passwordController, isPassword: true),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildTextField("email", controller: emailController, isEmail: true),
        const SizedBox(height: 12),
        _buildTextField("username", controller: usernameController),
        const SizedBox(height: 12),
        _buildTextField("password", controller: passwordController, isPassword: true),
        const SizedBox(height: 12),
        _buildTextField("confirm password", controller: confirmPasswordController, isPassword: true, isConfirmPassword: true),
      ],
    );
  }

  Widget _buildTextField(String hintText, {bool isPassword = false, bool isConfirmPassword = false, bool isEmail = false, required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "กรุณากรอก $hintText";
        }
        if (isEmail && !_isValidEmail(value)) {
          return "รูปแบบอีเมลไม่ถูกต้อง";
        }
        if (isPassword && value.length < 6) {
          return "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
        }
        if (isConfirmPassword && value != passwordController.text) {
          return "รหัสผ่านไม่ตรงกัน";
        }
        return null;
      },
    );
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if(isLogin){
            _login();
          }else{
            _register();
          }

          // Navigator.pushNamed(context, Routes.mainApp.toStringPath());
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
      ),
      child: Text(
        isLogin ? "เข้าสู่ระบบ" : "ลงทะเบียน",
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return ElevatedButton(
      onPressed: () {
        context.read<GoogleAuthBloc>().add(GoogleSignInRequested());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green.shade900),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/image/google_icon.png", height: 24),
          const SizedBox(width: 8),
          const Text(
            "ดำเนินการด้วย google",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
