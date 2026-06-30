import 'package:animalapp/UI/styled_text.dart';
import 'package:animalapp/models/Animal.dart';
import 'package:flutter/material.dart';
import 'dart:io';


class AnimalCard extends StatelessWidget {
  const AnimalCard({required this.animal, required this.onTap, super.key});
  final Animal animal;
  final VoidCallback onTap;
  
  //This is the card that's gonna appear on the list
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: animal.image.startsWith('assets/')
                  ? Image.asset(
                      animal.image,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(animal.image),
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StyledText(
                        animal.name,
                      ),
                      StyledText(animal.specie),
                    ],
                  ),
                  StyledText('${animal.breed} • ${animal.age} years old'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}