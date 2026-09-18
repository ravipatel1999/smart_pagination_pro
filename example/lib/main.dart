import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_pagination_pro/smart_pagination_pro.dart';

void main() {
  runApp(const SmartPaginationExampleApp());
}

// ============================================================================
// GENERIC DOMAIN MODELS
// ============================================================================

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
}

class Order {
  const Order({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
  });

  final String id;
  final String customerName;
  final double amount;
  final String status;
  final String date;
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.readTime,
  });

  final String id;
  final String title;
  final String author;
  final String category;
  final String readTime;
}

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.position,
    required this.salary,
  });

  final int id;
  final String name;
  final String department;
  final String position;
  final double salary;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.cursor,
  });

  final String id;
  final String description;
  final double amount;
  final String cursor;
}

// ============================================================================
// MOCK API SERVICES
// ============================================================================

class MockApiService {
  static final List<User> _mockUsers = List.generate(
    125,
    (index) => User(
      id: index + 1,
      name: 'User #${index + 1}',
      email: 'user${index + 1}@example.com',
      role: index % 3 == 0
          ? 'Admin'
          : (index % 2 == 0 ? 'Developer' : 'Designer'),
      status: index % 4 == 0 ? 'Inactive' : 'Active',
    ),
  );

  static final List<Product> _mockProducts = List.generate(
    80,
    (index) => Product(
      id: 'PROD-${index + 100}',
      name: 'Product Item #${index + 1}',
      category: ['Electronics', 'Clothing', 'Books', 'Home'][index % 4],
      price: (index + 1) * 12.5,
      rating: 3.5 + (index % 15) / 10,
    ),
  );

  static final List<Article> _mockArticles = List.generate(
    60,
    (index) => Article(
      id: 'ART-${index + 1}',
      title: 'Exploring Flutter Pagination Best Practices #${index + 1}',
      author: 'Author ${index % 5 + 1}',
      category: ['Mobile', 'Architecture', 'Dart', 'UI/UX'][index % 4],
      readTime: '${3 + index % 7} min read',
    ),
  );

  static Future<SmartPageResult<User>> fetchUsers(
      SmartPaginationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    var filtered = _mockUsers;
    if (request.search != null && request.search!.isNotEmpty) {
      final query = request.search!.toLowerCase();
      filtered = filtered
          .where((u) =>
              u.name.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query))
          .toList();
    }

    if (request.filters.containsKey('role')) {
      final role = request.filters['role'];
      if (role != null && role != 'All') {
        filtered = filtered.where((u) => u.role == role).toList();
      }
    }

    final startIndex = (request.page - 1) * request.pageSize;
    if (startIndex >= filtered.length) {
      return SmartPageResult<User>(
        items: [],
        totalItems: filtered.length,
      );
    }

    final endIndex = (startIndex + request.pageSize).clamp(0, filtered.length);
    final pageItems = filtered.sublist(startIndex, endIndex);

    return SmartPageResult<User>(
      items: pageItems,
      totalItems: filtered.length,
    );
  }

  static Future<SmartPageResult<Product>> fetchProducts(
      SmartPaginationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    var list = List<Product>.from(_mockProducts);
    if (request.filters.containsKey('category')) {
      final cat = request.filters['category'];
      if (cat != null && cat != 'All') {
        list = list.where((p) => p.category == cat).toList();
      }
    }

    if (request.sort != null) {
      final sort = request.sort!;
      list.sort((a, b) {
        int comp = 0;
        if (sort.field == 'price') {
          comp = a.price.compareTo(b.price);
        } else if (sort.field == 'rating') {
          comp = a.rating.compareTo(b.rating);
        }
        return sort.ascending ? comp : -comp;
      });
    }

    final startIndex = (request.page - 1) * request.pageSize;
    if (startIndex >= list.length) {
      return SmartPageResult<Product>(items: [], totalItems: list.length);
    }
    final endIndex = (startIndex + request.pageSize).clamp(0, list.length);

    return SmartPageResult<Product>(
      items: list.sublist(startIndex, endIndex),
      totalItems: list.length,
    );
  }

  static Future<SmartPageResult<Article>> fetchArticles(
      SmartPaginationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final startIndex = (request.page - 1) * request.pageSize;
    if (startIndex >= _mockArticles.length) {
      return const SmartPageResult<Article>(items: [], totalItems: 60);
    }
    final endIndex =
        (startIndex + request.pageSize).clamp(0, _mockArticles.length);
    return SmartPageResult<Article>(
      items: _mockArticles.sublist(startIndex, endIndex),
      totalItems: _mockArticles.length,
    );
  }
}

// ============================================================================
// MAIN SHOWCASE APPLICATION
// ============================================================================

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

class _ShowcaseHomeScreenState extends State<ShowcaseHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pagination Pro Showcase'),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          SimplePaginationScreen(),
          ApiPaginationScreen(),
          SearchFilterScreen(),
          InfiniteScrollListScreen(),
          PaginatedGridScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.touch_app),
            label: 'Simple API',
          ),
          NavigationDestination(
            icon: Icon(Icons.api),
            label: 'API Controller',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search & Filter',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Infinite List',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Grid View',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. SIMPLE API PAGINATION SCREEN (LEVEL 1)
// ============================================================================

class SimplePaginationScreen extends StatefulWidget {
  const SimplePaginationScreen({super.key});

  @override
  State<SimplePaginationScreen> createState() => _SimplePaginationScreenState();
}

class _SimplePaginationScreenState extends State<SimplePaginationScreen> {
  int _currentPage = 1;
  int _pageSize = 10;
  final int _totalItems = 85;

  List<User> _getCurrentPageUsers() {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _totalItems) return [];
    final end = (start + _pageSize).clamp(0, _totalItems);
    return List.generate(
      end - start,
      (i) {
        final idx = start + i + 1;
        return User(
          id: idx,
          name: 'Simple User #$idx',
          email: 'simple$idx@example.com',
          role: idx % 2 == 0 ? 'Member' : 'VIP',
          status: 'Active',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _getCurrentPageUsers();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Level 1 — Simple API (SmartPagination)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'No controller or state management needed. Just pass your page state & callbacks.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${user.id}')),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Chip(label: Text(user.role)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SmartPagination(
            currentPage: _currentPage,
            pageSize: _pageSize,
            totalItems: _totalItems,
            showFirstLastButtons: true,
            onPageChanged: (page) => setState(() => _currentPage = page),
            onPageSizeChanged: (size) => setState(() => _pageSize = size),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. API CONTROLLER PAGINATION SCREEN (LEVEL 2)
// ============================================================================

class ApiPaginationScreen extends StatefulWidget {
  const ApiPaginationScreen({super.key});

  @override
  State<ApiPaginationScreen> createState() => _ApiPaginationScreenState();
}

class _ApiPaginationScreenState extends State<ApiPaginationScreen> {
  late final SmartPaginationController<User> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SmartPaginationController<User>(
      pageSize: 10,
      fetch: MockApiService.fetchUsers,
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
    return Column(
      children: [
        Expanded(
          child: SmartPaginatedList<User>(
            controller: _controller,
            displayMode: PaginationDisplayMode.pagination,
            showShimmer: true,
            itemBuilder: (context, user, index) {
              return ListTile(
                leading: CircleAvatar(child: Text('${user.id}')),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Chip(
                  label: Text(user.role),
                  backgroundColor: user.role == 'Admin'
                      ? Colors.amber.shade100
                      : Colors.blue.shade100,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 3. SEARCH & FILTER SCREEN
// ============================================================================

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late final SmartPaginationController<User> _controller;
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _controller = SmartPaginationController<User>(
      pageSize: 10,
      fetch: MockApiService.fetchUsers,
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search users (debounced)...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (val) => _controller.search(val),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Roles')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'Developer', child: Text('Developer')),
                  DropdownMenuItem(value: 'Designer', child: Text('Designer')),
                ],
                onChanged: (role) {
                  if (role != null) {
                    setState(() => _selectedRole = role);
                    _controller.setFilter('role', role);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SmartPaginatedList<User>(
            controller: _controller,
            displayMode: PaginationDisplayMode.pagination,
            showShimmer: true,
            itemBuilder: (context, user, index) {
              return ListTile(
                leading: CircleAvatar(child: Text('${user.id}')),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Text(user.role),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 4. INFINITE SCROLL LIST SCREEN
// ============================================================================

class InfiniteScrollListScreen extends StatefulWidget {
  const InfiniteScrollListScreen({super.key});

  @override
  State<InfiniteScrollListScreen> createState() =>
      _InfiniteScrollListScreenState();
}

class _InfiniteScrollListScreenState extends State<InfiniteScrollListScreen> {
  late final SmartPaginationController<Article> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SmartPaginationController<Article>(
      pageSize: 15,
      fetch: MockApiService.fetchArticles,
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
    return SmartPaginatedList<Article>(
      controller: _controller,
      displayMode: PaginationDisplayMode.infiniteScroll,
      showShimmer: true,
      itemBuilder: (context, article, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(article.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${article.author} • ${article.readTime}'),
            trailing: Chip(label: Text(article.category)),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 5. PAGINATED GRID SCREEN
// ============================================================================

class PaginatedGridScreen extends StatefulWidget {
  const PaginatedGridScreen({super.key});

  @override
  State<PaginatedGridScreen> createState() => _PaginatedGridScreenState();
}

class _PaginatedGridScreenState extends State<PaginatedGridScreen> {
  late final SmartPaginationController<Product> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SmartPaginationController<Product>(
      pageSize: 12,
      fetch: MockApiService.fetchProducts,
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
    return SmartPaginatedGrid<Product>(
      controller: _controller,
      displayMode: PaginationDisplayMode.pagination,
      maxCrossAxisExtent: 220,
      childAspectRatio: 0.85,
      showShimmer: true,
      itemBuilder: (context, product, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.shopping_bag_outlined, size: 32),
                  ),
                ),
                const Spacer(),
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${product.rating}'),
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
