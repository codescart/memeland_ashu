import 'package:flutter/material.dart';
import 'package:memeland/util/data.dart';
import 'package:memeland/widget/chat_item.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // ignore: unused_field
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          cursorColor: Colors.white,
          decoration: InputDecoration.collapsed(
              hintText: 'Search', hintStyle: TextStyle(color: Colors.white)),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(
        //       Icons.filter_list,
        //     ),
        //     onPressed: () {},
        //   ),
        // ],
        // bottom: TabBar(
        //   controller: _tabController,
        //   indicatorColor: Theme.of(context).accentColor,
        //   labelColor: Theme.of(context).accentColor,
        //   unselectedLabelColor: Theme.of(context).textTheme.caption.color,
        //   isScrollable: false,
        //   tabs: <Widget>[
        //     Tab(
        //       text: "Message",
        //     ),
        //     // Tab(
        //     //   text: "Groups",
        //     // ),
        //   ],
        // ),
      ),
      body: ListView.separated(
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
        itemCount: chats.length,
        itemBuilder: (BuildContext context, int index) {
          Map chat = chats[index];
          return ChatItem(
            dp: chat['dp'],
            name: chat['name'],
            isOnline: chat['isOnline'],
            counter: chat['counter'],
            msg: chat['msg'],
            time: chat['time'],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
