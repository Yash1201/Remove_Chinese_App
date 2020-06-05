import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;


void main() => runApp(MaterialApp(home: ListAppsPages()));

class ListAppsPages extends StatefulWidget {
  @override
  _ListAppsPagesState createState() => _ListAppsPagesState();
}

class _ListAppsPagesState extends State<ListAppsPages> {
  bool _showSystemApps = false;
  bool _onlyLaunchableApps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chinese Installed applications"),
      ),
      body: _ListAppsPagesContent(
          includeSystemApps: _showSystemApps,
          onlyAppsWithLaunchIntent: _onlyLaunchableApps,
          key: GlobalKey()),
    );
  }
}

class _ListAppsPagesContent extends StatelessWidget {
  final bool includeSystemApps;
  final bool onlyAppsWithLaunchIntent;

  const _ListAppsPagesContent(
      {Key key,
        this.includeSystemApps: false,
        this.onlyAppsWithLaunchIntent: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DeviceApps.getInstalledApplications(
            includeAppIcons: true,
            includeSystemApps: includeSystemApps,
            onlyAppsWithLaunchIntent: onlyAppsWithLaunchIntent),
        builder: (context, data) {
          if (data.data == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            List<Application> chineseapps = data.data;
            List<Application> apps = List<Application>();
            List<String> myList = List<String>();
            myList.add("App Manager");
            myList.add("Skype");
            myList.add("Tik Tok");
            myList.add("CamScanner");

            chineseapps.forEach((element) {
              if(myList.contains(element.appName))
                apps.add(element);
            });
            print(apps);
            return ListView.builder(
                itemBuilder: (context, position) {
                  Application app = apps[position];

                  return Column(
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: app is ApplicationWithIcon
                            ? CircleAvatar(
                          backgroundImage: MemoryImage(app.icon),
                          backgroundColor: Colors.white,
                        )
                            : null,
                        onTap: () => DeviceApps.openApp(app.packageName),
                        title: Text("${app.appName}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        ),
//                        subtitle: Text('Version: ${app.versionName}\nSystem app: ${app.systemApp}\nAPK file path: ${app.apkFilePath}\nData dir : ${app.dataDir}\nInstalled: ${DateTime.fromMillisecondsSinceEpoch(app.installTimeMilis).toString()}\nUpdated: ${DateTime.fromMillisecondsSinceEpoch(app.updateTimeMilis).toString()}'),
                        subtitle: RaisedButton(
                          onPressed: () async {
                            String url = 'https://www.google.com/search?q=alternative+app+for+${app.appName}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            }
                            else {
                              throw 'Could not launch $url';
                            }
                          },
                          color: Colors.yellow,
                          child: Text('Search alternate app for ${app.appName}'),
                        ),
                        trailing: RaisedButton(
                          onPressed: () {
                            android_intent.Intent()
                              ..setAction(android_action.Action.ACTION_DELETE)
                              ..setData(Uri.parse("package:${app.packageName}"))
                              ..startActivityForResult().then((data) {
                                print(data);
                              }, onError: (e) {
                                print(e);
                              });
                          },
                          textColor: Colors.red,
//                          color: Colors.blue,
                          child: Text(
                              "Uninstall",
                          ),
                        ),
                            ),
                      Divider(
                        height: 1.0,
                      )
                    ],
                  );
                },
                itemCount: apps.length);
          }
        });
  }
}
