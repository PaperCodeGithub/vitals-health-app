import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  State<ProfileWidget> createState() => _ProfileWidgetState();

}

class _ProfileWidgetState extends State<ProfileWidget>{
  bool isFollowing = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle, size: 60, color: Colors.pinkAccent),
          const SizedBox(width: 16),
          Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Aritra Das", style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),),
              SizedBox(height: 4),
              Text(
                "Developer",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16
                ),
              ),
            ]
          )),
          ElevatedButton(onPressed: (){
            setState(() {
              isFollowing = !isFollowing;
            });
          }, child: Text(isFollowing ? "Unfollow" : "Follow", style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(backgroundColor: isFollowing ? Colors.grey : Colors.pinkAccent),)
        ]
      ),
    );
  }

}