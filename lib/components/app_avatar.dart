import 'package:flutter/material.dart';

import '../gen/assets.gen.dart';

class AppAvatar extends StatelessWidget {

  const AppAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
  width: 50,
  height: 50,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border:  Border.all(
  
    ),
    image:  DecorationImage(
      image: AssetImage( Assets.images.profilePicture.path),
      fit: BoxFit.cover,
    ),
  ),
)
;
  }
}