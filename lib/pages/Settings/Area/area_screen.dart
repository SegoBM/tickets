import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/departamentoController.dart';
import 'package:tickets/models/ConfigModels/departamento.dart';
import 'package:tickets/models/ConfigModels/puesto.dart';
import 'package:tickets/pages/Settings/Area/area_add_screen.dart';
import 'package:tickets/pages/Settings/Area/department/departament_add_wArea_screen.dart';
import 'package:tickets/pages/Settings/Area/department/job/job_screen.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/buttons/custom_dropdown_button.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controllers/ConfigControllers/areaController.dart';
import '../../../models/ConfigModels/area.dart';
import '../../../models/ConfigModels/usuarioPermiso.dart';
import '../../../shared/utils/user_preferences.dart';
import '../../../shared/widgets/Loading/loadingDialog.dart';
import '../../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../../shared/widgets/dialogs/customAlertDialog.dart';
import '../../../shared/widgets/error/customNoData.dart';

class AreasScreen extends StatefulWidget {
  static String id = 'AreasScreen';
  List<UsuarioPermisoModels> listUsuarioPermisos = [];
  BuildContext context;
  AreasScreen({super.key, required this.listUsuarioPermisos, required this.context});

  @override
  _AreasScreenState createState() => _AreasScreenState();
}

class _AreasScreenState extends State<AreasScreen> {
  final GlobalKey _areaKey = GlobalKey(); late Size size; late ThemeData theme;
  final FocusNode _focusNode = FocusNode();
  double _opacity = 1.0, width = 0; bool mostrarFiltro = false;
  final _searchController = TextEditingController(), _areaController = TextEditingController(),
      _departmentController = TextEditingController();
  final ScrollController _scrollController = ScrollController(), scrollController = ScrollController();

  List<String> selectAreas = [], selectDepartments = [""], selectedItemsAreas = [], selectedItemsDepartments= [];
  List<AreaModels> listArea = [], listAreasTemp = [];
  List<ScrollController> scrollControllers = [];
  bool addAreaP = false, editAreaP = false, deleteAreaP = false, _isLoading = true;
  @override
  void initState() {
    _getAreas();
    getPermisos();
    const timeLimit = Duration(seconds: 20);
    Timer(timeLimit, () {
      if(listArea.isEmpty){
        setState(() {
          _isLoading = false;
        });
      }else{
        _isLoading = false;
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; theme = Theme.of(context); width = size.width-350;
    return PressedKeyListener(keyActions: {
      LogicalKeyboardKey.f4: () {addArea();},
      LogicalKeyboardKey.escape : () async {Navigator.of(context).pushNamed('homeMenuScreen');},
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey: _areaKey,
    child: Scaffold(
      appBar: size.width > 600? MyCustomAppBarDesktop(title:"Areas",context: widget.context,backButton: false) : null,
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: size.width> 600? _bodyLandscape() : _bodyPortrait(),
        ),
      ),
    ));
  }
  Widget _bodyLandscape(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if(size.width<1200)...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            Row(children: _filtros(),),
            const SizedBox(width: 5,),
          ],)
        ]else...[
          Row(children: [
            _filtros()[0],
            const SizedBox(width: 5,),
            _filtros()[2],
          ],),
          const SizedBox(height: 5,),
          Row(children: [
            _filtros()[4],
          ],),
        ],
        _body(),
    ]);
  }
  Widget _body(){
    return SizedBox(height:size.height-118,
        child: FutureBuilder<List<AreaModels>>(future: _getDatos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: _buildLoadingIndicator(10));
            } else {
              final listAreas = snapshot.data ?? [];
              if (listAreas.isNotEmpty) {
                return Stack(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.only(right: 30), child: RefreshIndicator(
                      onRefresh: () async {await _getAreas();},
                      child: FadingEdgeScrollView.fromScrollView(
                      child: ListView.builder(controller: _scrollController,
                        scrollDirection: Axis.horizontal, itemCount: listAreas.length,
                        itemBuilder: (context, index) {
                          return Row(children: [
                            _myContainer(listAreas[index], scrollControllers[index]),
                            const SizedBox(width: 5,),
                          ],);
                        },
                      ),
                    ),),),
                    Positioned(right: 0, bottom: 0, top: 0,
                      child: CircleAvatar(backgroundColor: theme.colorScheme.secondary, radius: 20,
                        child: IconButton(
                          icon: Icon(IconLibrary.iconAdd, color: theme.colorScheme.onPrimary,),
                          onPressed: (){addArea();},
                        ),
                      ),
                    ),
                  ],
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
        ));
  }
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
      Positioned(right: 0, bottom: 0, top: 0,
        child: CircleAvatar(backgroundColor: theme.colorScheme.secondary, radius: 20,
          child: IconButton(
            icon: Icon(IconLibrary.iconAdd, color: theme.colorScheme.onPrimary,),
            onPressed: (){},
          ),
        ),
      ),
    ],);
  }
  Widget cardEsqueleto(double width){
    return SizedBox(width: width, height: 85,child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
        color: theme.backgroundColor, borderOnForeground: true,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Shimmer.fromColors(baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1), enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),),
            ),
          ),
        )
    ),);
  }
  Widget _myContainer(AreaModels areaModels, ScrollController scrollController){
    return Container(height:size.height-120, width: 300,
        decoration: BoxDecoration(color: theme.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            const SizedBox(),
            GestureDetector(child: Text(areaModels.nombre, style: TextStyle(color: theme.colorScheme.onPrimary,
                fontSize: 18, fontWeight: FontWeight.bold),),onTap: (){editArea(areaModels);},
              onLongPress: (){
                if(deleteAreaP){
                  deleteArea(areaModels);
                }else{
                  CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
                }
              },),
            IconButton(onPressed: (){
                if(addAreaP){
                  addDepartment(areaModels);
                }else{
                  CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
                }
              }, icon: const Icon(IconLibrary.iconAdd),
              hoverColor: theme.colorScheme.background, style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
                padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
              ),
            ),

          ],),
          Divider(color: theme.colorScheme.secondary,),
          SizedBox(height: size.height-212,
            child:Scrollbar(thumbVisibility: true,controller: scrollController,child:  FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(
                controller: scrollController, itemCount: areaModels.departamentos!.length,
                itemBuilder: (context, index){
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _card(areaModels.departamentos![index]),);
                },
              ),
            ),),)
        ],)
    );
  }
  Widget _myContainerEsqueleto(){
    return Container(height: size.height-120, width: 300,
        decoration: BoxDecoration(color: theme.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(children: [
          SizedBox(width: 260,height: 40,child: Shimmer.fromColors(baseColor: theme.primaryColor,
            highlightColor: theme.brightness == Brightness.light? const Color.fromRGBO(195, 193, 186, 1.0):
            const Color.fromRGBO(46, 61, 68, 1), enabled: true,
            child: Container(margin: const EdgeInsets.all(3),decoration:
            BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8),),
            ),
          ),),
          Divider(color: theme.colorScheme.secondary,),
          SizedBox(height: size.height-210,
            child: FadingEdgeScrollView.fromScrollView(
              child: ListView.builder(physics: const NeverScrollableScrollPhysics(),
                controller: scrollController, itemCount: 15,
                itemBuilder: (context, index){
                  return cardEsqueleto(width);
                },
              ),
            ),)
        ],)
    );
  }
  Widget _bodyPortrait(){
    return const Column(children: [Text("data")],);
  }
  List<Widget> _filtros(){
    return [
      SizedBox(width: 250, child: MyTextfieldIcon(labelText: Texts.search, textController: _searchController,
          suffixIcon: const Icon(IconLibrary.iconSearch),floatingLabelStyle: TextStyle(color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold), backgroundColor: theme.colorScheme.secondary,
        colorLine: theme.colorScheme.primary, focusNode: _focusNode,
        onChanged: (value){
          aplicarFiltro();
          setState(() {
            FocusScope.of(context).requestFocus(_focusNode);
          });
        },),),
      const SizedBox(width: 5,),
      Container(padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 8),
        width: 220,decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
        child: CustomDropdownButton(theme: theme,context: context,items: selectAreas,selectedItems: selectedItemsAreas,
          setState: setState, text: "Selecciona una(s) area(s)",
          onTap: (){aplicarFiltro();},
        ),),
      const SizedBox(width: 5,),
      if(mostrarFiltro)...[
        AnimatedOpacity(opacity: _opacity, duration: const Duration(milliseconds: 400),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 8),
          width: 220,decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
          child: CustomDropdownButton(theme: theme,context: context,items: selectDepartments,selectedItems: selectedItemsDepartments,
            setState: setState, text: "Selecciona algun(os) departamento(s)",
            onTap: (){
              listAreasTemp =  listArea.map((area) => AreaModels(
                nombre: area.nombre, idArea: area.idArea,
                departamentos: area.departamentos!.map((dep) => DepartamentoModels(
                  idDepartamento: dep.idDepartamento, nombre: dep.nombre,
                  puestos: dep.puestos!.map((puesto) => PuestoModels(
                    idPuesto: puesto.idPuesto, nombre: puesto.nombre,
                    // Asegúrate de copiar también las demás propiedades del puesto si las hay
                  )).toList(),
                  // Asegúrate de copiar también las demás propiedades del departamento si las hay
                )).toList(),
                // Asegúrate de copiar también las demás propiedades de la área si las hay
              )).toList();
              if(selectedItemsAreas.isNotEmpty){
                listAreasTemp = listAreasTemp.where((area) =>
                    selectedItemsAreas.contains(area.nombre)).toList();
                if(selectedItemsDepartments.isNotEmpty){
                  for(int i = 0; i<listAreasTemp.length; i++){
                    listAreasTemp[i].departamentos = listAreasTemp[i].departamentos!.where((departamento) =>
                        selectedItemsDepartments.contains(departamento.nombre)).toList();
                  }
                }
              }
            },
          ),),
        ),
      ],
      const SizedBox(width: 5,),
    ];
  }
  Widget _card(DepartamentoModels departamento){
    return GestureDetector(onDoubleTap: () async {
      if(editAreaP){
        for(int i = 0; i<listArea.length; i++){
          for(int j = 0; j<listArea[i].departamentos!.length; j++){
            if(listArea[i].departamentos![j].idDepartamento == departamento.idDepartamento){
              await myShowDialog(JobScreen(departamentoModels: listArea[i].departamentos![j],), context, size.width*0.40);
              break;
            }
          }
        }
      }else{
        CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
      }
    },
      child: MySwipeTileCard(horizontalPadding: 0,
        colorBasico: theme.colorScheme.background, iconColor: theme.colorScheme.onPrimary,
        containerB: ListTile(
          title: const Text('DEPARTAMENTO', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15 ),),
          subtitle: Text((departamento.nombre), style: const TextStyle( fontWeight: FontWeight.normal, fontSize: 13),),
        ),
        onTapRL: (){
          if(deleteAreaP){
            if(listArea.firstWhere((element) => element.departamentos!.any((dep) =>
            dep.nombre == departamento.nombre)).departamentos!.length == 1) {
              CustomSnackBar.showWarningSnackBar(context, Texts.errorDeleteMin);
            }else{
              deleteDepartment(departamento);
            }
          }else{
            CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
          }
        },
        onTapLR: (){
          if(editAreaP){
            editDepartment(departamento);
          }else{
            CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
          }
        },
      ),
    );
  }
  void resetAreaTemp(){
    listAreasTemp =  listArea.map((area) => AreaModels(
      nombre: area.nombre, idArea: area.idArea,
      departamentos: area.departamentos!.map((dep) => DepartamentoModels(
        idDepartamento: dep.idDepartamento, nombre: dep.nombre,
        puestos: dep.puestos!.map((puesto) => PuestoModels(
          idPuesto: puesto.idPuesto, nombre: puesto.nombre,
          // Asegúrate de copiar también las demás propiedades del puesto si las hay
        )).toList(),
        // Asegúrate de copiar también las demás propiedades del departamento si las hay
      )).toList(),
      // Asegúrate de copiar también las demás propiedades de la área si las hay
    )).toList();
  }
  void aplicarFiltro(){
    resetAreaTemp();
    if(selectedItemsAreas.isNotEmpty){
      if(!mostrarFiltro){
        _opacity = 1;
        mostrarFiltro = true;
      }
      selectDepartments = [];
      selectedItemsDepartments = [];
      for(int i = 0; i<listArea.length; i++){
        for(int j = 0; j<selectedItemsAreas.length; j++){
          if(listArea[i].nombre == selectedItemsAreas[j]){
            selectDepartments.addAll(listArea[i].departamentos!.map((e) => e.nombre).toList());
          }
        }
      }
      if(selectedItemsAreas.isNotEmpty){
        listAreasTemp = listAreasTemp.where((area) =>
            selectedItemsAreas.contains(area.nombre)).toList();
      }
    }else{
      _opacity = 0;
      Future.delayed(const Duration(milliseconds: 400), (){
        if(mostrarFiltro){
          mostrarFiltro = false;
          setState(() {});
        }
      });
    }
    if(_searchController.text.isNotEmpty){
      listAreasTemp = listAreasTemp.map((area) => AreaModels(
        nombre: area.nombre, idArea: area.idArea,
        departamentos: area.departamentos!.where((dep) => dep.nombre.toLowerCase().
        contains(_searchController.text.toLowerCase())).toList(),
      )).toList();
      listAreasTemp = listAreasTemp.where((area) => area.departamentos!.isNotEmpty).toList();
    }
    setState(() {});
  }
  Future<void> addArea() async {
    if(addAreaP){
      await myShowDialog(AreaAddScreen(), context, size.width*0.40);
      _getAreas();
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  void editArea(AreaModels area){
    if(editAreaP){
      _areaController.text = area.nombre;
      showDialog(context: context, barrierDismissible: false, builder: (BuildContext context2){
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState)
            {return ScaffoldMessenger(child: Builder(
                builder: (context) => Scaffold(backgroundColor: Colors.transparent,
                    body: alertDialogEditArea(context, area)
                )
            ));}
        );
      });
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  void deleteArea(AreaModels area){
    if(deleteAreaP){
      if(listArea.length == 1) {
        CustomSnackBar.showWarningSnackBar(context, Texts.errorDeleteMin);
      }else{
        CustomAwesomeDialog(title: Texts.askDeleteConfirm,
            desc: 'Area: ${area.nombre}', btnOkOnPress: () async {
              try{
                LoadingDialog.showLoadingDialog(context, Texts.savingData);
                AreaController areaController = AreaController();
                bool delete = await areaController.deleteArea(area.idArea!);
                LoadingDialog.hideLoadingDialog(context);
                if(delete){
                  CustomAwesomeDialog(title: Texts.deleteSuccess,
                      desc: '', btnOkOnPress: (){},
                      btnCancelOnPress: (){}).showSuccess(context);
                  Future.delayed(const Duration(milliseconds: 2500), (){
                    selectedItemsAreas.remove(area.nombre);
                    listArea.remove(area);
                    listAreasTemp.remove(area);
                    setState(() {});
                  });
                }else{
                  LoadingDialog.hideLoadingDialog(context);
                  CustomAwesomeDialog(title: Texts.errorDeleteRegistry, btnOkOnPress: (){},
                      desc: 'Error inesperado. Contacte a soporte', btnCancelOnPress: (){}).showError(context);
                }
              }catch (e){
                ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
                String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
                CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: error,
                  btnOkOnPress: (){}, btnCancelOnPress: () {},).showError(context);
              }
            }, btnCancelOnPress: (){}).showQuestion(context);
      }
    }else{
      CustomSnackBar.showWarningSnackBar(context, Texts.errorPermissions);
    }
  }
  Widget alertDialogEditArea(BuildContext context, AreaModels area){
    return CustomAlertDialog(title: "Editar Area",
      content: Padding(padding: const EdgeInsets.all(1),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              MyTextfieldIcon(labelText: "Area", backgroundColor: theme.colorScheme.background,
                labelStyle: const TextStyle(fontSize: 15,), toUpperCase: true,
                textController: _areaController, suffixIcon: const Icon(IconLibrary.iconBusiness,),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      onPressedOk: (){
        if(_areaController.text.isNotEmpty){
          if(_areaController.text.length > 20) {
            CustomSnackBar.showInfoSnackBar(context,
                "El nombre del area debe tener menos de 20 caracteres");
          }else{
            CustomAwesomeDialog(title: Texts.askEditConfirm, desc: 'Area: ${area.nombre}',
                btnOkOnPress: () async {
              try{
                LoadingDialog.showLoadingDialog(context, Texts.savingData);
                AreaController areaController = AreaController();
                String empresaID =await  UserPreferences().getEmpresaId();
                bool check = await areaController.checkArea(_areaController.text.trim(), empresaID);
                if(check){
                  AreaModels areaModels = AreaModels(nombre: _areaController.text.trim(), idArea: area.idArea,);

                  bool edit = await areaController.updateArea(area.idArea!, areaModels);
                  LoadingDialog.hideLoadingDialog(context);
                  if(edit) {
                    CustomAwesomeDialog(title: Texts.editSuccess, desc: '', btnOkOnPress: () {},
                        btnCancelOnPress: () {}).showSuccess(context);
                    Future.delayed(const Duration(milliseconds: 2500), () {
                      for(int i = 0; i<listArea.length; i++){
                        if(listArea[i].idArea == area.idArea){
                          listArea[i].nombre = _areaController.text;
                          setState(() {});
                          break;
                        }
                      }
                      area.nombre = _areaController.text;
                      _areaController.text = ""; Navigator.of(context).pop();
                      setState(() {});
                    });
                  }else{
                    CustomAwesomeDialog(title: Texts.errorEditRegistry, desc: Texts.errorUnexpected,
                        btnOkOnPress: (){}, btnCancelOnPress: (){}).showError(context);
                  }
                }else{
                  LoadingDialog.hideLoadingDialog(context);
                  CustomAwesomeDialog(title: Texts.errorEditRegistry, desc: Texts.errorNameDepartment,
                      btnOkOnPress: (){}, btnCancelOnPress: (){}).showError(context);
                }
              }catch (e){
                LoadingDialog.hideLoadingDialog(context);
                ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
                String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
                CustomAwesomeDialog(title: Texts.errorEditRegistry,
                  desc: error, btnOkOnPress: (){}, btnCancelOnPress: (){},).showError(context);
              }
            }, btnCancelOnPress: (){}).showQuestion(context);
          }
        }else{
          CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
        }
      },
    );
  }

  Future<void> addDepartment(AreaModels area) async {
    await myShowDialog(DepartamentoAddWAreaScreen(areaModels: area,), context, size.width*0.40);
    _getAreas();
  }
  void editDepartment(DepartamentoModels departamento){
    _departmentController.text = departamento.nombre;
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context2){
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState)
          {return ScaffoldMessenger(child: Builder(
              builder: (context) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: alertDialogEditDepartment(context, departamento)
              )
          ));}
      );
    });
  }
  void deleteDepartment(DepartamentoModels departamento){
    CustomAwesomeDialog(title: Texts.askDeleteConfirm,
        desc: 'Departamento: ${departamento.nombre}', btnOkOnPress: () async {
          LoadingDialog.showLoadingDialog(context, Texts.savingData);
          DepartamentoController departamentoController = DepartamentoController();
          bool delete = await departamentoController.deleteDepartamento(departamento.idDepartamento!);
          LoadingDialog.hideLoadingDialog(context);
          if(delete){
            CustomAwesomeDialog(title: Texts.deleteSuccess, desc: '',
                btnOkOnPress: (){}, btnCancelOnPress: (){}).showSuccess(context);
            Future.delayed(const Duration(milliseconds: 2500), (){
              selectedItemsDepartments.remove(departamento.nombre);
              for(int i = 0; i < listArea.length; i++){
                for(int j = 0; j < listArea[i].departamentos!.length; j++){
                  if(listArea[i].departamentos![j].idDepartamento == departamento.idDepartamento){
                    listArea[i].departamentos!.removeAt(j);
                    setState(() {});
                    break;
                  }
                }
              }
              for(int i = 0; i < listAreasTemp.length; i++){
                for(int j = 0; j < listAreasTemp[i].departamentos!.length; j++){
                  if(listAreasTemp[i].departamentos![j].idDepartamento == departamento.idDepartamento){
                    listAreasTemp[i].departamentos!.removeAt(j);
                    setState(() {});
                    break;
                  }
                }
              }
            });

          }else{
            CustomAwesomeDialog(title: Texts.errorDeleteRegistry, desc: Texts.errorUnexpected,
                btnOkOnPress: (){}, btnCancelOnPress: (){}).showError(context);
          }
      }, btnCancelOnPress: (){}).showQuestion(context);
  }
  Widget alertDialogEditDepartment(BuildContext context, DepartamentoModels departamento){
    return CustomAlertDialog(title: "Editar Departamento",
      content: Padding(padding: const EdgeInsets.all(1),
        child: Form(
          child: Column(
            children: [
              const SizedBox(height: 15,),
              MyTextfieldIcon(labelText: "Departamento", backgroundColor: theme.colorScheme.background,
                labelStyle: const TextStyle(fontSize: 15,), toUpperCase: true,
                textController: _departmentController,
                suffixIcon: const Icon(IconLibrary.iconBusiness,)),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      onPressedOk: (){
        if(_departmentController.text.isNotEmpty){
          if(_departmentController.text.length > 50){
            CustomSnackBar.showInfoSnackBar(context, "El nombre del departamento debe tener menos de 50 caracteres");
          }else{
            CustomAwesomeDialog(title: Texts.askEditConfirm,
                desc: 'Departamento: ${departamento.nombre}',
                btnOkOnPress: () async {
                  DepartamentoController departamentoController = DepartamentoController();
                  String empresaID =await  UserPreferences().getEmpresaId();
                  bool check = await departamentoController.checkDepartamento(_departmentController.text.trim(), empresaID);
                  if(check){
                    LoadingDialog.showLoadingDialog(context, Texts.savingData);
                    String areaId = "";
                    for(int i = 0; i<listArea.length; i++){
                      for(int j = 0; j<listArea[i].departamentos!.length; j++){
                        if(listArea[i].departamentos![j].idDepartamento == departamento.idDepartamento){
                          areaId = listArea[i].idArea!;
                        }
                      }
                    }
                    DepartamentoModels departamentoModels = DepartamentoModels(
                      idDepartamento: departamento.idDepartamento,
                      nombre: _departmentController.text.trim(),
                      areaId: areaId,
                    );
                    DepartamentoController departamentoController = DepartamentoController();
                    bool update = await departamentoController.updateDepartamento(departamento.idDepartamento!, departamentoModels);
                    LoadingDialog.hideLoadingDialog(context);
                    if(update){
                      CustomAwesomeDialog(title: Texts.editSuccess, desc: '', btnOkOnPress: (){},
                          btnCancelOnPress: (){}).showSuccess(context);
                      Future.delayed(const Duration(milliseconds: 2500), (){
                        for(int i = 0; i<listArea.length; i++){
                          for(int j = 0; j<listArea[i].departamentos!.length; j++){
                            if(listArea[i].departamentos![j].idDepartamento == departamento.idDepartamento){
                              listArea[i].departamentos![j].nombre = _departmentController.text.trim();
                              setState(() {});
                              break;
                            }
                          }
                        }
                        departamento.nombre = _departmentController.text.trim();
                        _departmentController.text = "";
                        Navigator.of(context).pop();
                      });
                    }
                  }else{
                    LoadingDialog.hideLoadingDialog(context);
                    CustomAwesomeDialog(title: Texts.errorEditRegistry, desc: Texts.errorNameDepartment,
                        btnOkOnPress: (){}, btnCancelOnPress: (){}).showError(context);
                  }
                }, btnCancelOnPress: (){}).showQuestion(context);
          }
        }else{
          CustomSnackBar.showInfoSnackBar(context, Texts.completeError);
        }
      },
    );
  }
  Future<List<AreaModels>> _getAreas() async {
    List<AreaModels> listAreas = [];
    try {
      AreaController areaController = AreaController();
      listAreas = await areaController.getAreasAgrupadas();
      scrollControllers = [];
      for(int i = 0; i<listAreas.length; i++){
        scrollControllers.add(ScrollController());
      }
      selectAreas = listAreas.map((e) => e.nombre).toList();
      listArea = listAreas.map((area) => AreaModels(
        nombre: area.nombre,
        idArea: area.idArea,
        departamentos: area.departamentos!.map((dep) => DepartamentoModels(
          idDepartamento: dep.idDepartamento,
          nombre: dep.nombre,
          puestos: dep.puestos!.map((puesto) => PuestoModels(
            idPuesto: puesto.idPuesto,
            nombre: puesto.nombre,
            // Asegúrate de copiar también las demás propiedades del puesto si las hay
          )).toList(),
          // Asegúrate de copiar también las demás propiedades del departamento si las hay
        )).toList(),
        // Asegúrate de copiar también las demás propiedades de la área si las hay
      )).toList();

      listAreasTemp = listAreas.map((area) => AreaModels(
        nombre: area.nombre,
        idArea: area.idArea,
        departamentos: area.departamentos!.map((dep) => DepartamentoModels(
          idDepartamento: dep.idDepartamento,
          nombre: dep.nombre,
          puestos: dep.puestos!.map((puesto) => PuestoModels(
            idPuesto: puesto.idPuesto,
            nombre: puesto.nombre,
            // Asegúrate de copiar también las demás propiedades del puesto si las hay
          )).toList(),
          // Asegúrate de copiar también las demás propiedades del departamento si las hay
        )).toList(),
        // Asegúrate de copiar también las demás propiedades de la área si las hay
      )).toList();

      setState(() {});
    } catch (e) {
      print('Error al obtener area: $e');
    }
    return listAreas;
  }
  Future<List<AreaModels>> _getDatos() async {
    try {
      return listAreasTemp;
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }

  void getPermisos() {
    List<UsuarioPermisoModels> listUsuarioPermisos = widget.listUsuarioPermisos;
    for(int i = 0; i < listUsuarioPermisos.length; i++) {
      if (listUsuarioPermisos[i].permisoId == Texts.permissionsAreaAdd) {
        addAreaP = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsAreaEdit){
        editAreaP = true;
      }else if(listUsuarioPermisos[i].permisoId == Texts.permissionsAreaDelete) {
        deleteAreaP = true;
      }
    }
  }
}