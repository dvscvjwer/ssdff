import 'package:flutter/material.dart';

import '../models/title.dart';
import '../widgets/title_card.dart';

class CollectionScreen extends StatelessWidget {
  final String title;
  final List<TitleItem> items;
  const CollectionScreen({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => TitleCard(
          title: items[i],
          width: 120,
          showTitle: true,
        ),
      ),
    );
  }
}
