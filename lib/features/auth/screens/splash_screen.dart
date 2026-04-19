import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ct484tx_project_trangdc24v7x324/routes/app_routes.dart';
import 'package:ct484tx_project_trangdc24v7x324/core/pocketbase_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds:7), () async {
      if (!mounted) return;

      final isLoggedIn = pb.authStore.isValid;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xffFF939B),
                  Color(0xffEF2A39),
                  Color(0xFFEF2A39),
                ],
                stops: [0.0, 0.67, 1.0],
              ),
            ),
            child: Stack(
              children: [
                /// Tên app và slogan nằm giữa
                Positioned(
                  top: screenHeight * 0.32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'YourFood',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lobster(
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          'Ăn uống theo cách của bạn',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.042,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Góc trái bên dưới chứa hình minh họa
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: screenHeight * 0.28,
                    child: Stack(
                      children: [
                        Positioned(
                          left: -screenWidth * 0.04,
                          bottom: 0,
                          child: Image.asset(
                            'images/splashScreen/image2.png',
                            width: screenWidth * 0.48,
                            fit: BoxFit.contain,
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.18,
                          bottom: screenHeight * 0.01,
                          child: Image.asset(
                            'images/splashScreen/image1.png',
                            width: screenWidth * 0.42,
                            fit: BoxFit.contain,
                          ),
                        ),

                        /// Hotline bên phải
                        Positioned(
                          right: screenWidth * 0.05,
                          bottom: screenHeight * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Hotline 1900 1010',
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  right: -screenWidth * 0.1,
                  bottom: screenHeight * 0.15,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
