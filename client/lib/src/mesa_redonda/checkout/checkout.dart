import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Adjusted the scaffold to use SafeArea for better UX on devices with notches
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure checkout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use SingleChildScrollView only if content exceeds screen size
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Delivering to Jose Frometa'),
                        const SizedBox(height: 8.0),
                        _buildInfoRow(
                          '8260 NW 14TH ST APT X-42714, MIAMI, FL, 33191-1501, United States',
                          'Change',
                        ),
                        const SizedBox(height: 16.0),
                        _buildSectionTitle('Paying with Mastercard 8668'),
                        const SizedBox(height: 8.0),
                        _buildInfoRow(
                          'Use a gift card, voucher, or promo code',
                          'Change',
                        ),
                        const SizedBox(height: 16.0),
                        _buildSectionTitle(
                            'Arriving Sep 24, 2024 - Oct 15, 2024'),
                        const SizedBox(height: 8.0),
                        _buildInfoRow(
                          'Tuesday, Sep 24 - Tuesday, Oct 15\n   \$6.90 - Delivery',
                          '',
                        ),
                        const SizedBox(height: 16.0),
                        _buildCartItem(),
                        const SizedBox(height: 16.0),
                        Spacer(),
                        _buildOrderSummary(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    );
  }

  Widget _buildInfoRow(String info, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            info,
            style: const TextStyle(fontSize: 14.0),
          ),
        ),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: () {},
            child: Text(actionText),
          ),
      ],
    );
  }

  Widget _buildCartItem() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Use NetworkImage or AssetImage based on your needs
            Image.asset(
              'assets/food1.jpeg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2X White LED Daytime Running Lights DRL Fog Lamp For Suzuki Vitara',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Ships from 厚钧商贸\nSold by 厚钧商贸',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    '\$68.99',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Change'),
                      ),
                      const Text(
                        'Quantity: 1',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Card(
      color: Colors.yellow[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildOrderSummaryRow('Items (3)', '\$190.96'),
            _buildOrderSummaryRow('Shipping & handling', '\$6.90'),
            _buildOrderSummaryRow('Estimated tax to be collected', '\$13.37'),
            const Divider(),
            _buildOrderSummaryRow('Order total', '\$211.23', isBold: true),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final String phoneNumber = '+18493590832'; // WhatsApp number
                final String orderDetails = _generateOrderDetails();
                final String whatsappUrlMobile =
                    'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(orderDetails)}';
                final String whatsappUrlWeb =
                    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(orderDetails)}';

                if (await canLaunch(whatsappUrlMobile)) {
                  await launch(whatsappUrlMobile);
                } else {
                  // Fallback to WhatsApp Web
                  if (await canLaunch(whatsappUrlWeb)) {
                    await launch(whatsappUrlWeb);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open WhatsApp')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.yellow[700],
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Place your order',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  String _generateOrderDetails() {
    // Replace with actual data from your state or models
    final String items =
        '2X White LED Daytime Running Lights DRL Fog Lamp For Suzuki Vitara';
    final String total = '\$211.23';
    final String address =
        '8260 NW 14TH ST APT X-42714, MIAMI, FL, 33191-1501, United States';

    return 'Order Details:\nItems: $items\nTotal: $total\nDeliver to: $address';
  }
}
