import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../animations/fade_animation.dart';
import '../../components/glass_container.dart';
import '../../gen/assets.gen.dart';
import '../../providers/home_provider.dart';
import '../../providers/location_tracking_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute(
        builder: (_) => const Dashboard(), fullscreenDialog: true,);
  }
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final activeIconColor =
      const ColorFilter.mode(Colors.white, BlendMode.srcIn);
  late final iconColor =
      const ColorFilter.mode(Colors.white54, BlendMode.srcIn);

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final trackingProvider = context.watch<LocationTrackingProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.fastOutSlowIn,
              child: homeProvider.selectedScreen,
            ),
            floatingActionButtonAnimator:
                FloatingActionButtonAnimator.noAnimation,

            bottomNavigationBar: FadeAnimation(
              duration: 0.4,
              visible: !keyboardOpen,
              child: GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                borderRadius: BorderRadius.circular(30),
                padding: EdgeInsets.zero,
                child: BottomNavigationBar(
                  elevation: 0,
                  selectedFontSize: 0,
                  unselectedFontSize: 0,
                  backgroundColor: Colors.black,
                  fixedColor: Colors.white,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: homeProvider.currentIndex,
                  onTap: homeProvider.switchToIndex,
                  items: [
                    BottomNavigationBarItem(
                      icon: Assets.images.home.svg(colorFilter: iconColor),
                      activeIcon: GlowingIcon(
                        child: Assets.images.homeFilled
                            .svg(colorFilter: activeIconColor),
                      ),
                      label: 'Main',
                    ),
                    BottomNavigationBarItem(
                      icon: Assets.images.calendar.svg(colorFilter: iconColor),
                      activeIcon: GlowingIcon(
                        child: Assets.images.calendarFilled
                            .svg(colorFilter: activeIconColor),
                      ),
                      label: 'Second',
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.large(
              elevation: 0,
              shape: const CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 10,
                ),
              ),
              onPressed: () {
                    final trackingProvider = Provider.of<LocationTrackingProvider>(context, listen: false);


                if (trackingProvider.isTracking) {
                  trackingProvider.stopTracking();
                  return;
                }

                trackingProvider.startTracking();
              },
              backgroundColor: Colors.black,
              child: Icon(
                trackingProvider.isTracking ? Icons.stop : Icons.timer,
                color: trackingProvider.isTracking ? Colors.red : Colors.white,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }
}

class GlowingIcon extends StatelessWidget {
  final Widget child;

  const GlowingIcon({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
