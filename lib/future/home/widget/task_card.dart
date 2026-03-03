import 'package:flutter/material.dart';

class CustomTaskCard extends StatelessWidget {
  final Color colors;
  final String heasderText;
  final String discription;
  const CustomTaskCard(
      {super.key,
      required this.colors,
      required this.heasderText,
      required this.discription});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: colors, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heasderText,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            discription,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
