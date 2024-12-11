import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/bar/sidebar_group_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item.dart';
import 'package:shimmer/shimmer.dart';
import '../../shared/actions/key_raw_listener.dart';
import '../../shared/widgets/error/customNoData.dart';
import 'package:rive/rive.dart' as rv;


class HomeMenuScreen extends StatefulWidget {
  static String id = 'homeMenuScreen';
  List<SidebarGroupItem> items;
  BuildContext context;
  HomeMenuScreen({Key? key, required this.context, required this.items});
  @override
  _HomeMenuScreenState createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  late Size size; late ThemeData theme;
  final _controller = ScrollController(), _scrollController = ScrollController();
  List<ScrollController> scrollControllers = [ScrollController(),ScrollController(),ScrollController(),ScrollController()];
  List<SidebarGroupItem> items = [];
  bool isLoading = true;
  final GlobalKey _gestureDetectorKey = GlobalKey(), _key = GlobalKey();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    getItems();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context); size = MediaQuery.of(context).size;
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
      LogicalKeyboardKey.escape : () async {Navigator.of(context).pushNamed('homeMenuScreen');},
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey: _key, child: Scaffold(appBar: size.width > 600? MyCustomAppBarDesktop(title: "Menú principal",
        context: widget.context,backButton: false) : null,
        body: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: size.width > 600 ? _body() : _bodyPortrait()
        )));
  }
  Widget _bodyLandscape(){
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      const SizedBox(height: 15,),
      SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child:Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 20,),
              SingleChildScrollView(child: Column(children: [
                for(int i = 0; i < items.length; i++)
                  Column(children: [
                    Text(items[i].text, style: TextStyle(fontSize: 20, color: theme.colorScheme.onSecondary),),
                    for(int j = 0; j < items[i].items.length; j++)
                      Column(children: [
                        Text(items[i].items[j].text, style: TextStyle(fontSize: 15, color: theme.colorScheme.onSecondary),),
                      ],)
                  ],)
              ],),),
            ],
          ),))
    ],),);
  }

  Widget _body(){
    return Container(height:size.height-70, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: FutureBuilder<List<SidebarGroupItem>>(future: _getDatos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: _buildLoadingIndicator(10));
            } else {
              final listAreas = snapshot.data ?? [];
              if (listAreas.isNotEmpty) {
                return Stack(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.only(right: 30), child: FadingEdgeScrollView.fromScrollView(
                      child: ListView.builder(controller: _scrollController,
                        scrollDirection: Axis.horizontal, itemCount: listAreas.length,
                        itemBuilder: (context, index) {
                          return Row(children: [
                            _myContainer(listAreas[index], scrollControllers[index]),
                            const SizedBox(width: 10,)
                          ],);
                        },
                      ),
                    ),),
                  ],
                );
              } else {
                if(isLoading){
                  return Center(child: _buildLoadingIndicator(10));
                }else{
                  return SingleChildScrollView(child: Center(child: NoDataWidget()),);
                }
              }
            }
          },
        ));
  }

  Widget _myContainer(SidebarGroupItem areaModels, ScrollController scrollController){
    return Container(height:size.height-75, width: 200,
        decoration: BoxDecoration(color: theme.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          Text(areaModels.text, style: TextStyle(color: theme.colorScheme.onPrimary,
              fontSize: 18, fontWeight: FontWeight.bold),),
          Divider(color: theme.colorScheme.secondary,),
          SizedBox(height: size.height-142,
            child:Scrollbar(thumbVisibility: true,controller: scrollController,child:
            FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(
                controller: scrollController, itemCount: areaModels.items.length,
                itemBuilder: (context, index){
                  return _card(areaModels.items[index]);
                },
              ),
            ),),)
        ],)
    );
  }
  Widget _card(SidebarItem sidebarItem){
    return InkWell(key: sidebarItem.subItems != null? _gestureDetectorKey:null, onTap: () async {
      if(!sidebarItem.isSelected){
        if(sidebarItem.subItems == null) {
          for(int i = 0; i < items.length; i++){
            for(int j = 0; j < items[i].items.length; j++){
              items[i].isCollapsed = true;
              items[i].items[j].isSelected = false;
            }
          }
          sidebarItem.isSelected = true;
          for(int i = 0; i < items.length; i++){
            for(int j = 0; j < items[i].items.length; j++){
              if(items[i].items[j].isSelected){
                items[i].isCollapsed = false;
                break;
              }
            }
          }
          sidebarItem.onPressed();
        }else{
          final RenderBox renderBox = _gestureDetectorKey.currentContext!.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);
          var result = await showMenu(context: context,
            position: RelativeRect.fromLTRB(position.dx+70,  position.dy+20,  position.dx+70, position.dy+20,),
            items: sidebarItem.subItems!.map((subItem) {
              return PopupMenuItem<String>(value: subItem.text, child: Text(subItem.text),);
            }).toList(),
          );
          if(result != null){
            for(var item in sidebarItem.subItems!){
              item.isSelected = false;
              if(item.text == result){
                item.isSelected = true;
                for(int i = 0; i < items.length; i++){
                  for(int j = 0; j < items[i].items.length; j++){
                    items[i].items[j].isSelected = false;
                  }
                }
                items.first.isCollapsed = true;

                sidebarItem.isSelected = true;
                for(int i = 0; i < items.length; i++){
                  for(int j = 0; j < items[i].items.length; j++){
                    if(items[i].items[j].isSelected){
                      items[i].isCollapsed = false;
                      break;
                    }
                  }
                }
                sidebarItem.onPressed();
                item.onPressed();
              }
            }
          }
        }
      }
    },child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: sidebarItem.isSelected? theme.colorScheme.secondary: theme.backgroundColor,
      ),
      child: Column(children: [
        Text((sidebarItem.text), style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 13.5 ),),
      ],),),);
  }
  Future<List<SidebarGroupItem>> _getDatos() async {
    try {
      return items;
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }
  Widget _bodyPortrait(){
    return SingleChildScrollView(child: Padding(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bienvenido a Full-ERP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary), textAlign: TextAlign.left,),
        Text("Seguimos trabajando en proporcionarte una mejor experiencia", style: TextStyle(fontSize: 16,
            color: theme.colorScheme.onSecondary), textAlign: TextAlign.left,),
        const SizedBox(width: 400, height: 400,
          child: rv.RiveAnimation.asset('assets/new_file.riv',),)
      ],),),);
  }
  Widget containerInfo(Color colorContainer, Color colorText, String title, String text){
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
      width: 170, height: 120, padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: colorContainer,
        border: Border.all(color: theme.colorScheme.onSecondaryContainer, width: 3,),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
        Row(children: [
          SizedBox(width: 150,child: Text(title, style: TextStyle(fontSize: 15, color: theme.colorScheme.background),),)],),
        Row(children: [
          SizedBox(width: 150,child: Text(text, style: TextStyle(fontSize: 21,color: theme.colorScheme.background, fontWeight: FontWeight.bold),),)
        ],)
      ],),));
  }
  // Método para generar datos de ejemplo

  Widget _buildLoadingIndicator(int n) {
    return Stack(children: [
      FadingEdgeScrollView.fromSingleChildScrollView(
          child: SingleChildScrollView(controller: _scrollController,
            scrollDirection: Axis.horizontal, physics: const NeverScrollableScrollPhysics(),
            child: Row(children: [
              for(int i = 0; i<n; i++)...[
                _myContainerEsqueleto(),
                const SizedBox(width: 10,)
              ]
            ],),
          )
      ),
    ],);
  }
  Widget _myContainerEsqueleto(){
    return Container(height: size.height-75, width: 200,
        decoration: BoxDecoration(color: theme.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(children: [
          SizedBox(width: 260,height: 40,child: Shimmer.fromColors(baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1), enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
          ),),
          Divider(color: theme.colorScheme.secondary,),
          SizedBox(height: size.height-156,
            child: FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _scrollController, itemCount: 15,
                itemBuilder: (context, index){
                  return cardEsqueleto(size.width);
                },
              ),
            ),)
        ],)
    );
  }
  Future<void> getItems() async {
    await Future.delayed(const Duration(milliseconds: 500), (){
      items = widget.items;
      for(int i = 0; i < items.length; i++){
        if(i == 0){
          items[i].isCollapsed = false;
        }else{
          items[i].isCollapsed = true;
        }
        for(int j = 0; j < items[i].items.length; j++){
          if(items[i].items[j].text == 'Menú Principal'){
            items[i].items[j].isSelected = true;
          }else{
            items[i].items[j].isSelected = false;
          }
        }
      }
    });
    setState(() {});
  }
  Widget cardEsqueleto(double width){
    return SizedBox(width: width, height: 50,child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
        color: theme.backgroundColor, borderOnForeground: true,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Shimmer.fromColors(
            baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1),
            enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        )
    ),);
  }
}