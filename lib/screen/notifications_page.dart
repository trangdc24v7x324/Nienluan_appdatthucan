import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Đơn hàng đã xác nhận',
        'subtitle': 'Đơn #12345 của bạn đã được xác nhận',
        'time': '2 phút trước',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Đang giao hàng',
        'subtitle': 'Shipper đang trên đường đến bạn',
        'time': '10 phút trước',
        'icon': Icons.delivery_dining,
        'color': Colors.orange,
      },
      {
        'title': 'Ưu đãi đặc biệt 🎉',
        'subtitle': 'Giảm 30% cho đơn hàng hôm nay',
        'time': '1 giờ trước',
        'icon': Icons.local_offer,
        'color': Colors.red,
      },
      {
        'title': 'Thanh toán thành công',
        'subtitle': 'Bạn đã thanh toán thành công 120.000đ',
        'time': 'Hôm qua',
        'icon': Icons.payment,
        'color': Colors.blue,
      },
      {
        'title': 'Đánh giá món ăn',
        'subtitle': 'Hãy đánh giá trải nghiệm của bạn ⭐',
        'time': '2 ngày trước',
        'icon': Icons.star,
        'color': Colors.amber,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: const Color(0xFFEF2A39),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // ICON
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 26),
                ),

                const SizedBox(width: 12),

                // TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // TIME
                Text(
                  item['time'],
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
