import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 12;
    double cutoutRadius = 10;
    double cutoutPosition = size.width * 0.3;

    path.moveTo(radius, 0);
    path.lineTo(cutoutPosition - cutoutRadius, 0);
    path.arcToPoint(Offset(cutoutPosition + cutoutRadius, 0), radius: Radius.circular(cutoutRadius), clockwise: false);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius));
    
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius));
    
    path.lineTo(cutoutPosition + cutoutRadius, size.height);
    path.arcToPoint(Offset(cutoutPosition - cutoutRadius, size.height), radius: Radius.circular(cutoutRadius), clockwise: false);
    
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius));
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
