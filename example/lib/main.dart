import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

void main() {
  runApp(const SmartPaginationExampleApp());
}

/// Healthcare Patient Model for Example 1 & 12
class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.department,
    required this.status,
    required this.doctor,
    required this.roomNumber,
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String department;
  final String status;
  final String doctor;
  final String roomNumber;
}

/// Product Model for Grid & Cursor Showcase
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
  });

  final String id;
  final String title;
  final String category;
  final double price;
  final double rating;
}

/// Main Showcase Application
class SmartPaginationExampleApp extends StatefulWidget {
  const SmartPaginationExampleApp({super.key});

  @override
  State<SmartPaginationExampleApp> createState() =>
      _SmartPaginationExampleAppState();
}

class _SmartPaginationExampleAppState extends State<SmartPaginationExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pagination Pro Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: ShowcaseHomeScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class ShowcaseHomeScreen extends StatefulWidget {
  const ShowcaseHomeScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<ShowcaseHomeScreen> createState() => _ShowcaseHomeScreenState();
}

class _ShowcaseHomeScreenState extends State<ShowcaseHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Smart Pagination Pro',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Light/Dark Theme',
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
                icon: Icon(Icons.local_hospital_outlined),
                text: 'Healthcare Patients'),
            Tab(
                icon: Icon(Icons.grid_view_outlined),
                text: 'Product Grid (Cursor)'),
            Tab(
                icon: Icon(Icons.table_chart_outlined),
                text: 'Pagination Bar (Offset)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PatientsListView(),
          ProductsGridView(),
          OrdersPaginationBarView(),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: HEALTHCARE PATIENTS SHOWCASE
// ==========================================
class PatientsListView extends StatefulWidget {
  const PatientsListView({super.key});

  @override
  State<PatientsListView> createState() => _PatientsListViewState();
}

class _PatientsListViewState extends State<PatientsListView> {
  late SmartPaginationController<Patient> _controller;
  final TextEditingController _searchController = TextEditingController();

  bool _showShimmer = true;
  bool _simulateError = false;
  String? _selectedDept;
  String? _selectedStatus;

  final List<Patient> _mockPatients = List.generate(
    120,
    (index) {
      final depts = [
        'Cardiology',
        'Orthopedics',
        'Neurology',
        'Pediatrics',
        'General'
      ];
      final statuses = ['Active', 'Discharged', 'Pending'];
      final doctors = [
        'Dr. Sarah Jenkins',
        'Dr. Ravi Patel',
        'Dr. Michael Chang',
        'Dr. Emily Wong'
      ];
      return Patient(
        id: 'P-${1000 + index}',
        name: '${[
          'Ravi Patel',
          'Amit Kumar',
          'Sarah Jenkins',
          'Elena Rostova',
          'Carlos Mendez',
          'John Doe',
          'Priya Sharma',
          'David Kim'
        ][index % 8]} #${index + 1}',
        age: 20 + (index % 50),
        gender: index % 2 == 0 ? 'Male' : 'Female',
        department: depts[index % depts.length],
        status: statuses[index % statuses.length],
        doctor: doctors[index % doctors.length],
        roomNumber: 'Room ${101 + (index % 30)}',
      );
    },
  );

  @override
  void initState() {
    super.initState();
    _controller = SmartPaginationController<Patient>(
      pageSize: 15,
      strategy: PaginationStrategy.page,
      fetch: _fetchPatients,
      autoFillViewport: true,
      deduplicateItems: true,
      itemKey: (patient) => patient.id,
    );
    _controller.loadInitial();
  }

  Future<SmartPageResult<Patient>> _fetchPatients(
      SmartPaginationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (_simulateError && request.page == 1) {
      throw Exception('Network Timeout: Unable to reach Hospital Server');
    }

    var list = List<Patient>.from(_mockPatients);

    if (request.search != null && request.search!.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(request.search!.toLowerCase()) ||
              p.id.toLowerCase().contains(request.search!.toLowerCase()))
          .toList();
    }

    if (request.filters.containsKey('department')) {
      list = list
          .where((p) => p.department == request.filters['department'])
          .toList();
    }

    if (request.filters.containsKey('status')) {
      list = list.where((p) => p.status == request.filters['status']).toList();
    }

    if (request.sort != null) {
      list.sort((a, b) {
        int comp = 0;
        if (request.sort!.field == 'age') {
          comp = a.age.compareTo(b.age);
        } else {
          comp = a.name.compareTo(b.name);
        }
        return request.sort!.descending ? -comp : comp;
      });
    }

    final start = (request.page - 1) * request.pageSize;
    if (start >= list.length) {
      return const SmartPageResult(items: [], hasMore: false);
    }

    final end = (start + request.pageSize).clamp(0, list.length);
    final pageItems = list.sublist(start, end);

    return SmartPageResult<Patient>(
      items: pageItems,
      totalItems: list.length,
      hasMore: end < list.length,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls Header
        Card(
          margin: const EdgeInsets.all(12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search patients by name or ID...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _controller.search(null);
                                    setState(() {});
                                  },
                                )
                              : null,
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onChanged: (val) {
                          _controller.search(val);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        hint: const Text('Department'),
                        value: _selectedDept,
                        items: [
                          'Cardiology',
                          'Orthopedics',
                          'Neurology',
                          'Pediatrics',
                          'General'
                        ]
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedDept = val);
                          _controller.setFilter('department', val);
                        },
                      ),
                      const SizedBox(width: 12.0),
                      DropdownButton<String>(
                        hint: const Text('Status'),
                        value: _selectedStatus,
                        items: ['Active', 'Discharged', 'Pending']
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedStatus = val);
                          _controller.setFilter('status', val);
                        },
                      ),
                      const SizedBox(width: 12.0),
                      TextButton.icon(
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Clear Filters'),
                        onPressed: () {
                          setState(() {
                            _selectedDept = null;
                            _selectedStatus = null;
                            _searchController.clear();
                          });
                          _controller.clearFilters();
                          _controller.search(null);
                        },
                      ),
                      const SizedBox(width: 12.0),
                      FilterChip(
                        label: const Text('Shimmer UI'),
                        selected: _showShimmer,
                        onSelected: (val) => setState(() => _showShimmer = val),
                      ),
                      const SizedBox(width: 8.0),
                      FilterChip(
                        label: const Text('Simulate Error'),
                        selected: _simulateError,
                        onSelected: (val) {
                          setState(() => _simulateError = val);
                          _controller.loadInitial();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // List View
        Expanded(
          child: SmartPaginatedList<Patient>(
            controller: _controller,
            showShimmer: _showShimmer,
            displayMode: PaginationDisplayMode.infiniteScroll,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            separatorBuilder: (context, index) => const Divider(height: 1.0),
            itemBuilder: (context, patient, index) {
              Color statusColor = Colors.green;
              if (patient.status == 'Pending') statusColor = Colors.orange;
              if (patient.status == 'Discharged') statusColor = Colors.grey;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(patient.name[0]),
                ),
                title: Text(
                  patient.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${patient.id} • ${patient.age} yrs (${patient.gender}) • ${patient.department}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        patient.status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      patient.roomNumber,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TAB 2: PRODUCT CATALOG GRID (CURSOR MODES)
// ==========================================
class ProductsGridView extends StatefulWidget {
  const ProductsGridView({super.key});

  @override
  State<ProductsGridView> createState() => _ProductsGridViewState();
}

class _ProductsGridViewState extends State<ProductsGridView> {
  late SmartPaginationController<Product> _controller;

  final List<Product> _mockProducts = List.generate(
    80,
    (index) => Product(
      id: 'prod_${index + 1}',
      title: 'Medical Supply #${index + 1}',
      category: ['Equipment', 'Pharmaceutical', 'Consumables'][index % 3],
      price: 15.0 + (index * 4.5),
      rating: 4.0 + ((index % 10) / 10),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = SmartPaginationController<Product>(
      pageSize: 12,
      strategy: PaginationStrategy.cursor,
      fetch: _fetchProductsCursor,
    );
    _controller.loadInitial();
  }

  Future<SmartPageResult<Product>> _fetchProductsCursor(
      SmartPaginationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    int startIndex = 0;
    if (request.cursor != null) {
      final cursorStr = request.cursor.toString();
      startIndex = int.tryParse(cursorStr.replaceFirst('cursor_', '')) ?? 0;
    }

    if (startIndex >= _mockProducts.length) {
      return const SmartPageResult(items: [], hasMore: false);
    }

    final endIndex =
        (startIndex + request.pageSize).clamp(0, _mockProducts.length);
    final items = _mockProducts.sublist(startIndex, endIndex);

    final nextCursorToken =
        endIndex < _mockProducts.length ? 'cursor_$endIndex' : null;

    return SmartPageResult<Product>(
      items: items,
      nextCursor: nextCursorToken,
      hasMore: nextCursorToken != null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartPaginatedGrid<Product>(
      controller: _controller,
      maxCrossAxisExtent: 220.0,
      mainAxisSpacing: 12.0,
      crossAxisSpacing: 12.0,
      childAspectRatio: 0.85,
      showShimmer: true,
      itemBuilder: (context, product, index) {
        return Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 48.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  product.category,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14.0, color: Colors.amber),
                        Text(
                          ' ${product.rating}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// TAB 3: ORDERS PAGINATION BAR (OFFSET STRATEGY)
// ==========================================
class OrdersPaginationBarView extends StatefulWidget {
  const OrdersPaginationBarView({super.key});

  @override
  State<OrdersPaginationBarView> createState() =>
      _OrdersPaginationBarViewState();
}

class _OrdersPaginationBarViewState extends State<OrdersPaginationBarView> {
  late SmartPaginationController<String> _controller;

  final List<String> _mockOrders = List.generate(
    145,
    (index) => 'Order #ORD-${10000 + index} • Pharmacy Prescription Delivery',
  );

  @override
  void initState() {
    super.initState();
    _controller = SmartPaginationController<String>(
      pageSize: 10,
      strategy: PaginationStrategy.offset,
      fetch: (request) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final start = request.offset.clamp(0, _mockOrders.length);
        final end = (start + request.pageSize).clamp(0, _mockOrders.length);
        return SmartPageResult<String>(
          items: _mockOrders.sublist(start, end),
          totalItems: _mockOrders.length,
        );
      },
    );
    _controller.loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartPaginatedList<String>(
      controller: _controller,
      displayMode: PaginationDisplayMode.pagination,
      itemBuilder: (context, orderTitle, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
            title: Text(orderTitle),
            subtitle: const Text('Status: Delivered'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
