import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'disease_scanner_screen.dart';
import 'crop_rotation_screen.dart';

class FarmToolsScreen extends StatelessWidget {
  const FarmToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = theme.colorScheme.surface;

    Widget toolTile({
      required String title,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text('Farm Tools'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            toolTile(
              title: 'Disease Scanner',
              icon: Icons.image_search,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DiseaseScannerScreen()),
              ),
            ),
            toolTile(
              title: 'Crop Rotation',
              icon: Icons.timeline,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CropRotationScreen()),
              ),
            ),
            toolTile(
              title: 'Fertilizer Calculator',
              icon: Icons.science,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CalculatorScreen(mode: 'fertilizer'),
                ),
              ),
            ),
            toolTile(
              title: 'Seed Calculator',
              icon: Icons.grain,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CalculatorScreen(mode: 'seed'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
