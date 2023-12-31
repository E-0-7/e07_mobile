import 'package:e07_mobile/donasi_buku/donasi_buku.dart';
import 'package:e07_mobile/drawer/left_drawer.dart';
import 'package:e07_mobile/katalog_buku/models/userstatus.dart';
import 'package:e07_mobile/katalog_buku/tambah_buku.dart';
import 'package:e07_mobile/pinjam_buku/screens/katalog_pinjam_buku.dart';
import 'package:e07_mobile/request_buku/screens/main_request_buku.dart';
import 'package:flutter/material.dart';
import 'package:e07_mobile/katalog_buku/models/buku.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:e07_mobile/authentication/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:e07_mobile/beli_buku/screens/beli_buku_katalog.dart';

class BookCatalog extends StatefulWidget {
  const BookCatalog({Key? key}) : super(key: key);

  @override
  State<BookCatalog> createState() => _BookCatalogState();
}

class _BookCatalogState extends State<BookCatalog> {
  late Future<List<Buku>> books;
  late CookieRequest request;

  @override
  void initState() {
    super.initState();
    // Don't access Provider in initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access Provider here
    request = Provider.of<CookieRequest>(context);
    books = fetchBooks(request);
  }

  Future<List<Buku>> fetchBooks(CookieRequest request) async {
    final response = await http.get(
      Uri.parse('https://flex-lib.domcloud.dev/json/'),
    );

    if (response.statusCode == 200) {
      return bukuFromJson(response.body);
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Buku'),
        backgroundColor: const Color(0xFF215082),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('asset/images/login_books.png'),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      backgroundColor: const Color(0xFF0B1F49),
      body: FutureBuilder(
        future: fetchBooks(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada data produk.",
                style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
              ),
            );
          } else {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Flex-Lib\nKatalog Buku\n\n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Di Flex-lib, kamu dapat meminjam buku, beli buku, request buku, dan donasi buku lama kamu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    color: const Color(0xFF163869),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Buku',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildUserSpecificButtons(),
                ),
                SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 4,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var book = snapshot.data![index];
                    return Card(
                      color: const Color(0xFF163869),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 2 / 3,
                              child: Image.network(
                                book.fields.urlFotoLarge ??
                                    "http://images.amazon.com/images/P/1879384493.01.LZZZZZZZ.jpg",
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              book.fields.bookTitle ?? "Tidak Ada Judul",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              book.fields.bookAuthor ?? "Tidak Ada Penulis",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              book.fields.tahunPublikasi.toString() == "" ||
                                      book.fields.tahunPublikasi
                                              .toString()
                                              .toLowerCase() ==
                                          "null"
                                  ? "-1"
                                  : book.fields.tahunPublikasi.toString(),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              book.fields.penerbit ?? "Tidak Ada Penerbit",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                  staggeredTileBuilder: (int index) =>
                      const StaggeredTile.fit(2),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildUserSpecificButtons() {
    final userStatus =
        Provider.of<UserStatusModel>(context, listen: false).userStatus;
    if (userStatus == 'guest') {
      return const SizedBox.shrink(); // No buttons for guests
    } else if (userStatus == 'loggedIn') {
      return _buildLoggedInButtons();
    } else if (userStatus == 'pustakawan') {
      return _buildLibrarianButtons();
    } else {
      return const SizedBox.shrink(); // Default case
    }
  }

  Widget _buildLoggedInButtons() {
    List<Widget> buttons = [
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainRequestBuku(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Request Buku')),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationPage(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Donasi Buku')),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KatalogPinjamBuku(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Pinjam Buku')),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BeliBukuKatalog(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Beli Buku')),
    ];

    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 20, // Jarak vertikal antara tombol
      crossAxisSpacing: 20,
      shrinkWrap: true,
      children: buttons,
    );
  }

  Widget _buildLibrarianButtons() {
    List<Widget> buttons = [
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainRequestBuku(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Request Buku')),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationPage(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Donasi Buku')),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KatalogPinjamBuku(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Pinjam Buku')),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BeliBukuKatalog(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Beli Buku')),
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormTambahBuku(),
                ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10), // Atur ukuran tombol sesuai keinginan Anda
            textStyle: const TextStyle(fontSize: 14), // Atur ukuran teks tombol
          ),
          child: const Text('Tambah Buku')),
    ];

    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 20, // Jarak vertikal antara tombol
      crossAxisSpacing: 20,
      shrinkWrap: true,
      children: buttons,
    );
  }
}
