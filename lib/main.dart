import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAHjjpvC9DzW1E7A1lTff6_7bSyiLElZcM",
      authDomain: "uaslaundryflutter.firebaseapp.com",
      databaseURL: "https://fullstack-labs.firebaseio.com",
      projectId: "uaslaundryflutter",
      storageBucket: "uaslaundryflutter.firebasestorage.app",
      messagingSenderId: "1075213339021",
      appId: "1:1075213339021:web:e884ecbdb69d5f39afd5c4",
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginService()),
      ],
      child: const AplikasiLaundry(),
    ),
  );
}

class Utils {
  static const Color mainThemeColor = Color(0xFF00BFA6);
}

class AplikasiLaundry extends StatelessWidget {
  const AplikasiLaundry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Laundry',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LaundryLogin()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_laundry_service, size: 100, color: Utils.mainThemeColor),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class LaundryLogin extends StatefulWidget {
  const LaundryLogin({Key? key}) : super(key: key);

  @override
  State<LaundryLogin> createState() => _LaundryLoginState();
}

class _LaundryLoginState extends State<LaundryLogin> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    LoginService loginService = Provider.of<LoginService>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selamat Datang!',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Aplikasi Laundry',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Utils.mainThemeColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Utils.mainThemeColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  var username = usernameController.text;
                  var password = passwordController.text;

                  bool isLoggedIn = await loginService.signInWithEmailAndPassword(username, password);

                  if (isLoggedIn) {
                    usernameController.clear();
                    passwordController.clear();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MainWrapper()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login gagal. Periksa email dan password")),
                    );
                  }
                },
                child: Text('Login',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // TODO: Navigate to Register Page
              },
              child: Text('Belum punya akun? Daftar disini',
                style: GoogleFonts.poppins(color: Utils.mainThemeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginService extends ChangeNotifier {
  String _userId = '';

  String getUserId() {
    return _userId;
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      _userId = credentials.user!.uid;
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const NewOrderPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Utils.mainThemeColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Van Laundry'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoAkun(),
            const Divider(height: 30),
            _buildStatistikHarian(),
            const Divider(height: 30),
            _buildStatistikBulanan(context),
            const Divider(height: 30),
            _buildMenuTransaksi(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utils.mainThemeColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewOrderPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoAkun() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Akun User',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.store, color: Utils.mainThemeColor),
            const SizedBox(width: 10),
            Text(
              'Cabang Utama',
              style: GoogleFonts.poppins(),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Kas Hari ini',
                  style: GoogleFonts.poppins(),
                ),
                Text(
                  'Rp.100.000',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Utils.mainThemeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistikHarian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaksi Hari ini',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Utils.mainThemeColor, width: 3),
            ),
            child: Text(
              '5x',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Utils.mainThemeColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistikBulanan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik 4 Bulan Terakhir',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                _buildMenuStatistik(Icons.local_laundry_service, 'Produk'),
                const SizedBox(height: 15),
                _buildMenuStatistik(Icons.people, 'Pelanggan'),
              ],
            ),
            Column(
              children: [
                _buildMenuStatistik(Icons.money, 'Pengeluaran'),
                const SizedBox(height: 15),
                _buildMenuStatistik(Icons.person, 'Kasir'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuStatistik(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Utils.mainThemeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 30, color: Utils.mainThemeColor),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }

  Widget _buildMenuTransaksi(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaksi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Cari/Ambil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.mainThemeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchOrderPage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('Data Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderListPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Daftar Notifikasi'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Utils.mainThemeColor),
            title: Text('Profil Akun', style: GoogleFonts.poppins()),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.store, color: Utils.mainThemeColor),
            title: Text('Manajemen Cabang', style: GoogleFonts.poppins()),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.local_laundry_service, color: Utils.mainThemeColor),
            title: Text('Produk dan Layanan', style: GoogleFonts.poppins()),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Utils.mainThemeColor),
            title: Text('Pengaturan Aplikasi', style: GoogleFonts.poppins()),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.help, color: Utils.mainThemeColor),
            title: Text('Bantuan', style: GoogleFonts.poppins()),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Keluar', style: GoogleFonts.poppins(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({Key? key}) : super(key: key);

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedService = 'Cuci Reguler';
  final List<String> _services = [
    'Cuci Reguler',
    'Cuci Express',
    'Cuci Setrika',
    'Setrika Saja',
    'Dry Cleaning'
  ];

  String _selectedStatus = 'Diterima';
  final List<String> _statuses = ['Diterima', 'Proses', 'Selesai', 'Diambil'];

  final Map<String, double> _servicePrices = {
    'Cuci Reguler': 5000,
    'Cuci Express': 8000,
    'Cuci Setrika': 7000,
    'Setrika Saja': 4000,
    'Dry Cleaning': 15000,
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _pickupDateController.text = DateFormat('yyyy-MM-dd').format(now);
    _deliveryDateController.text =
        DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 2)));
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _pickupDateController.dispose();
    _deliveryDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    return weight * (_servicePrices[_selectedService] ?? 0);
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('orders').add({
          'customerName': _customerNameController.text,
          'phone': _phoneController.text,
          'serviceType': _selectedService,
          'weight': double.parse(_weightController.text),
          'pricePerKg': _servicePrices[_selectedService],
          'totalPrice': _calculateTotal(),
          'pickupDate': _pickupDateController.text,
          'deliveryDate': _deliveryDateController.text,
          'status': _selectedStatus,
          'notes': _notesController.text,
          'createdAt': Timestamp.now(),
          'userId': _auth.currentUser?.uid ?? '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${_customerNameController.text} berhasil dibuat'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Baru'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Informasi Pelanggan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap isi nama pelanggan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap isi nomor HP';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Detail Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedService,
                        items: _services.map((service) {
                          return DropdownMenuItem<String>(
                            value: service,
                            child: Text(service),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedService = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Jenis Layanan',
                          prefixIcon: Icon(Icons.local_laundry_service),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Berat (kg)',
                          prefixIcon: Icon(Icons.scale),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap isi berat laundry';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Harap isi angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pickupDateController,
                              decoration: const InputDecoration(
                                labelText: 'Tanggal Masuk',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, _pickupDateController),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _deliveryDateController,
                              decoration: const InputDecoration(
                                labelText: 'Tanggal Selesai',
                                prefixIcon: Icon(Icons.event_available),
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context, _deliveryDateController),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: _statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Status Pesanan',
                          prefixIcon: Icon(Icons.info),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Harga:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Rp ${_calculateTotal().toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Catatan Tambahan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN PESANAN',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchOrderPage extends StatelessWidget {
  const SearchOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari/Ambil Pesanan'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman Pencarian Pesanan'),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Riwayat Pesanan Anda'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Utils.mainThemeColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman Profil Pengguna'),
      ),
    );
  }
}

//OrderListPage
class OrderListPage extends StatefulWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  void _openOrderForm({String? docId, Map<String, dynamic>? existingData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: OrderForm(
            documentId: docId,
            existingData: existingData,
            onSaved: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  Future<void> _deleteOrder(String id) async {
    await orders.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orders.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan.'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Belum ada data pesanan.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data['customerName'] ?? 'Tanpa Nama'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layanan: ${data['serviceType']}'),
                      Text('Berat: ${data['weight']} kg'),
                      Text('Harga: Rp ${data['totalPrice']}'),
                      Text('Status: ${data['status']}'),
                      Text('Tanggal Masuk: ${data['pickupDate']}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _openOrderForm(docId: docId, existingData: data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _openOrderForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class OrderForm extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? existingData;
  final VoidCallback onSaved;

  const OrderForm({Key? key, this.documentId, this.existingData, required this.onSaved}) : super(key: key);

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _customerNameController;
  late TextEditingController _serviceTypeController;
  late TextEditingController _weightController;
  late TextEditingController _totalPriceController;
  late TextEditingController _statusController;
  late TextEditingController _pickupDateController;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.existingData?['customerName'] ?? '');
    _serviceTypeController = TextEditingController(text: widget.existingData?['serviceType'] ?? '');
    _weightController = TextEditingController(text: widget.existingData?['weight']?.toString() ?? '');
    _totalPriceController = TextEditingController(text: widget.existingData?['totalPrice']?.toString() ?? '');
    _statusController = TextEditingController(text: widget.existingData?['status'] ?? '');
    _pickupDateController = TextEditingController(text: widget.existingData?['pickupDate'] ?? '');
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _serviceTypeController.dispose();
    _weightController.dispose();
    _totalPriceController.dispose();
    _statusController.dispose();
    _pickupDateController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final orderData = {
      'customerName': _customerNameController.text,
      'serviceType': _serviceTypeController.text,
      'weight': double.tryParse(_weightController.text) ?? 0,
      'totalPrice': double.tryParse(_totalPriceController.text) ?? 0,
      'status': _statusController.text,
      'pickupDate': _pickupDateController.text,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final orders = FirebaseFirestore.instance.collection('orders');

    if (widget.documentId != null) {
      await orders.doc(widget.documentId).update(orderData);
    } else {
      await orders.add(orderData);
    }

    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.documentId != null;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(isEdit ? 'Edit Pesanan' : 'Pesanan Baru', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Nama Customer'),
              validator: (value) => value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
            ),
            TextFormField(
              controller: _serviceTypeController,
              decoration: const InputDecoration(labelText: 'Jenis Layanan'),
              validator: (value) => value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
            ),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Berat (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _totalPriceController,
              decoration: const InputDecoration(labelText: 'Harga Total'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            TextFormField(
              controller: _pickupDateController,
              decoration: const InputDecoration(labelText: 'Tanggal Masuk'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveOrder,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(isEdit ? 'Update' : 'Tambah'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}










