import 'package:flutter/material.dart';


class InwardBorderExample extends StatelessWidget {
  const InwardBorderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: Stack(
          children: [
            // Main container
            Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Bottom-left inward curve
            Positioned(
              bottom: -20, // Push outside to cut into main container
              left: -20,
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: Colors.grey, // background color
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),

            // Bottom-right inward curve
            Positioned(
              bottom: -20,
              right: -20,
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: Colors.grey, // background color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}