import 'package:flutter/material.dart'
    show
        StatelessWidget,
        Widget,
        Image,
        BuildContext,
        MediaQuery,
        BoxFit,
        AssetImage;

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.cover,
      image: const AssetImage('assets/images/background.png'),
    );
  }
}
