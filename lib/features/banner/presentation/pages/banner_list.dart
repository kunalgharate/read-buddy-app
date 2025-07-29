import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:read_buddy_app/features/banner/presentation/pages/Add_banner.dart';
import 'package:read_buddy_app/features/banner/presentation/widgets/banner_collection.dart';

class BannersList extends StatefulWidget {
  const BannersList({super.key});

  @override
  State<BannersList> createState() => _BannersListState();
}

class _BannersListState extends State<BannersList> {
  @override
  void initState() {
    context.read<BannerBloc>().add(GetBannerListEvent());
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
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: const Color.fromARGB(255, 96, 177, 228),
        shape: CircleBorder(),
        tooltip: 'Add Banner',
        onPressed: () {
          // Your action
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddBanner()));
        },
        child: const Center(
          child: Text(
            'Add Banner',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
