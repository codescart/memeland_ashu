import 'dart:convert';

import 'package:memeland/global/global.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:memeland/models/notitications_model.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Future<List> notificationData;

  Future<List> getAllnotification() async {
    Uri url = Uri.parse("${baseUrl()}/user_notification_listing");
    var response = await http.post(url, body: {'user_id': userID});

    if (response.statusCode == 200) {
      var output = response.body;
      var json = jsonDecode(output);
      //print(json);
      //print(json['services'][0]["id"]);
      return json['data'];
    }
    return null;
  }

  @override
  void initState() {
    setState(() {
      notificationData = getAllnotification();
    });

    super.initState();
  }

  NotificationsModel notificationsModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        title: Text(
          "Notifications",
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColorLight,
            )),
      ),
      body: FutureBuilder(
          future: notificationData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length <= 0) {
                return Center(
                  child: Text("Don't have any Notification"),
                );
              } else {
                return ListView.separated(
                  padding: EdgeInsets.all(10),
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Divider(),
                      ),
                    );
                  },
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return notiTile(snapshot.data[index]);
                  },
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget notiTile(data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            data['profile_pic'],
          ),
          radius: 25,
        ),
        contentPadding: EdgeInsets.all(0),
        title: Text(
          data['username'],
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
        subtitle: Text(
          data['message'],
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        ),
        trailing: Text(
          data['date'],
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 11,
              color: Theme.of(context).primaryColorLight),
        ),
        onTap: () {},
      ),
    );
  }
}
