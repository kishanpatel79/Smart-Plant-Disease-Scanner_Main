import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rental_data.dart';

class FarmingToolsRentalScreen extends StatefulWidget {
  const FarmingToolsRentalScreen({Key? key}) : super(key: key);

  @override
  State<FarmingToolsRentalScreen> createState() => _FarmingToolsRentalScreenState();
}

class _FarmingToolsRentalScreenState extends State<FarmingToolsRentalScreen> {
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    await RentalData.loadRentals();
  }

  void _showRentalDialog(BuildContext context, String toolName, String price) {
    _daysController.clear();
    _addressController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rent $toolName',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _daysController,
                decoration: InputDecoration(
                  labelText: 'Number of Days',
                  hintText: 'Enter number of days',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter your delivery address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_daysController.text.isEmpty || _addressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final days = int.tryParse(_daysController.text);
              if (days == null || days <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number of days'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                _isLoading = true;
              });

              // Extract daily rate from price string (e.g., "₹2000/day" -> 2000)
              final dailyRate = double.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));

              final rentalEntry = RentalEntry(
                toolName: toolName,
                days: days,
                deliveryAddress: _addressController.text,
                dailyRate: dailyRate,
                deliveryRequired: true,
              );

              await RentalData.addRental(rentalEntry);

              setState(() {
                _isLoading = false;
              });

              Navigator.pop(context); // Close the rental dialog

              // Show success dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Order Confirmed!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your order has been successfully placed!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Tool', toolName),
                      _buildInfoRow('Duration', '$days days'),
                      _buildInfoRow('Delivery Address', _addressController.text),
                      const SizedBox(height: 16),
                      const Text(
                        'Cost Breakdown:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(rentalEntry.costSummary),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm Rental',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.build,
                                size: 32,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Farming Equipment Rental',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rent high-quality farming tools and equipment',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildToolCard(
                        context,
                        'Tractor',
                        'Heavy-duty farming equipment for plowing and tilling',
                        'https://t4.ftcdn.net/jpg/02/95/83/47/240_F_295834744_u8NDU4pQFPIa3RwZ9nmwD3bHfmlJ0AHl.jpg',
                        '₹2000/day',
                        'Available',
                        Icons.agriculture,
                        Colors.blue,
                      ),
                      _buildToolCard(
                        context,
                        'Plough',
                        'Traditional soil preparation tool for small farms',
                        'https://cdn.pixabay.com/photo/2023/03/12/13/15/plough-7846832_1280.png',
                        '₹500/day',
                        'Available',
                        Icons.agriculture,
                        Colors.green,
                      ),
                      _buildToolCard(
                        context,
                        'Harvester',
                        'Modern combine harvester for efficient crop harvesting',
                        'https://images.pexels.com/photos/163752/harvest-grain-combine-arable-farming-163752.jpeg?auto=compress&cs=tinysrgb&w=600',
                        '₹3000/day',
                        'Available',
                        Icons.grass,
                        Colors.orange,
                      ),
                      _buildToolCard(
                        context,
                        'Sprayer',
                        'Pesticide and fertilizer application equipment',
                        'https://media.istockphoto.com/id/1251658155/photo/farmer-spraying-vegetables-in-the-garden-with-herbicides-pesticides-or-insecticides.jpg?s=612x612&w=0&k=20&c=PPz3L1eQ_FeZWgLiQUMnyk43bwZWWc9QYDwseuy1Oa4=',
                        '₹800/day',
                        'Available',
                        Icons.spa,
                        Colors.purple,
                      ),
                      _buildToolCard(
                        context,
                        'Cultivator',
                        'Soil cultivation and weed control equipment',
                        'https://cdn.pixabay.com/photo/2017/08/18/08/05/landtechnik-2654156_1280.jpg',
                        '₹900/day',
                        'Available',
                        Icons.agriculture,
                        Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String toolName,
    String description,
    String imageUrl,
    String price,
    String availability,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.red)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toolName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            description,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: availability == 'Available'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        availability,
                        style: TextStyle(
                          color: availability == 'Available'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showRentalDialog(context, toolName, price);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Rent Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
