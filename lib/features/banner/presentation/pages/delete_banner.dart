import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteBanner {
  void confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: const Text(
          "Are you sure you want to permanently delete this banner from the ReadBuddy app?",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.black))),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              TextButton(
                onPressed: () {
                  context.read<BannerBloc>().add(DeleteBannerEvent(id));
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.black))),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
