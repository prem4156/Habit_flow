enum ItemRarity {
  common('E-Rank Common', 0xFF8A9BA8),
  rare('C-Rank Rare', 0xFF00E5FF),
  epic('A-Rank Epic', 0xFFA855F7),
  legendary('S-Rank Monarch', 0xFFFFD700);

  final String label;
  final int colorHex;
  const ItemRarity(this.label, this.colorHex);
}

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final ItemRarity rarity;
  final String icon;
  int quantity;
  final int price;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.icon,
    this.quantity = 1,
    this.price = 100,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'rarity': rarity.name,
    'icon': icon,
    'quantity': quantity,
    'price': price,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    rarity: ItemRarity.values.firstWhere(
      (r) => r.name == json['rarity'],
      orElse: () => ItemRarity.common,
    ),
    icon: json['icon'] ?? 'box',
    quantity: json['quantity'] ?? 1,
    price: json['price'] ?? 100,
  );

  static List<InventoryItem> defaultItems() => [
    InventoryItem(
      id: 'blessed_box',
      name: 'Blessed Random Box',
      description: 'A glowing gift from The System. Grants stat points, gold, or rare elixirs.',
      rarity: ItemRarity.rare,
      icon: 'gift',
      quantity: 2,
      price: 250,
    ),
    InventoryItem(
      id: 'full_recovery',
      name: 'Status Recovery Potion',
      description: 'Instantly resets Fatigue to 0% and restores full physical vitality.',
      rarity: ItemRarity.epic,
      icon: 'potion',
      quantity: 3,
      price: 150,
    ),
    InventoryItem(
      id: 'dungeon_key',
      name: 'Instant Dungeon Key (E-Rank)',
      description: 'Opens a hidden dimensional rift for solitary training.',
      rarity: ItemRarity.rare,
      icon: 'key',
      quantity: 1,
      price: 500,
    ),
    InventoryItem(
      id: 'kasaka_fang',
      name: "Kasaka's Venom Fang",
      description: 'Dagger carved from the Blue Venom-Fanged Kasaka. Radiates lethal power.',
      rarity: ItemRarity.legendary,
      icon: 'sword',
      quantity: 1,
      price: 2000,
    ),
  ];
}
