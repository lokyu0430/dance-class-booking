import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isEnglish = false;

  void toggleLanguage() {
    setState(() => isEnglish = !isEnglish);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: isEnglish ? 'Dance Class Booking System' : '課堂預約系統',
      debugShowCheckedModeBanner: false,
      home: MainScreen(isEnglish: isEnglish, toggleLanguage: toggleLanguage),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isEnglish;
  final VoidCallback toggleLanguage;
  const MainScreen({super.key, required this.isEnglish, required this.toggleLanguage});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Map<String, String>> myBookings = [];
  DateTime selectedDate = DateTime(2026, 4, 1);

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookings') ?? [];
    setState(() {
      myBookings = saved.map((e) {
        final parts = e.split('|');
        return {'class': parts[0], 'time': parts[1], 'tutor': parts[2]};
      }).toList();
    });
  }

  Future<void> _saveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final list = myBookings.map((b) => '${b['class']}|${b['time']}|${b['tutor']}').toList();
    await prefs.setStringList('bookings', list);
  }

  void bookClass(String className, String time, String tutor) {
    setState(() {
      myBookings.add({'class': className, 'time': time, 'tutor': tutor});
    });
    _saveBookings();
  }

  void cancelBooking(int index) {
    setState(() => myBookings.removeAt(index));
    _saveBookings();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePage(isEnglish: widget.isEnglish),
      ClassesPage(
        isEnglish: widget.isEnglish,
        selectedDate: selectedDate,
        onDateChanged: (newDate) => setState(() => selectedDate = newDate),
        onBook: bookClass,
      ),
      MyBookingsPage(
        isEnglish: widget.isEnglish,
        bookings: myBookings,
        onCancel: cancelBooking,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEnglish ? 'Dance Class Booking System' : '課堂預約系統'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: widget.toggleLanguage,
            child: Text(widget.isEnglish ? '中文' : 'English',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.deepPurple,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: widget.isEnglish ? 'Home' : '首頁'),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: widget.isEnglish ? 'Classes' : '課堂'),
          BottomNavigationBarItem(icon: const Icon(Icons.bookmark), label: widget.isEnglish ? 'My Bookings' : '我的預約'),
        ],
      ),
    );
  }
}

// ==================== 首頁 ====================
class HomePage extends StatelessWidget {
  final bool isEnglish;
  const HomePage({super.key, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 120, color: Colors.deepPurple),
            const SizedBox(height: 30),
            Text(
              isEnglish ? 'Welcome to Dance Class Booking System!' : '歡迎使用課堂預約系統！',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              isEnglish ? 'Book your favorite dance classes easily' : '輕鬆預約你鍾意的舞蹈課堂',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 課堂頁面 ====================
class ClassesPage extends StatelessWidget {
  final bool isEnglish;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final Function(String, String, String) onBook;

  const ClassesPage({
    super.key,
    required this.isEnglish,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onBook,
  });

  // 每個星期幾 對應 不同老師 & 課程
  Map<int, List<Map<String, String>>> get weeklySchedule {
    return {
      1: [ // Mon
        {'style': 'Jazz Funk', 'tutor': 'Sumyi'},
        {'style': 'Heels', 'tutor': 'Jay'},
        {'style': 'Choreography', 'tutor': 'Cat'},
      ],
      2: [ // Tue
        {'style': 'Hip Hop', 'tutor': 'Haylie'},
        {'style': 'Jazz Funk', 'tutor': 'Sumyi'},
        {'style': 'Girls Hip Hop', 'tutor': 'Eunis'},
      ],
      3: [ // Wed
        {'style': 'Heels', 'tutor': 'Jay'},
        {'style': 'Choreography', 'tutor': 'Cat'},
        {'style': 'Hip Hop', 'tutor': 'Haylie'},
      ],
      4: [ // Thu
        {'style': 'Jazz Funk', 'tutor': 'Sumyi'},
        {'style': 'Girls Hip Hop', 'tutor': 'Eunis'},
        {'style': 'Heels', 'tutor': 'Jay'},
      ],
      5: [ // Fri
        {'style': 'Choreography', 'tutor': 'Cat'},
        {'style': 'Hip Hop', 'tutor': 'Haylie'},
        {'style': 'Jazz Funk', 'tutor': 'Sumyi'},
      ],
      6: [ // Sat
        {'style': 'Girls Hip Hop', 'tutor': 'Eunis'},
        {'style': 'Choreography', 'tutor': 'Cat'},
        {'style': 'Heels', 'tutor': 'Jay'},
      ],
      7: [ // Sun
        {'style': 'Hip Hop', 'tutor': 'Haylie'},
        {'style': 'Girls Hip Hop', 'tutor': 'Eunis'},
        {'style': 'Choreography', 'tutor': 'Cat'},
      ],
    };
  }

  final List<String> timeSlots = const [
    '18:00 - 19:30',
    '19:30 - 21:00',
    '21:00 - 22:30',
  ];

  @override
  Widget build(BuildContext context) {
    int weekday = selectedDate.weekday; // 1=Mon, 7=Sun
    final classesToday = weeklySchedule[weekday] ?? [];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.deepPurple.shade50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(30, (index) {
                final date = DateTime(2026, 4, 1).add(Duration(days: index));
                final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;

                return GestureDetector(
                  onTap: () => onDateChanged(date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MM/dd').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: classesToday.length,
            itemBuilder: (context, slotIndex) {
              final time = timeSlots[slotIndex];
              final className = '${classesToday[slotIndex]['style']} by ${classesToday[slotIndex]['tutor']}';
              final tutor = classesToday[slotIndex]['tutor']!;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note, size: 40, color: Colors.deepPurple),
                  ),
                  title: Text(
                    className,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(time, style: const TextStyle(fontSize: 17)),
                      Text(isEnglish ? '1.5 hours' : '1.5 小時'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    // 按鈕文字變白色 → 看得清楚
                    child: Text(
                      isEnglish ? 'Book' : '預約',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () {
                      onBook(className, time, tutor);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEnglish ? 'Booked successfully! 🎉' : '預約成功！🎉'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== 我的預約 ====================
class MyBookingsPage extends StatelessWidget {
  final bool isEnglish;
  final List<Map<String, String>> bookings;
  final Function(int) onCancel;

  const MyBookingsPage({
    super.key,
    required this.isEnglish,
    required this.bookings,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          isEnglish ? 'No classes booked yet.\nGo to Classes to book!' : '仲未有預約課堂。\n去課堂頁面預約啦！',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return Card(
          child: ListTile(
            title: Text(b['class']!),
            subtitle: Text('${b['time']!} • ${b['tutor']!}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onCancel(index),
            ),
          ),
        );
      },
    );
  }
}