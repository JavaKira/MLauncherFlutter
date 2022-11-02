import 'package:flutter/material.dart';
import 'package:mlauncher_flutter/version.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MLauncher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Sidebar(content: const HomePage()),
    );
  }
}

class Sidebar extends StatefulWidget {
  Sidebar({required this.content, super.key});

  Widget content;

  @override
  State<Sidebar> createState() => _SideBarState();
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _SideBarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: 67,
          color: const Color(0xff757575),
          child: Column (
            children: [
              TextButton(
                onPressed: () => {
                  setState(() => {
                    widget.content = const HomePage()
                  })
                },
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 52.0,
                ),
              ),
              TextButton(
                onPressed: () => {
                  setState(() => {
                    widget.content = const SettingsPage()
                  })
                },
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 52.0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.content,
        ),
      ],
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color(0xffE0E0E0),
    );
  }
}

class _HomePageState extends State<HomePage> {
  double loadProgress = 0.0;
  Version? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0E0E0),
      body: Column(
        children: [
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            color: const Color(0xff757575),
            child: Align(
                alignment: Alignment.center,
                child: Center(
                  child: Image.asset(
                  'assets/logo.png',
                  height: 768*4,
                  width: 107*4,),
                ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height-70-100,
            width: MediaQuery.of(context).size.width,
            child: Align(
                alignment: Alignment.center,
                child: ListView(
                  children: const [],
                ),
            ),
          ),
          Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            color: const Color(0xff757575),
            child: Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 20,
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: const [
                            BoxShadow(color: Color(0xff9ACD32), spreadRadius: 10),
                          ],
                        ),
                        child: FutureBuilder(
                            future: VersionLoader.load(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData){
                                dropdownValue ??= snapshot.data?.first;
                                return DropdownButton<Version>(
                                  value: dropdownValue,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.black),
                                  onChanged: (Version? value) {
                                    setState(() {
                                      dropdownValue = value!;
                                    });
                                  },
                                  items: snapshot.data?.map<DropdownMenuItem<Version>>((Version value) {
                                    return DropdownMenuItem<Version>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                );
                              } else if(snapshot.hasError) {
                                print(snapshot.error.toString());
                                return const SizedBox(
                                  child: Text("error when load versions"),
                                );
                              }

                              return const SizedBox(
                                width: 0,
                                height: 0,
                              );
                            }
                        ),
                      )
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () => {
                          if (dropdownValue != null) {
                            !dropdownValue!.isDownloaded ?
                            dropdownValue?.download(onLoad: (value) => {
                              setState(() => {
                                loadProgress += value.length/dropdownValue!.size
                              })
                            }, onDone: () => {
                              setState(() => {
                                loadProgress = 0
                              })
                            }).then((value) => setState(() => {}))
                                : dropdownValue?.launch()
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: const [
                              BoxShadow(color: Color(0xff9ACD32), spreadRadius: 10),
                            ],
                          ),
                          child: Builder(builder: (BuildContext context) {
                              if (dropdownValue == null) return Container();
                              return Text(!dropdownValue!.isDownloaded ? "Download" : "Launch", style: const TextStyle(color: Colors.black));
                            },
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 200,
                        height: 32,
                        child: Builder(builder: (BuildContext context) {
                          if (loadProgress != 0) {
                            return LinearProgressIndicator(
                              value: loadProgress,
                            );
                          } else {
                            return Container();
                          }
                        })
                      )
                    ),
                  ],
                ),
            ),
          ),
        ],
      )
    );
  }
}
