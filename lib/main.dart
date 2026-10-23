
import 'package:flutter/material.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/edit_transaction_screen.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

const Color primaryColor = Color(0xFF4B55D4);
const Color darkColor = Color(0xFF192342);
const Color backgroundColor = Color(0xFFF6F7FC);

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// MÀN HÌNH CHÀO MỪNG
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 4),
            const WalletIllustration(),
            const SizedBox(height: 20),
            const Text(
              'Expense Manager',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF858DA8),
              ),
            ),
            const Spacer(flex: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseHomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// HÌNH MINH HỌA VÍ TIỀN
class WalletIllustration extends StatelessWidget {
  const WalletIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            left: 29,
            child: Container(
              width: 47,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF65D27C),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 23,
            child: Container(
              width: 48,
              height: 39,
              decoration: BoxDecoration(
                color: const Color(0xFF36C96B),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            top: 29,
            left: 10,
            child: Container(
              width: 88,
              height: 49,
              decoration: BoxDecoration(
                color: const Color(0xFF4D65E9),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          Positioned(
            top: 44,
            right: 10,
            child: Container(
              width: 36,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF3833B4),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MÀN HÌNH QUẢN LÝ CHI TIÊU
class ExpenseHomeScreen extends StatefulWidget {
  const ExpenseHomeScreen({super.key});

  @override
  State<ExpenseHomeScreen> createState() => _ExpenseHomeScreenState();
}

class _ExpenseHomeScreenState extends State<ExpenseHomeScreen> {
  int selectedTab = 0;
String _transactionSearch = '';
String _transactionFilter = 'Tất cả';
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();

    if (!mounted) return;

    setState(() {
      transactions
        ..clear()
        ..addAll(data.map((item) {
          final isExpense = item['isExpense'] == 1;
          final category = item['category'] as String;

          return {
            ...item,
            'amount': isExpense
                ? -(item['amount'] as num).toInt()
                : (item['amount'] as num).toInt(),
            'date': item['date'].toString().substring(0, 10),
            'icon': getCategoryIcon(category),
            'color': getCategoryColor(category),
          };
        }));
    });
  }




  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Di chuyển':
        return Icons.directions_bus;
      case 'Mua sắm':
        return Icons.shopping_bag;
      case 'Lương':
      case 'Tiền làm thêm':
        return Icons.account_balance_wallet;
      default:
        return Icons.receipt_long;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFFA726);
      case 'Di chuyển':
        return const Color(0xFF42A5F5);
      case 'Mua sắm':
        return const Color(0xFFAB70D6);
      case 'Lương':
      case 'Tiền làm thêm':
        return const Color(0xFF66BB6A);
      default:
        return primaryColor;
    }
  }

  final List<Map<String, dynamic>> transactions = [];


  int get totalIncome {
    return transactions.fold<int>(
      0,
          (sum, item) =>
      sum + ((item['amount'] as int) > 0 ? item['amount'] as int : 0),
    );
  }

  int get totalExpense {
    return transactions.fold<int>(
      0,
          (sum, item) =>
      sum + ((item['amount'] as int) < 0 ? -(item['amount'] as int) : 0),
    );
  }

  int get balance => totalIncome - totalExpense;

  String formatMoney(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-' : ''}${buffer.toString()} đ';
  }



  Future<void> showAddTransactionDialog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );

    if (result == true && mounted) {
      await loadTransactions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm giao dịch thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  Future<void> showEditTransaction(
      Map<String, dynamic> transaction,
      ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(
          transaction: transaction,
        ),
      ),
    );

    if (result == true && mounted) {
      await loadTransactions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật giao dịch thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Quản lí thu chi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bạn chưa có thông báo mới.'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: darkColor,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedTab,
        children: [
          buildHomeTab(),
          buildStatisticsTab(),
          buildTransactionsTab(),
          buildProfileTab(),

        ],
      ),

      floatingActionButton: selectedTab == 0 || selectedTab == 2
          ? FloatingActionButton(
        onPressed: showAddTransactionDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) => setState(() => selectedTab = index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }


  Widget buildMonthlyChart() {
    final now = DateTime.now();

    final monthlyTransactions = transactions.where((item) {
      final date = DateTime.tryParse(item['date'].toString());

      return date != null &&
          date.year == now.year &&
          date.month == now.month;
    }).toList();

    final income = monthlyTransactions.fold<int>(
      0,
          (sum, item) {
        final amount = item['amount'] as int;
        return sum + (amount > 0 ? amount : 0);
      },
    );

    final expense = monthlyTransactions.fold<int>(
      0,
          (sum, item) {
        final amount = item['amount'] as int;
        return sum + (amount < 0 ? -amount : 0);
      },
    );

    final maxAmount = income > expense
        ? income.toDouble()
        : expense.toDouble();

    final incomeHeight =
    maxAmount == 0 ? 0.0 : 110 * income / maxAmount;

    final expenseHeight =
    maxAmount == 0 ? 0.0 : 110 * expense / maxAmount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê thu - chi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Tháng ${now.month}/${now.year}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChartBar(
                label: 'Thu nhập',
                amount: income,
                height: incomeHeight,
                color: const Color(0xFF36B878),
              ),
              _buildChartBar(
                label: 'Chi tiêu',
                amount: expense,
                height: expenseHeight,
                color: const Color(0xFFE76565),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Color(0xFF36B878),
                size: 10,
              ),
              const SizedBox(width: 6),
              const Text('Thu nhập'),
              const Spacer(),
              Text(
                formatMoney(income),
                style: const TextStyle(
                  color: Color(0xFF269B61),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Color(0xFFE76565),
                size: 10,
              ),
              const SizedBox(width: 6),
              const Text('Chi tiêu'),
              const Spacer(),
              Text(
                formatMoney(expense),
                style: const TextStyle(
                  color: Color(0xFFE05252),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar({
    required String label,
    required int amount,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          formatMoney(amount),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 54,
          height: height < 4 ? 4 : height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // Thẻ tổng số dư
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4B55D4),
                Color(0xFF6974F5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng số dư',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                formatMoney(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Thu nhập',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(totalIncome),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.trending_down,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Chi tiêu',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(totalExpense),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),


        // Giao dịch gần đây
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedTab = 2;
                });
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text(
                'Chưa có giao dịch nào.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...transactions.take(5).map(buildTransactionCard),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget buildTransactionCard(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] as int;
    final color = transaction['color'] as Color;

    return InkWell(
        onTap: () => showEditTransaction(transaction),
        borderRadius: BorderRadius.circular(15),
        child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(transaction['icon'] as IconData, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  transaction['date'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${amount >= 0 ? '+' : '-'}${formatMoney(amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: amount >= 0
                  ? const Color(0xFF2EAA66)
                  : const Color(0xFFE05252),
            ),
          ),
        ],
      ),
        ),
    );
  }

  Widget buildStatisticsTab() {
    final Map<String, int> categoryExpenses = {};

    for (final item in transactions) {
      final amount = item['amount'] as int;

      if (amount < 0) {
        final category = item['category']?.toString() ?? 'Khác';

        categoryExpenses[category] =
            (categoryExpenses[category] ?? 0) + amount.abs();
      }
    }

    final totalCategoryExpense = categoryExpenses.values.fold<int>(
      0,
          (sum, amount) => sum + amount,
    );

    final chartColors = [
      const Color(0xFFFF6384),
      const Color(0xFF36A2EB),
      const Color(0xFFFFCE56),
      const Color(0xFF4BC0C0),
      const Color(0xFF9966FF),
      const Color(0xFFFF9F40),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Thống kê',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tổng quan tình hình tài chính của bạn',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 22),

        // Bộ chọn thời gian
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEEFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Text(
                    'Tổng quan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Biểu đồ tròn
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cơ cấu chi tiêu',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 24),

              if (totalCategoryExpense == 0)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      'Chưa có dữ liệu chi tiêu',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 230,
                  child: Center(
                    child: ExpenseDonutChart(
                      data: categoryExpenses,
                      total: totalCategoryExpense,
                      colors: chartColors,
                      formatMoney: formatMoney,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Chú thích danh mục
              ...categoryExpenses.entries.toList().asMap().entries.map(
                    (entry) {
                  final index = entry.key;
                  final category = entry.value.key;
                  final amount = entry.value.value;
                  final color = chartColors[index % chartColors.length];
                  final percent =
                  totalCategoryExpense == 0
                      ? 0.0
                      : amount / totalCategoryExpense * 100;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatMoney(amount),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),



        // Số dư
        buildSummaryCard(
          'Số dư hiện tại',
          formatMoney(balance),
          Icons.account_balance_wallet,
          primaryColor,
        ),

        const SizedBox(height: 20),
        // Tổng thu nhập
        buildSummaryCard(
          'Tổng thu nhập',
          formatMoney(totalIncome),
          Icons.trending_up,
          const Color(0xFF2EAA66),
        ),

        // Tổng chi tiêu
        buildSummaryCard(
          'Tổng chi tiêu',
          formatMoney(totalExpense),
          Icons.trending_down,
          const Color(0xFFE05252),
        ),
      ],
    );
  }


Widget buildSummaryCard(
String title,
String value,
IconData icon,
Color color,
) {
return Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
),
child: Row(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: color.withValues(alpha: 0.12),
borderRadius: BorderRadius.circular(12),
),
child: Icon(icon, color: color, size: 25),
),
const SizedBox(width: 14),
Expanded(
child: Text(
title,
style: const TextStyle(
fontSize: 14,
color: Colors.grey,
),
),
),
Text(
value,
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.bold,
color: color,
),
),
],
),
);
}




Widget buildTransactionsTab() {
final keyword = _transactionSearch.trim().toLowerCase();

final filteredTransactions = transactions.where((item) {
final title = (item['title'] ?? '').toString().toLowerCase();
final category =
(item['category'] ?? '').toString().toLowerCase();
final note = (item['note'] ?? '').toString().toLowerCase();

final matchesSearch = keyword.isEmpty ||
title.contains(keyword) ||
category.contains(keyword) ||
note.contains(keyword);

final amount = (item['amount'] as num?)?.toDouble() ?? 0;
final matchesType = _transactionFilter == 'Tất cả' ||
(_transactionFilter == 'Thu nhập' && amount > 0) ||
(_transactionFilter == 'Chi tiêu' && amount < 0);

return matchesSearch && matchesType;
}).toList()
..sort((a, b) =>
b['date'].toString().compareTo(a['date'].toString()));

return ListView(
padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
children: [
const Text(
'Giao dịch',
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
color: darkColor,
),
),
const SizedBox(height: 18),

// Ô tìm kiếm
TextField(
onChanged: (value) {
setState(() => _transactionSearch = value);
},
decoration: InputDecoration(
hintText: 'Tìm kiếm giao dịch...',
prefixIcon: const Icon(Icons.search),
suffixIcon: _transactionSearch.isNotEmpty
? IconButton(
icon: const Icon(Icons.close),
onPressed: () {
setState(() => _transactionSearch = '');
},
)
: IconButton(
icon: const Icon(Icons.filter_list),
onPressed: () {
showModalBottomSheet(
context: context,
builder: (sheetContext) {
return SafeArea(
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Lọc giao dịch',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
...['Tất cả', 'Thu nhập', 'Chi tiêu']
.map((filter) {
return RadioListTile<String>(
title: Text(filter),
value: filter,
groupValue: _transactionFilter,
onChanged: (value) {
if (value != null) {
setState(() {
_transactionFilter = value;
});
Navigator.pop(sheetContext);
}
},
);
}),
],
),
),
);
},
);
},
),
filled: true,
fillColor: const Color(0xFFF0F2FA),
contentPadding: const EdgeInsets.symmetric(vertical: 12),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),
const SizedBox(height: 14),

// Bộ lọc nhanh
Row(
children: ['Tất cả', 'Thu nhập', 'Chi tiêu'].map((filter) {
final selected = _transactionFilter == filter;

return Expanded(
child: Padding(
padding: const EdgeInsets.only(right: 7),
child: OutlinedButton(
onPressed: () {
setState(() => _transactionFilter = filter);
},
style: OutlinedButton.styleFrom(
backgroundColor:
selected ? primaryColor : Colors.white,
foregroundColor:
selected ? Colors.white : darkColor,
side: BorderSide(
color: selected
? primaryColor
: const Color(0xFFE2E5EF),
),
padding: const EdgeInsets.symmetric(vertical: 10),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
),
child: Text(
filter,
maxLines: 1,
style: const TextStyle(fontSize: 12),
),
),
),
);
}).toList(),
),
const SizedBox(height: 20),

if (filteredTransactions.isEmpty)
Padding(
padding: const EdgeInsets.symmetric(vertical: 45),
child: Column(
children: [
const Icon(
Icons.receipt_long_outlined,
size: 48,
color: Colors.grey,
),
const SizedBox(height: 12),
Text(
transactions.isEmpty
? 'Chưa có giao dịch nào.'
: 'Không tìm thấy giao dịch phù hợp.',
textAlign: TextAlign.center,
style: const TextStyle(color: Colors.grey),
),
],
),
)
else ...[
Text(
'${filteredTransactions.length} giao dịch',
style: const TextStyle(
fontSize: 13,
color: Colors.grey,
),
),
const SizedBox(height: 8),
...filteredTransactions.map((item) {
final amount = (item['amount'] as num).toInt();
final isIncome = amount > 0;
final category = (item['category'] ?? 'Khác').toString();
final date = (item['date'] ?? '').toString();
final displayDate = date.length >= 10
? '${date.substring(8, 10)}/'
'${date.substring(5, 7)}/'
'${date.substring(0, 4)}'
: date;

return Card(
elevation: 0,
color: Colors.white,
margin: const EdgeInsets.only(bottom: 10),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
child: ListTile(
contentPadding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 5,
),
leading: CircleAvatar(
backgroundColor: getCategoryColor(category)
.withValues(alpha: 0.15),
child: Icon(
getCategoryIcon(category),
color: getCategoryColor(category),
),
),
title: Text(
(item['title'] ?? category).toString(),
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: darkColor,
),
),
subtitle: Text(
displayDate,
style: const TextStyle(fontSize: 11),
),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'${isIncome ? '+' : '-'}'
'${formatMoney(amount.abs())}',
style: TextStyle(
color: isIncome
? const Color(0xFF2EAA66)
: const Color(0xFFE76565),
fontSize: 12,
fontWeight: FontWeight.bold,
),
),
const Icon(
Icons.chevron_right,
size: 18,
color: Colors.grey,
),
],
),
onTap: () => showEditTransaction(item),
),
);
}),
],
],
);
}
  Widget buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Cá nhân',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFEDEEFF),
            child: Icon(
              Icons.person,
              size: 45,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Người dùng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const ListTile(
          leading: Icon(Icons.account_circle_outlined),
          title: Text('Thông tin cá nhân'),
          subtitle: Text('Quản lý thông tin tài khoản'),
        ),
        const ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text('Cài đặt'),
          subtitle: Text('Tùy chỉnh ứng dụng'),
        ),
      ],
    );
  }
}

class ExpenseDonutChart extends StatelessWidget {
  final Map<String, int> data;
  final int total;
  final List<Color> colors;
  final String Function(int) formatMoney;

  const ExpenseDonutChart({
    super.key,
    required this.data,
    required this.total,
    required this.colors,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: DonutChartPainter(
              values: entries.map((e) => e.value.toDouble()).toList(),
              colors: colors,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tổng chi tiêu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                formatMoney(total),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DonutChartPainter({
    required this.values,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);

    if (total <= 0) return;

    const strokeWidth = 24.0;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -3.141592653589793 / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = values[i] / total * 2 * 3.141592653589793;

      paint.color = colors[i % colors.length];

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors;
  }
}