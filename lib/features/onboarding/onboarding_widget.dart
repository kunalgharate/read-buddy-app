import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingWidget extends StatelessWidget {
  final String image, title, description;

  const OnboardingWidget({
    required this.image,
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final imageHeight = isLandscape ? 120.0 : 250.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image.endsWith('.svg')
              ? SvgPicture.asset(image, height: imageHeight)
              : Image.asset(image, height: imageHeight),
          SizedBox(height: isLandscape ? 20 : 40),
          Text(
            title,
            style: TextStyle(
              fontSize: isLandscape ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: isLandscape ? 14 : 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
