import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';
import '../providers/language_provider.dart';

// --- My Orders Screen ---
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('my_orders')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(context.tr('no_orders'), style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('start_shopping')),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Shipping Address Screen ---
class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  List<String> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _addresses = prefs.getStringList('shipping_addresses') ?? ['123 Main Street, New York, NY 10001'];
    });
  }

  Future<void> _addAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _addresses.add(address);
    });
    await prefs.setStringList('shipping_addresses', _addresses);
  }

  Future<void> _removeAddress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _addresses.removeAt(index);
    });
    await prefs.setStringList('shipping_addresses', _addresses);
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('add_address')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: context.tr('address_hint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr('cancel'))),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addAddress(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('shipping_address')),
        actions: [
          IconButton(onPressed: _showAddDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: _addresses.isEmpty
          ? const Center(child: Text('No addresses found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(child: Icon(Icons.home)),
                    title: Text(context.tr('shipping_address') + ' ${index + 1}'),
                    subtitle: Text(_addresses[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeAddress(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- Payment Methods Screen ---
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<String> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cards = prefs.getStringList('payment_cards') ?? ['**** **** **** 1234'];
    });
  }

  Future<void> _addCard(String card) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cards.add(card);
    });
    await prefs.setStringList('payment_cards', _cards);
  }

  Future<void> _removeCard(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cards.removeAt(index);
    });
    await prefs.setStringList('payment_cards', _cards);
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('add_card')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: context.tr('card_hint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr('cancel'))),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addCard(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('payment_methods')),
        actions: [
          IconButton(onPressed: _showAddDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: _cards.isEmpty
          ? const Center(child: Text('No payment methods added'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.credit_card, size: 40),
                    title: Text(_cards[index]),
                    subtitle: const Text('Exp: 12/26'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _removeCard(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- Notifications Screen ---
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool orderUpdates = true;
  bool promotions = false;
  bool newArrivals = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orderUpdates = prefs.getBool('notif_orders') ?? true;
      promotions = prefs.getBool('notif_promos') ?? false;
      newArrivals = prefs.getBool('notif_arrivals') ?? true;
    });
  }

  Future<void> _updateSetting(String key, bool value, Function(bool) updater) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() => updater(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('notifications'))),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(context.tr('order_updates')),
            subtitle: const Text('Get notified about your order status'),
            value: orderUpdates,
            onChanged: (val) => _updateSetting('notif_orders', val, (newVal) => orderUpdates = newVal),
          ),
          SwitchListTile(
            title: Text(context.tr('promotions')),
            subtitle: const Text('Receive special deals and discounts'),
            value: promotions,
            onChanged: (val) => _updateSetting('notif_promos', val, (newVal) => promotions = newVal),
          ),
          SwitchListTile(
            title: Text(context.tr('new_arrivals')),
            subtitle: const Text('Be the first to know about new products'),
            value: newArrivals,
            onChanged: (val) => _updateSetting('notif_arrivals', val, (newVal) => newArrivals = newVal),
          ),
        ],
      ),
    );
  }
}

// --- Privacy & Security Screen ---
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// --- Help & Support Screen ---
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// --- Language Screen ---
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('language'))),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: Text(context.tr('english')),
            value: 'en',
            groupValue: languageProvider.locale.languageCode,
            onChanged: (val) {
              if (val != null) {
                languageProvider.setLanguage(val);
              }
            },
          ),
          RadioListTile<String>(
            title: Text(context.tr('arabic')),
            value: 'ar',
            groupValue: languageProvider.locale.languageCode,
            onChanged: (val) {
              if (val != null) {
                languageProvider.setLanguage(val);
              }
            },
          ),
        ],
      ),
    );
  }
}
