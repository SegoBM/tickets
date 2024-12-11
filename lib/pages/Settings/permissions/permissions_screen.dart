import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/areaController.dart';
import 'package:tickets/models/ConfigModels/area.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_decoration.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:tickets/shared/widgets/my_expandable/my_expandable.dart';
import '../../../controllers/ConfigControllers/PermisoController/departamentoSubmoduloController.dart';
import '../../../controllers/ConfigControllers/PermisoController/permisoController.dart';
import '../../../models/ConfigModels/PermisoModels/Modulo.dart';
import '../../../models/ConfigModels/PermisoModels/departamentoSubmodulo.dart';
import '../../../models/ConfigModels/PermisoModels/permiso.dart';
import '../../../models/ConfigModels/PermisoModels/submoduloPermisos.dart';
import '../../../models/ConfigModels/departamento.dart';
import '../../../shared/utils/icon_library.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:shimmer/shimmer.dart';

import '../../../shared/widgets/error/customNoData.dart';

class PermissionsScreen extends StatefulWidget {
  BuildContext context;
  PermissionsScreen({super.key, required this.context});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> with TickerProviderStateMixin {
  late ThemeData theme; late Size size;
  final ScrollController _scrollController = ScrollController(),
      _scrollController2 = ScrollController(), scrollController = ScrollController();
  final _skeletonController = ScrollController();
  final _key = GlobalKey();
  List<AreaModels> listAreas2 = [];
  List<String> selectedItemsAreas = [],  selectedSubPermisos = [],
      adminTypeList = ["Usuario", "Administrador", "SuperAdmin"], listAreas = [];
  List<SubmoduloPermisos> listSubModulos = [],listPermisos = [];
  List<Modulo> listPermisos2 = [];
  bool entered = false, isSwitched = false, _isLoading = true;
  double width = 0;
  late TabController tabController;
  DepartamentoSubmoduloController departamentoSubmoduloController = DepartamentoSubmoduloController();
  PermisoController permisoController =  PermisoController();
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    getAreas();
    _getModuloPermiso();
    _getSubModulos();
    const timeLimit = Duration(seconds: 10);
    Timer(timeLimit, () {
      if(listSubModulos.isEmpty){
        setState(() {
          _isLoading = false;
        });
      }else{
        _isLoading = false;
      }
    });
    // selectedItemSubPermisos = adminTypeList.first;
  //_loadSubmodulosAndPrintPermisos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context); size = MediaQuery.of(context).size;
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
      LogicalKeyboardKey.escape : () async {Navigator.of(context).pushNamed('homeMenuScreen');},
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey: _key, child: Scaffold(backgroundColor: theme.backgroundColor,
      appBar: size.width > 600? MyCustomAppBarDesktop(
        title: 'Permisos sugeridos',context: widget.context, backButton: false,) : null,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 5,),
          child: size.width> 600? _bodyLandScape() : _bodyPortrait()
      ),
    ));
  }

  Widget _bodyLandScape(){
    return Column(children: [
      TabBar(controller: tabController,// Color de fondo del TabBar
        labelColor: theme.colorScheme.onPrimary, unselectedLabelColor: Colors.grey[400], // Color de las pestañas no seleccionadas
        labelStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), // Estilo de texto de las pestañas
        indicatorWeight: 5, padding: EdgeInsets.symmetric(horizontal: size.width*.15),
        tabs: const [
          Tab(text: "Permiso asociado al tipo de usuario"),
          Tab(text: "Acceso a súbmodulo por departamento",),
        ],
      ),
      Expanded(child: SizedBox(height: size.height-140,width: size.width,child:
        TabBarView(controller: tabController, children: _bodyPrincipal(),),),
      ),
    ],);
  }
  Widget _bodyPortrait(){
    return const Placeholder(child: Text('Portrait'),);
  }

  List<Widget> _bodyPrincipal(){
    return [
      _fullBody(listPermisos),
      _bodyPermisoDepartamento(),
    ];
  }
  Widget _bodyPermisoDepartamento(){
    return Padding(padding: const  EdgeInsets.all(5),
        child: FutureBuilder<List<AreaModels>>(
          future: _getDatos2(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: _buildLoadingIndicator2(10));
            } else {
              final listProducto = snapshot.data ?? [];
              if (listProducto.isNotEmpty) {
                return Scrollbar(thumbVisibility: true,controller: _scrollController2,
                    child: FadingEdgeScrollView.fromScrollView(
                      child: ListView.builder(physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController2, itemCount: listAreas2.length,
                          itemBuilder: (context, index){
                            return header(listAreas2[index]);
                          })
                ));
              } else {
                if(_isLoading){
                  return Center(child: _buildLoadingIndicator2(10));
                }else{
                  return SingleChildScrollView(child: Center(child: NoDataWidget()),);
                }
              }
            }
          },
        )
    );
  }

  Widget _fullBody(List<SubmoduloPermisos> permiso){
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: FutureBuilder<List<SubmoduloPermisos>>(
        future: _getDatos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: _buildLoadingIndicator(10));
          } else {
            final listProducto = snapshot.data ?? [];
            if (listProducto.isNotEmpty) {
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
                child:Scrollbar(controller: _scrollController,thumbVisibility: true,
                  child:  FadingEdgeScrollView.fromSingleChildScrollView(
                    child: SingleChildScrollView(controller: _scrollController,
                        child: IntrinsicHeight(
                          child: Wrap(alignment: WrapAlignment.center, spacing: 5, runSpacing: 5,
                            children: [
                              for(int i = 0; i <listSubModulos.length; i++)...[
                                _cabeza(listSubModulos[i]),
                              ],
                            ],
                          ),)
                    )
                ),)
              );
            } else {
              if(_isLoading){
                return Center(child: _buildLoadingIndicator(10));
              }else{
                return SingleChildScrollView(child: Center(child: NoDataWidget()),);
              }
            }
          }
        },
      )
    );
  }
  Widget _buildLoadingIndicator(int n) {
       return FadingEdgeScrollView.fromSingleChildScrollView(
             child: SingleChildScrollView(controller: _scrollController,
                 physics: const NeverScrollableScrollPhysics(),
                 child: Wrap(alignment: WrapAlignment.center, spacing: 5, runSpacing: 5,
                   children: [
                     for(int i = 0; i <n; i++)...[
                       _myContainerEsqueleto()
                     ],
                   ],
                 )
             )
         );
     }
  Widget _buildLoadingIndicator2(int n) {
       return FadingEdgeScrollView.fromSingleChildScrollView(
           child: SingleChildScrollView(controller: _scrollController,
               physics: const NeverScrollableScrollPhysics(),
               child: Wrap(alignment: WrapAlignment.center, spacing: 5, runSpacing: 5,
                 children: [
                   for(int i = 0; i <n; i++)...[
                     _myContainerEsqueleto2()
                   ],
                 ],
               )
           )
       );
     }
  Widget cardEsqueleto(double width){
       return SizedBox(width: width, height: 85,child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
         child: Shimmer.fromColors(baseColor: theme.primaryColor,
           highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
           const Color.fromRGBO(46, 61, 68, 1), enabled: true,
           child: Container(margin: const EdgeInsets.all(3),decoration:
           BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),),
           ),
         ),
       ));
     }
  Widget cardEsqueleto2(){
       return SizedBox(height: 85,child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
         child: Shimmer.fromColors(baseColor: theme.primaryColor,
           highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
           const Color.fromRGBO(46, 61, 68, 1), enabled: true,
           child: Container(margin: const EdgeInsets.all(3),decoration:
           BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),),
           ),
         ),
       ));
     }
  Widget _myContainerEsqueleto(){
       return Container(height: 260, width: 450,
           decoration: BoxDecoration(color: theme.primaryColor,
             borderRadius: const BorderRadius.all(Radius.circular(10)),
           ),
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
           child: Column(children: [
             SizedBox(width: 260,height: 40,child: Shimmer.fromColors(
               baseColor: theme.primaryColor,
               highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0) :
               const Color.fromRGBO(46, 61, 68, 1), enabled: true,
               child: Container(margin: const EdgeInsets.all(3),decoration:
               BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),),
               ),
             ),),
             Divider(color: theme.colorScheme.secondary,),
             SizedBox(height: 180,
               child: FadingEdgeScrollView.fromScrollView(
                 child: ListView.builder(
                   physics: const NeverScrollableScrollPhysics(),
                   controller: scrollController, itemCount: 15,
                   itemBuilder: (context, index){
                     return cardEsqueleto(width);
                   },
                 ),
               ),)
           ],)
       );
     }
  Widget _myContainerEsqueleto2(){
       return Container(height: 245, width: 300,
           decoration: BoxDecoration(color: theme.primaryColor,
             borderRadius: const BorderRadius.all(Radius.circular(10)),
           ),
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
           child: Column(children: [
             SizedBox(height: 40,child: Shimmer.fromColors(
               baseColor: theme.primaryColor,
               highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
               const Color.fromRGBO(46, 61, 68, 1),
               enabled: true,
               child: Container(margin: const EdgeInsets.all(3),decoration:
               BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),),
               ),
             ),),
             Divider(color: theme.colorScheme.secondary,),
             SizedBox(height: 160,
               child: FadingEdgeScrollView.fromScrollView(
                 child: ListView.builder(physics: const NeverScrollableScrollPhysics(),
                   controller: scrollController, itemCount: 15,
                   itemBuilder: (context, index){
                     return cardEsqueleto2();
                   },
                 ),
               ),)
           ],)
       );
     }

  Future<List<SubmoduloPermisos>> _getDatos() async{
    return listSubModulos;
  }
  Future<List<AreaModels>> _getDatos2() async{
    return listAreas2;
  }
  Widget _cabeza(SubmoduloPermisos sub){
    return Container(width: 400, height: 195,
      decoration: BoxDecoration(color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ), padding: const EdgeInsets.all(5),
      child: Padding(padding: const EdgeInsets.all(2.0),
        child: SingleChildScrollView(child: Column(
          children: [
            Text(sub.nombreSubmodulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,),),
            Divider(color: theme.colorScheme.secondary , endIndent: 2, indent: 2, thickness: 3,),
            const SizedBox(height: 5,),
            bodyCard(sub),
          ],
        ),)
      ),
    );
  }

  Widget bodyCard(SubmoduloPermisos permiso){
    return  Padding(padding: const  EdgeInsets.all(2),
      child: Center(child: Column(children: [..._buildPermissionList(permiso)])),
    );
  }

  List<Widget> _buildPermissionList(SubmoduloPermisos subModulo){
    List<Widget> permissions = [];
    for (var permiso in subModulo.permisos!) {
      permissions.add(
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Column(children: [
                SizedBox(width: 130,child: Text(permiso.nombre,
                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),),)
              ],),
              Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  SizedBox(width: 200,height: 40,
                    child: MyDropdown(
                      textStyle: const TextStyle(fontSize: 12),
                      boxDecoration: BoxDecoration(color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      dropdownItems: adminTypeList, selectedItem: permiso.tipoUsuario,
                      suffixIcon: Icon( Icons.person_2_outlined, color: theme.colorScheme.onPrimary,),
                      onPressed: ((newValue){
                        if(permiso.tipoUsuario != newValue){
                          CustomAwesomeDialog(title: '¿Desea cambiar el permiso \"${permiso.nombre}\" de '
                              '\"${permiso.tipoUsuario}\" a \"${newValue}\"?', desc: '', btnOkOnPress: () {
                             actualizarPermiso(permiso, newValue!);
                          }, btnCancelOnPress: () {  },).showQuestion(context);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 5,),
                ]
              ),
            ],
          )
      );
    }
    return permissions;
  }
  Widget header(AreaModels area){
     return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
         padding: const EdgeInsets.all(2.0),
         child: Column(children: [
           Text(area.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
           SizedBox(width: size.width/3,child: Divider(thickness: 2,color: theme.colorScheme.secondary,),),
           Wrap(alignment: WrapAlignment.start,
             spacing: 5, runSpacing: 5, children: _buildDepartments(area.departamentosSubmodulo!),)
         ],)
     );
  }
  List<Widget> _buildDepartments(List<DepartamentoModels> departamentos){
     List<Widget> departments = [];
     for (DepartamentoModels department in departamentos){
       departments.add(_myContainer(department));
     }
     return departments;
  }
  Widget _myContainer(DepartamentoModels area){
       return Container(width: 300,
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
           decoration: BoxDecoration(color: theme.colorScheme.primary,
             borderRadius: const BorderRadius.all(Radius.circular(10)),),
           child: Column(children:[
             Text(area.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
           Divider(color: theme.colorScheme.secondary,endIndent: 2,indent: 2,thickness: 3,),
           const SizedBox(height: 5,),
           // TODO: first expandable
           ..._buildModules(area),
        ],),
       );
  }

  List<Widget> _buildModules(DepartamentoModels department){
       List<Widget> modules = [];
       for(Modulo modulo in listPermisos2){
         modules.add(
           Column(children: [
             MyExpandable(backgroundColor: theme.colorScheme.secondary, isExpanded: false,
               borderRadius: 8, header: Padding(padding: const  EdgeInsets.all(5.0),
                 child:
                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                   Text(modulo.nombreModulo, style:const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),),
                   Switch(
                     value: department.departamentoSubmodulos.where((element) => modulo.submodulos.any((element2) => element2.submoduloId == element.subModuloId)).isNotEmpty,
                     onChanged: (value){
                       if(value){
                         CustomAwesomeDialog(title: '¿Desea activar todos los súbmodulos del módulo \"${modulo.nombreModulo}\" para el '
                             'departamento de \"${department.nombre}\"?', desc: '', btnOkOnPress: () {
                           activarPermisos(modulo, department);
                         }, btnCancelOnPress: () {  },).showQuestion(context);
                       }else{
                         CustomAwesomeDialog(title: '¿Desea desactivar todos los súbmodulos del módulo \"${modulo.nombreModulo}\" para el '
                             'departamento de \"${department.nombre}\"?', desc: '', btnOkOnPress: () {
                           desactivarPermisos(modulo,department);
                         }, btnCancelOnPress: () {  },).showQuestion(context);
                       }
                     },
                   )
                 ]),
               ),
               expanded: Padding(
                 padding: const EdgeInsets.all(5.0),
                 child: Column(children: [..._buildSubModules(modulo, department),],),
               ),),
              const SizedBox(height: 5,),
           ],)
         );
       }
       return modules;
     }
  List<Widget> _buildSubModules(Modulo module,DepartamentoModels department){
       List<Widget> subModules = [];
       for(SubmoduloPermisos subModulo in module.submodulos){
         subModules.add(
           Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children:[
                 Expanded(
                   child: Text(subModulo.nombreSubmodulo, style: const TextStyle( fontWeight: FontWeight.bold ),),),
                 const SizedBox(),
                 Switch(
                   value: department.departamentoSubmodulos.any((element) => element.subModuloId == subModulo.submoduloId),
                   onChanged: (value) async {
                     if(value){
                       CustomAwesomeDialog(title: '¿Desea activar el súbmodulo \"${subModulo.nombreSubmodulo}\" para el '
                           'departamento de \"${department.nombre}\"?', desc: '', btnOkOnPress: () {
                         activarPermiso(subModulo, department);
                       }, btnCancelOnPress: () {  },).showQuestion(context);
                     }else{
                       CustomAwesomeDialog(title: '¿Desea desactivar el súbmodulo \"${subModulo.nombreSubmodulo}\" para el '
                           'departamento de \"${department.nombre}\"?', desc: '', btnOkOnPress: () {
                         desactivarPermiso(subModulo, department);
                       }, btnCancelOnPress: () {  },).showQuestion(context);
                     }
                   },
                 ),
               ]),
         );
       }
       return subModules;
     }
  Widget _lazyLoadIndicator( int n ){
List<Widget> buttonList = List.generate(n, (index) {
  return cardSkeleton(size.width);
});
 return Stack(children: [
  FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(children: [
          for(int i = 0; i<buttonList.length; i++)...[
            _myContainerSkeleton(),
            const SizedBox(width: 10,)
          ]
        ],),
      )
  ),
  Positioned(
    right: 0,
    bottom: 0,
    top: 0,
    child: CircleAvatar(
      backgroundColor: theme.colorScheme.secondary,
      radius: 20,
      child: IconButton(
        icon: Icon(IconLibrary.iconAdd, color: theme.colorScheme.onPrimary,),
        onPressed: (){},
      ),
    ),
  ),
],);
}
  Widget cardSkeleton(double width){
       return SizedBox(width: width, height: 85,child: Card(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
           color: theme.backgroundColor, borderOnForeground: true,
           child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
             child: Shimmer.fromColors(
               baseColor: theme.primaryColor,
               highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
               const Color.fromRGBO(46, 61, 68, 1),
               enabled: true,
               child: Container(margin: const EdgeInsets.all(3),decoration:
               BoxDecoration(
                 color: Colors.grey,
                 borderRadius: BorderRadius.circular(8),
               ),
               ),
             ),
           )
       ),);
     }
  Widget _myContainerSkeleton(){
       return Container(height: size.width>1200? 560: (selectedItemsAreas.isEmpty?560:490),
           width: 300,
           decoration: BoxDecoration(color: theme.primaryColor,
             borderRadius: const BorderRadius.all(Radius.circular(10)),
           ),
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
           child: Column(children: [
             SizedBox(width: 260,height: 40,child: Shimmer.fromColors(
               baseColor: theme.primaryColor,
               highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
               const Color.fromRGBO(46, 61, 68, 1),
               enabled: true,
               child: Container(margin: const EdgeInsets.all(3),decoration:
               BoxDecoration(
                 color: Colors.grey,
                 borderRadius: BorderRadius.circular(8),
               ),
               ),
             ),),
             Divider(color: theme.colorScheme.secondary,),
             SizedBox(height: size.width>1200? 460: (selectedItemsAreas.isEmpty?460:414),
               child: FadingEdgeScrollView.fromScrollView(
                 child: ListView.builder(
                   physics: const NeverScrollableScrollPhysics(),
                   controller: _skeletonController, itemCount: 15,
                   itemBuilder: (context, index){
                     return cardSkeleton(width);
                   },
                 ),
               ),)
           ],)
       );
     }
  Future <void>_getSubModulos() async {
       try {
         PermisoController subModuloController = PermisoController();
         listSubModulos = await subModuloController.getPermisoSubmodulos();
         print(listSubModulos.first.nombreSubmodulo);
         setState(() {

         });
       }catch(e){
         print(e);
       }
     }

  Future<void> getAreas() async {
    AreaController areaController = AreaController();
    listAreas2 = await areaController.getAreasSubModuloAgrupadas();
  }
  Future<void> _getModuloPermiso() async {
     PermisoController permisoController = PermisoController();
     listPermisos2 = await permisoController.getPermisoModulos();
  }
  Future<void> activarPermiso(SubmoduloPermisos subModulo,DepartamentoModels department) async{
    try{
      LoadingDialog.showLoadingDialog(context, Texts.activatingPermission);
      DepartamentoSubmodulo? save = await departamentoSubmoduloController.saveDepartamentoSubmodulo(DepartamentoSubmodulo(
        departamentoId: department.idDepartamento, subModuloId: subModulo.submoduloId,
      ));
      await Future.delayed(const Duration(milliseconds: 150), () {
        LoadingDialog.hideLoadingDialog(context);
      });
      if(save!= null){
        CustomAwesomeDialog(title: Texts.permissionActiveSuccess, desc: '',
          btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
        department.departamentoSubmodulos.add(save);
        setState(() {});
      }else{
        CustomAwesomeDialog(title: Texts.permissionActiveError, desc: 'Error inesperado. Contacte a soporte', btnOkOnPress: () {  },
          btnCancelOnPress: () {  },).showError(context);
      }
    }catch(e){
      await Future.delayed(const Duration(milliseconds: 150), () {
        LoadingDialog.hideLoadingDialog(context);
      });
      ConnectionExceptionHandler exceptionHandler = ConnectionExceptionHandler();
      String error = await exceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: Texts.permissionActiveError, desc: error, btnOkOnPress: () {  },
        btnCancelOnPress: () {  },).showError(context);
    }
  }
  Future<void> desactivarPermiso(SubmoduloPermisos subModulo,DepartamentoModels department) async {
    try{
      LoadingDialog.showLoadingDialog(context, Texts.deactivatingPermission);
      DepartamentoSubmodulo departamentoSubmodulo = department.departamentoSubmodulos.firstWhere((element) => element.subModuloId == subModulo.submoduloId
          && element.departamentoId == department.idDepartamento);
      if(departamentoSubmodulo.idDepartamentoSubmodulo!.isNotEmpty){
        bool delete = await departamentoSubmoduloController.deleteDepartamentoSubmodulo(departamentoSubmodulo.idDepartamentoSubmodulo!);
        await Future.delayed(const Duration(milliseconds: 150), () {
          LoadingDialog.hideLoadingDialog(context);
        });
        if(delete){
          CustomAwesomeDialog(title: Texts.permissionInactiveSuccess, desc: '',
            btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
          department.departamentoSubmodulos.remove(departamentoSubmodulo);
          setState(() {});
        }else{
          await Future.delayed(const Duration(milliseconds: 150), () {
            LoadingDialog.hideLoadingDialog(context);
          });
          CustomAwesomeDialog(title: Texts.permissionInactiveError, desc: 'Error inesperado. Contacte a soporte', btnOkOnPress: () {  },
            btnCancelOnPress: () {  },).showError(context);
        }
      }
    }catch(e){
      await Future.delayed(const Duration(milliseconds: 150), () {
        LoadingDialog.hideLoadingDialog(context);
      });
      ConnectionExceptionHandler exceptionHandler = ConnectionExceptionHandler();
      String error = await exceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: Texts.permissionInactiveError, desc: error, btnOkOnPress: () {  },
        btnCancelOnPress: () {  },).showError(context);
    }
  }
  Future<void> activarPermisos(Modulo modulo, DepartamentoModels department) async {
    try{
      LoadingDialog.showLoadingDialog(context, Texts.activatingPermissions);
      List<DepartamentoSubmodulo> save = await departamentoSubmoduloController.saveDepartamentoSubmodulos(
          department.idDepartamento!, modulo.idModulo
      );
      await Future.delayed(const Duration(milliseconds: 150), () {
        LoadingDialog.hideLoadingDialog(context);
      });
      if(save.isNotEmpty){
        CustomAwesomeDialog(title: Texts.permissionsActiveSuccess, desc: '',
          btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
        department.departamentoSubmodulos.removeWhere((element) => modulo.submodulos.any((element2) => element2.submoduloId == element.subModuloId));

        department.departamentoSubmodulos.addAll(save);
        setState(() {});
      }else{
        CustomAwesomeDialog(title: Texts.permissionsActiveError, desc: 'Error inesperado. Contacte a soporte', btnOkOnPress: () {  },
          btnCancelOnPress: () {  },).showError(context);
      }
    }catch(e){
      await Future.delayed(const Duration(milliseconds: 150), () {
        LoadingDialog.hideLoadingDialog(context);
      });
      ConnectionExceptionHandler exceptionHandler = ConnectionExceptionHandler();
      String error = await exceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: Texts.permissionActiveError, desc: error, btnOkOnPress: () {  },
        btnCancelOnPress: () {  },).showError(context);
    }
  }
  Future<void> desactivarPermisos(Modulo modulo, DepartamentoModels department) async {
       try{
         LoadingDialog.showLoadingDialog(context, Texts.deactivatingPermissions);
         bool save = await departamentoSubmoduloController.deleteDepartamentoModulo(
             department.idDepartamento!, modulo.idModulo);
         await Future.delayed(const Duration(milliseconds: 150), () {
           LoadingDialog.hideLoadingDialog(context);
         });
         if(save){
           CustomAwesomeDialog(title: Texts.permissionsInactiveSuccess, desc: '',
             btnOkOnPress: () {  }, btnCancelOnPress: () {  },).showSuccess(context);
           department.departamentoSubmodulos.removeWhere((element) => modulo.submodulos.any((element2) => element2.submoduloId == element.subModuloId));

           setState(() {});
         }else{
           CustomAwesomeDialog(title: Texts.permissionsInactiveError, desc: 'Error inesperado. Contacte a soporte', btnOkOnPress: () {  },
             btnCancelOnPress: () {  },).showError(context);
         }
       }catch(e){
         await Future.delayed(const Duration(milliseconds: 150), () {
           LoadingDialog.hideLoadingDialog(context);
         });
         ConnectionExceptionHandler exceptionHandler = ConnectionExceptionHandler();
         String error = await exceptionHandler.handleConnectionExceptionString(e);
         CustomAwesomeDialog(title: Texts.permissionActiveError, desc: error, btnOkOnPress: () {  },
           btnCancelOnPress: () {  },).showError(context);
       }
   }

  Future<void> actualizarPermiso(PermisoModels permiso, String newValue) async {
    try{
      PermisoController permisoController = PermisoController();
      UserPreferences userPreferences = UserPreferences();
      String userID = await userPreferences.getUsuarioID();
      bool update = await permisoController.updatePermiso(permiso.idPermiso, newValue, userID);
      if(update){
        CustomAwesomeDialog(title: Texts.permissionUpdateSuccess, desc: '', btnOkOnPress:(){},
          btnCancelOnPress:(){},).showSuccess(context);
        permiso.tipoUsuario = newValue;
        setState(() {});
      }else{
        CustomAwesomeDialog(title: Texts.permissionUpdateError,
          desc: 'Error inesperado. Contacte a soporte', btnOkOnPress: () {  },
          btnCancelOnPress: () {  },).showError(context);
      }
    }catch(e){
      ConnectionExceptionHandler exceptionHandler = ConnectionExceptionHandler();
      String error = await exceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: Texts.permissionUpdateError, desc: error, btnOkOnPress: () {  },
        btnCancelOnPress: () {  },).showError(context);
    }
  }
}







