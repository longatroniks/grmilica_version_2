import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grmilica_version_2/utils/colors.dart';
import 'package:grmilica_version_2/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
        title: SvgPicture.asset(
          'assets/images/GRMILICA.svg',
          height: 50,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.messenger_outline,
              color: redColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context,index) => PostCard(
                    snap: snapshot.data!.docs[index].data(),
                  ),
                  );
              }),
    );
  }
}
