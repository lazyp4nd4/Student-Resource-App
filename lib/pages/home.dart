import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studentresourceapp/components/custom_loader.dart';
import 'package:studentresourceapp/components/navDrawer.dart';
import 'package:studentresourceapp/models/user.dart';
import 'package:studentresourceapp/pages/subject.dart';
import 'package:studentresourceapp/utils/contstants.dart';
import 'package:studentresourceapp/utils/sharedpreferencesutil.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../utils/contstants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User userLoad = new User();
  bool semesterExists = true;

  Future fetchUserDetailsFromSharedPref() async {
    var result = await SharedPreferencesUtil.getStringValue(
        Constants.USER_DETAIL_OBJECT);
    Map valueMap = json.decode(result);
    User user = User.fromJson(valueMap);
    setState(() {
      userLoad = user;
    });

    final snapShot = await Firestore.instance
        .collection('Semesters')
        .document('${user.semester.toString()}')
        .get();
    print('${user.semester.toString()} is the current semester');
    if (snapShot.exists) {
      print('Semester data exists');
      setState(() {
        semesterExists = true;
      });
    } else {
      print('Semester Data DNE');
      setState(() {
        semesterExists = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetailsFromSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(userData: userLoad),
        appBar: AppBar(
          backgroundColor: Constants.DARK_SKYBLUE,
          elevation: 0,
          bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                  left: 16,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Semester ${userLoad.semester ?? ''}",
                      style: TextStyle(
                          fontSize: 24,
                          color: Constants.WHITE,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              preferredSize: Size.fromHeight(28)),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: semesterExists
              ? StreamBuilder(
                  stream: Firestore.instance
                      .collection('Semesters')
                      .document('${userLoad.semester}')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map branchSubjects = snapshot.data['branches']
                          ['${userLoad.branch.toUpperCase()}'];
                      print(branchSubjects.toString());
                      List<Widget> subjects = [];
                      branchSubjects.forEach((key, value) {
                        subjects.add(
                          FlatButton(
                            child: ListTile(
                              leading: Image.asset(
                                'assets/images/Computer.png',
                                height: 32,
                              ),
                              title: Text(
                                key,
                                style: TextStyle(
                                    color: Constants.BLACK,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                value,
                                style: TextStyle(
                                    color: Constants.STEEL,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right,
                                color: Constants.BLACK,
                                size: 36,
                              ),
                            ),
                            splashColor: Constants.SKYBLUE,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Subject(
                                        semester: userLoad.semester,
                                        subjectCode: key);
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      });
                      subjects.add(SizedBox(
                        height: 0,
                      ));

                      return Container(
                          child: ListView.separated(
                        itemCount: subjects.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          thickness: 0.5,
                          color: Constants.SMOKE,
                          indent: 24,
                          endIndent: 24,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return subjects[index];
                        },
                      ));
                    }
                    return CustomLoader();
                  },
                )
              : Center(
                  child: TyperAnimatedTextKit(
                      //Case when there is no Material present
                      onTap: () {
                        print("Tap Event");
                      },
                      speed: Duration(
                          milliseconds: 100), //Duration of TextAnimation

                      text: [
                        "Oops😵",
                        "It feels Lonely Here🙄",
                        "The Content is not Uploaded yet😬",
                        "It's Still Under Construction🚧",
                        "It would be Uploaded Soon😃"
                      ],
                      textStyle: TextStyle(fontSize: 25.0, fontFamily: "Agne"),
                      textAlign: TextAlign.center,
                      alignment:
                          AlignmentDirectional.topStart // or Alignment.topLeft
                      ),
                ),
        ));
  }
}
