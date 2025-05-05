import 'package:flutter/material.dart';
import 'package:dwaya_app/models/pharmacy.dart';
import 'package:dwaya_app/widgets/pharmacy_list_item.dart';
import 'package:dwaya_app/utils/colors.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  // TODO: Replace with actual search results fetching based on widget.searchQuery
  final List<Pharmacy> _searchResults = [
    const Pharmacy(
      id: '1',
      name: 'Silo Pharmacy',
      address: '5/1 address, kuppal nagar',
      distance: '49.6 Km',
      isOpen: true,
      imageUrl: '',
    ),
    const Pharmacy(
      id: '4',
      name: 'Rmasia Pharmacy',
      address: '789 Pine Ln, Villagetown',
      distance: '1.5 Km',
      isOpen: true,
      imageUrl: '',
    ),
    // Add more dummy results or filter the list based on searchQuery
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Results for "${widget.searchQuery}"',
          style: const TextStyle(color: black, fontSize: 18),
        ),
        // Optional: Add filter/sort actions
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: black),
            onPressed: () {
              /* TODO: Implement filter action */
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          // TODO: Show a different message if _searchResults is empty
          return PharmacyListItem(pharmacy: _searchResults[index]);
        },
      ),
    );
  }
}
