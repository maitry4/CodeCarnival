import 'package:codecarnival/components/tile.dart';
import 'package:codecarnival/pages/teacher_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {

    final username = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.email : 'something';
  final List _pages = [
    const StudentHomePage(),
  ];
   int currentIndex = 0;
  void goToPage(index) {
    setState(() {
      currentIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index],
      ),
    );
  }
  
    return Scaffold(
  backgroundColor: Colors.white,
appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.transparent,
  leading: Icon(Icons.menu),
),
// bottomNavigationBar: BottomNavigationBar(
// items: [
// BottomNavigationBarItem(icon: Icon (Icons.home),
// label: '',),
// BottomNavigationBarItem(
// icon: Icon (Icons.favorite),
// label: '',
// ), // BottomNavigationBarItem
// BottomNavigationBarItem(
// icon: Icon (Icons.notifications),
// label: '',),
// ],
// ), // BottomNavigationBar
body: Column (children: [
      Padding(
              padding: const EdgeInsets.symmetric (vertical: 10.0),
              child: Text(
              "Discover your class and join the journey today!",
              style: GoogleFonts.bebasNeue( fontSize:47, ),
             
              ),
            ), 
            SizedBox(height: 25,),
            // Search Bar
         Padding(
           padding: const EdgeInsets.symmetric(horizontal:25.0),
           child: TextField(
             decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search your Classes",
               focusedBorder: OutlineInputBorder(
               borderSide: BorderSide (color: Colors.grey.shade600), //0₁
                ), 
               enabledBorder: OutlineInputBorder(
               borderSide: BorderSide (color: Colors.grey.shade600)
               ),
               ),
                ),
         ),

         SizedBox(height:25),

        //  // horizontal listview of coffee types
        //      Container(
        //           height: 50,
        //             child: ListView(
        //              scrollDirection: Axis.horizontal,
        //                 children:[
                         // horizontal listview of
                       Container(
                           height: 50,
                           //color: Colors.yellow,
                                 child: ListView(
                                 scrollDirection: Axis.horizontal,
                                        children:[
                                         Text('Subjects:',
                                         style: (GoogleFonts.bebasNeue(fontSize: 20)),),
                                         
                        ],
                       ),
                           ), 
                        
         //horizontal tileview

         Expanded (
          child: ListView(
          scrollDirection: Axis.horizontal,
           children: [
              //  CoffeeTile(),
              //  CoffeeTile(),
              //  CoffeeTile(),
              //  CoffeeTile(),
              //  CoffeeTile(),
              //  CoffeeTile(),
              //  CoffeeTile(),
               
           
            
           ],
           ), 
           ), 



          ]), 
        );}
}