import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:read_buddy_app/features/banner/presentation/pages/add_banner.dart';
import 'package:read_buddy_app/features/banner/presentation/widgets/banner_collection.dart';

class BannersList extends StatefulWidget {
  const BannersList({super.key});

  @override
  State<BannersList> createState() => _BannersListState();
}

class _BannersListState extends State<BannersList> {
  @override
  void initState() {
    context.read<BannerBloc>().add(const GetBannerListEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Banners'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Expanded(child: BlocBuilder<BannerBloc, BannerState>(
              builder: (context, state) {
                switch (state) {
                  case BannerLoading():
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case BannerLoaded(:final banners):
                    return ListView.builder(
                        //physics: const NeverScrollableScrollPhysics(),
                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          final banner = banners[index];

                          return BannerCollection(banner: banner);
                        });
                  case BannerError(:final message):
                    return Center(
                      child: Text(message),
                    );

                  default:
                    return const SizedBox.shrink();
                }
              },
            )),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 96, 177, 228),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tooltip: 'Add Banner',
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddBanner()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Banner',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
