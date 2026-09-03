import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item_model.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';
import '../widgets/system_window.dart';

class InventoryScreen extends StatelessWidget {
  final SystemState state;

  const InventoryScreen({super.key, required this.state});

  void _showBoxResultDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemColors.panelBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: SystemColors.cyanGlow, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          '[ SYSTEM: BOX OPENED ]',
          style: GoogleFonts.orbitron(
            color: SystemColors.cyanGlow,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, color: SystemColors.goldAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              result,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SystemColors.cyanGlow,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CLAIM REWARD',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(String icon) {
    switch (icon) {
      case 'gift':
        return Icons.card_giftcard;
      case 'potion':
        return Icons.science_outlined;
      case 'key':
        return Icons.vpn_key;
      case 'sword':
        return Icons.colorize;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final storeItems = InventoryItem.defaultItems();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hunter Vault Balance
          SystemWindow(
            title: 'Hunter Vault & Assets',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: SystemColors.goldAccent, size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SYSTEM GOLD',
                          style: GoogleFonts.orbitron(
                            color: SystemColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${profile.gold} G',
                          style: GoogleFonts.orbitron(
                            color: SystemColors.goldAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SystemColors.cyanGlow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SystemColors.cyanGlow, width: 0.8),
                  ),
                  child: Text(
                    '${state.items.length} ITEM SLOTS',
                    style: GoogleFonts.orbitron(
                      color: SystemColors.cyanGlow,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Inventory Grid / List
          SystemWindow(
            title: 'Inventory Rucksack',
            child: Column(
              children: state.items.map((item) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color(item.rarity.colorHex).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(item.rarity.colorHex).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Color(item.rarity.colorHex), width: 1),
                        ),
                        child: Icon(
                          _getItemIcon(item.icon),
                          color: Color(item.rarity.colorHex),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'x${item.quantity}',
                                  style: GoogleFonts.orbitron(
                                    color: SystemColors.goldAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: GoogleFonts.rajdhani(
                                color: SystemColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.id == 'blessed_box')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SystemColors.goldAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () {
                            final res = state.openBlessedBox();
                            _showBoxResultDialog(context, res);
                          },
                          child: Text(
                            'OPEN',
                            style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      else if (item.id == 'full_recovery')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SystemColors.hpGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () => state.useRecoveryPotion(),
                          child: Text(
                            'USE',
                            style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'EQUIPPED',
                            style: GoogleFonts.orbitron(fontSize: 8, color: Colors.white54),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // System Shop
          SystemWindow(
            title: 'System Supply Store',
            child: Column(
              children: storeItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(_getItemIcon(item.icon), color: Color(item.rarity.colorHex), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item.price} Gold',
                              style: GoogleFonts.rajdhani(
                                color: SystemColors.goldAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SystemColors.cyanGlow.withValues(alpha: 0.2),
                          foregroundColor: SystemColors.cyanGlow,
                          side: const BorderSide(color: SystemColors.cyanGlow, width: 0.8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        onPressed: () => state.buyItem(item),
                        child: Text(
                          'PURCHASE',
                          style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Hunter Titles Collection
          SystemWindow(
            title: 'Attained Hunter Titles',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.titles.map((title) {
                final isCurrent = title == profile.title;
                return InkWell(
                  onTap: () => state.updateHunterDetails(title: title),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? SystemColors.cyanGlow.withValues(alpha: 0.25)
                          : Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isCurrent ? SystemColors.cyanGlow : Colors.white24,
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(Icons.verified, color: SystemColors.cyanGlow, size: 14),
                          ),
                        Text(
                          title,
                          style: GoogleFonts.orbitron(
                            color: isCurrent ? SystemColors.cyanGlow : SystemColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
