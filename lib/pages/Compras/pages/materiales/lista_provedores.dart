import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/textfields/my_text_field.dart';
import '../../../../shared/utils/icon_library.dart';
import '../../../../shared/utils/texts.dart';
import '../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';


class ListaProvedores extends StatefulWidget {

  const ListaProvedores({super.key});

  @override
  State<ListaProvedores> createState() => _ListaProvedoresState();
}

class _ListaProvedoresState extends State<ListaProvedores> {
  Color baseColor = const Color(0xFFF2F2F2);
  final GlobalKey listaKey = GlobalKey();
  late Size size;
  late ThemeData theme;

  final _infoFormKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _scrollController2 = ScrollController();

  final TextEditingController _searchProviderController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;
    theme = Theme.of(context);

    return PressedKeyListener(
        keyActions: {
          LogicalKeyboardKey.escape: () {
            CustomAwesomeDialog(title: Texts.alertExit,
                desc: Texts.lostData, btnOkOnPress: (){Navigator.of(context).pop();},
                btnCancelOnPress: (){}).showQuestion(context);
          },},
      Gkey: listaKey,
      child: Scaffold(
        appBar: size.width > 600 ? MyCustomAppBarDesktop(padding: 10.0, title: 'Lista de Provedores',
          height: 45, backButton: true, suffixWidget:
          ElevatedButton(
            style: ElevatedButton.styleFrom( backgroundColor: theme.backgroundColor ), onPressed: () {  }, child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Agregar',style: TextStyle( color: theme.colorScheme.onPrimary),),
              Icon( IconLibrary.iconAdd, color: theme.colorScheme.onPrimary,)
          ],),
          ), context: context, defaultButtons: false, borderRadius: BorderRadius.circular(25.0),
        ) : null,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0 , vertical: 5.0),
          child: _providerList(),
        ),
      ),

    );
  }

  Widget _providerList(){
    return Column(
      children: [
        const SizedBox( height: 10, ),
        SizedBox(width: size.width/3,
          child: MyTextField(
              backgroundColor: theme.colorScheme.background,
              inputColor: theme.colorScheme.onPrimary, colorBorder: theme.primaryColor,
              text: 'Busqueda de Proveedor', controller: _searchProviderController
          ),
        ),
        const SizedBox( height: 10, ),
        _headerTitleConainter("Datos de provedor"),
        // _formInfo(),
        _infoContainers()

      ],
    );
  }

Widget _infoContainers ( ) {
    return Column( children: [

      _dividedContainerRow(
      Container(
      height: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: theme.colorScheme.onBackground.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all( color: theme.colorScheme.primary, width: 3)),
      child:Column(
          children:[
            const Align(alignment: Alignment.center,
                child:  Text( 'Title 1 ', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
            Divider( color: theme.colorScheme.background,indent: 25,endIndent:25 ,height:2, ),
            const Align(alignment: Alignment.center,
                child:  Text( Texts.lorem,
                  style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                  textAlign: TextAlign.justify,
                )),
          ]
      ),

    ),
      Container(
            height: 90,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all( color: theme.colorScheme.primary, width: 3)),
            child:Column(
                children:[
                  const Align(alignment: Alignment.center,
                      child:  Text( 'Title 2', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                  Divider( color: theme.colorScheme.background,indent: 25,endIndent:25 ,height:2, ),
                  const Align(alignment: Alignment.center,
                      child:  Text( Texts.lorem,
                        style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                        textAlign: TextAlign.justify,
                      )),
                ]
            ),

          ) ),
      const SizedBox( height: 10,),
      _dividedContainerRow(
          Container(
            height: 90,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all( color: theme.colorScheme.primary, width: 3)),
            child:Column(
                children:[
                  const Align(alignment: Alignment.center,
                      child:  Text( 'Title 3', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                  Divider( color: theme.colorScheme.background,indent: 25,endIndent:25 ,height:2, ),
                  const Align(alignment: Alignment.center,
                      child:  Text( Texts.lorem,
                        style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                        textAlign: TextAlign.justify,
                      )),
                ]
            ),

          ),
          Container(
            height: 90,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all( color: theme.colorScheme.primary, width: 3)),
            child:Column(
                children:[
                  const Align(alignment: Alignment.center,
                      child:  Text( 'Title 4', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                  Divider( color: theme.colorScheme.background,indent: 25,endIndent:25 ,height:2, ),
                  const Align(alignment: Alignment.center,
                      child:  Text( Texts.lorem,
                        style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                        textAlign: TextAlign.justify,
                      )),
                ]
            ),

          )),
      const SizedBox( height: 23,),
      _dividedContainerRow(
        Container(

          color: const Color(0xFF3E4D54),
          child: ClayContainer(
            color: const Color(0xFF3E4D54),
            customBorderRadius:  BorderRadius.circular(10),
            // curveType: CurveType.convex,
            height: 90,
            depth: 12,
            child: Column(
              children: [
                const Align(alignment: Alignment.center,
                    child:  Text( 'Title 6', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                Divider( color: theme.colorScheme.secondaryContainer,indent: 25,endIndent:25 ,height:2, ),
                const Align(alignment: Alignment.center,
                    child:  Text( Texts.lorem,
                      style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                      textAlign: TextAlign.justify,
                    )),
              ], ),

          ),
        ),
        Container(

          color: const Color(0xFF3E4D54),
          child: ClayContainer(
            color: const Color(0xFF3E4D54),
            height: 90,
            depth: 12,
            customBorderRadius:  BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(alignment: Alignment.center,
                    child:  Text( 'Title 6', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                Divider( color: theme.colorScheme.secondaryContainer,indent: 25,endIndent:25 ,height:2, ),
                const Align(alignment: Alignment.center,
                    child:  Text( Texts.lorem,
                      style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                      textAlign: TextAlign.justify,
                    )),
              ], ),

          ),
        ),
      ),
      const SizedBox( height: 23,),
      _dividedContainerRow(
          Container(

            color: const Color(0xFF3E4D54),
            child: ClayContainer(
              color: const Color(0xFF3E4D54),
              customBorderRadius:  BorderRadius.circular(10),
              // curveType: CurveType.convex,
              height: 90,
              depth: 12,
              child: Column(
                children: [
                const Align(alignment: Alignment.center,
                    child:  Text( 'Title 6', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                Divider( color: theme.colorScheme.secondaryContainer,indent: 25,endIndent:25 ,height:2, ),
                const Align(alignment: Alignment.center,
                    child:  Text( Texts.lorem,
                      style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                      textAlign: TextAlign.justify,
                    )),
              ], ),

            ),
          ),
        Container(

          color: const Color(0xFF3E4D54),
          child: ClayContainer(
            color: const Color(0xFF3E4D54),
            height: 90,
            depth: 12,
            customBorderRadius:  BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(alignment: Alignment.center,
                    child:  Text( 'Title 6', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                Divider( color: theme.colorScheme.secondaryContainer,indent: 25,endIndent:25 ,height:2, ),
                const Align(alignment: Alignment.center,
                    child:  Text( Texts.lorem,
                      style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                      textAlign: TextAlign.justify,
                    )),
              ], ),

          ),
        ),
      ),
      const SizedBox( height: 23,),
      _dividedContainerRow(
        Container(

          color: const Color(0xFF3E4D54),
          child: ClayContainer(
            color: const Color(0xFF3E4D54),
            customBorderRadius:  BorderRadius.circular(10),
            // curveType: CurveType.convex,
            height: 90,
            depth: 12,
            child: Column(
              children: [
                const Align(alignment: Alignment.center,
                    child:  Text( 'Title 6', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                Divider( color: theme.colorScheme.secondaryContainer,indent: 25,endIndent:25 ,height:2, ),
                const Align(alignment: Alignment.center,
                    child:  Text( Texts.lorem,
                      style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                      textAlign: TextAlign.justify,
                    )),
              ], ),

          ),
        ),
        Container(

          color: const Color(0xFF3E4D54),
          child: ClayContainer(
            color: const Color(0xFF3E4D54),
            height: 90,
            depth: 12,
            customBorderRadius:  BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(alignment: Alignment.center,
                    child:  Text( 'Title 6', style: TextStyle( fontSize: 15, fontWeight: FontWeight.normal ),textAlign: TextAlign.justify, )),
                Divider( color: theme.colorScheme.secondaryContainer,indent: 25,endIndent:25 ,height:2, ),
                const Align(alignment: Alignment.center,
                    child:  Text( Texts.lorem,
                      style: TextStyle( fontSize: 12, fontWeight: FontWeight.normal ),
                      textAlign: TextAlign.justify,
                    )),
              ], ),

          ),
        ),
      ),
    ], );
}


  Widget _headerTitleConainter( String text ){
    return Container(
      width: size.width/2, decoration: BoxDecoration( borderRadius: BorderRadius.circular(10.0)),
      padding: const EdgeInsets.all( 10 ),
      child: Center(
        child: Column(
          children: [
            Text( text, style: const TextStyle( fontSize: 20, fontWeight: FontWeight.bold)),
            Divider( thickness: 2, color: theme.colorScheme.secondary, )
          ],),
      ),
    );
  }

  Widget _dividedContainerRow( Widget widgetL, Widget widgetR ){
    return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox( width: size.width*.18, child: widgetL,),
        const SizedBox( width: 10,),
        SizedBox( width: size.width*.18, child: widgetR,),
      ],);
  }

  Widget _threeRowContainer( Widget widget1, Widget widget2, Widget widget3){
    return Row(
        children:
        [
          SizedBox( width: size.width*10, child: widget1, ),
          const SizedBox(),
          SizedBox( width: size.width*10, child: widget2, ),
          const SizedBox(),
          SizedBox( width: size.width*10, child: widget3,),
        ]
    );
  }

  Widget _singleFormRow( Widget widgetL){
    return Row( mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox( width: 53, ),
        SizedBox( width: size.width/3, child: widgetL,),
      ],);
  }
}
