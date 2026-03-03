import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_app/core/constants/constants.dart';
import 'package:offline_app/future/auth/cubic/auth_cubit.dart';
import 'package:offline_app/future/home/pages/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  bool isLogin = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginEmailController = TextEditingController();
  final registerkey = GlobalKey<FormState>();
  final loginKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is AuthSignUp) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("You are Register Successfully")));
          } else if (state is AuthLoggedIn) {
            Navigator.pushAndRemoveUntil(
                context, Homepage.route(), (route) => false);
          }
        },
        builder: (context, state) {
          // if (state is AuthloadingState) {
          //   return Center(
          //       child: CircularProgressIndicator(
          //     strokeWidth: 2,
          //     color: AppColor.primaryColor,
          //   ));
          // }
          return Stack(
            children: [
              Image.asset(Assets.APP_LOGO),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColor.primaryColor.withOpacity(0.4),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.2, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: isLogin ? _loginForm() : _registerForm(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: registerkey,
      child: Column(
        key: const ValueKey("register"),
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            decoration: _inputDecoration("Name"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Name can't be Empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: emailController,
            decoration: _inputDecoration("Email"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email can't be Empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: _inputDecoration("Password"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password can't be Empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _actionButton("Register", () {
            if (registerkey.currentState!.validate()) {
              context.read<AuthCubit>().signUp(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim());
            }
          }),
          const SizedBox(height: 15),
          _switchText(
            text: "Already have an account?",
            actionText: "Sign In",
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Form(
      key: loginKey,
      child: Column(
        key: const ValueKey("login"),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Login",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: loginEmailController,
            decoration: _inputDecoration("Email"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email can't be Empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: loginPasswordController,
            obscureText: true,
            decoration: _inputDecoration("Password"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password can't be Empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _actionButton("Login", () {
            if (loginKey.currentState!.validate()) {
              context.read<AuthCubit>().login(
                  email: loginEmailController.text.trim(),
                  password: loginPasswordController.text.trim());
            }
          }),
          const SizedBox(height: 15),
          _switchText(
            text: "Don’t have an account?",
            actionText: "Register",
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthloadingState;
          return ElevatedButton(
            onPressed: onap,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.purple,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
          );
        },
      ),
    );
  }

  Widget _switchText({
    required String text,
    required String actionText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            actionText,
            style: TextStyle(
              color: AppColor.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
