import 'package:employee_app/config/app_config.dart';
import 'package:employee_app/providers/employee_provider.dart';
import 'package:employee_app/screens/employee_list_screen.dart';
import 'package:employee_app/widgets/decorative_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final provider = context.read<EmployeeProvider>();
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 2300)),
      provider.initialize(),
    ]);
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EmployeeListScreen(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  _Logo(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Zylu',
                    style: AppText.titleLg.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Employees',
                    style: AppText.titleMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Manage your team in one place',
                    style: AppText.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const Spacer(flex: 4),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icon/app_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.groups_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
