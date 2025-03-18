import 'package:flutter/material.dart';

/// Panel that displays notifications in the admin interface
class NotificationsPanel extends StatelessWidget {
  final ScrollController scrollController;
  
  const NotificationsPanel({
    super.key,
    required this.scrollController,
  });
  
  @override
  Widget build(BuildContext context) {
    // Use ConstrainedBox to set a maximum height
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mark_email_read),
                      tooltip: 'Mark all as read',
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Notification settings',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Notification list - now inside Expanded with a parent that has a defined size constraint
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                NotificationItem(
                  title: 'Order ready for delivery',
                  message: 'Order #12345 is ready for delivery at Table 3',
                  time: '2 min',
                  icon: Icons.restaurant,
                  color: Colors.green,
                  isUnread: true,
                ),
                NotificationItem(
                  title: 'New order received',
                  message: 'A new order has been received for Table 5',
                  time: '15 min',
                  icon: Icons.receipt,
                  color: Colors.blue,
                  isUnread: true,
                ),
                NotificationItem(
                  title: 'Reservation confirmed',
                  message: 'Table 8 reserved for 8:00 PM',
                  time: '30 min',
                  icon: Icons.event_available,
                  color: Colors.orange,
                  isUnread: false,
                ),
                NotificationItem(
                  title: 'Product out of stock',
                  message: 'The "Caesar Salad" product is out of stock',
                  time: '1h',
                  icon: Icons.warning,
                  color: Colors.red,
                  isUnread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual notification item displayed in the notifications panel
class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isUnread;
  
  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isUnread = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(message),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
}