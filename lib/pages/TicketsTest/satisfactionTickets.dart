import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:tickets/controllers/TicketController/SatisfactionController.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:rive/rive.dart' as rv;
import 'package:rive/rive.dart';

import '../../models/TicketsModels/satisfaction.dart';
import '../../shared/actions/handleException.dart';
import '../../shared/utils/texts.dart';
import '../../shared/widgets/Loading/loadingDialog.dart';
import '../../shared/widgets/Snackbars/customSnackBar.dart';
import '../../shared/widgets/dialogs/custom_awesome_dialog.dart';

class SatisfactionTicketsTest extends StatefulWidget {
  String id;
  SatisfactionTicketsTest({Key? key, required String this.id}) : super(key: key);

  @override
  _SatisfactionTicketsTestState createState() => _SatisfactionTicketsTestState();
}

class _SatisfactionTicketsTestState extends State<SatisfactionTicketsTest> {
  late Size size;
  late TabController tabController;
  final TextEditingController _commentController = TextEditingController();
  SMINumber? _input1;
  SMINumber? _input2;
  SMINumber? _input3;
  double raiting1 = 0;
  double raiting2 = 0;
  double raiting3 = 0;
  double storedRating1 = 0.0;
  double storedRating2 = 0.0;
  double storedRating3 = 0.0;

  final SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return LayoutBuilder(builder: (
      BuildContext context,
      BoxConstraints constraints,
    ) {
      return _mainSwiperBody();
    });
  }

  Widget _mainSwiperBody() {
    return Container(
      height: 500,
      child: Swiper(
        loop: false,
        itemCount: 4,
        physics: const BouncingScrollPhysics(),
        pagination: SwiperPagination(
          margin: const EdgeInsets.symmetric(vertical: 10),
          builder: DotSwiperPaginationBuilder(
            color: Colors.white,
            activeColor: Colors.black54,
          ),
        ),
        itemBuilder: (context, index) {
          return _swiperBody()[index];
        },
        controller: swiperController,
      ),
    );
  }

  List<Widget> _swiperBody() {
    return [
      _SatisfactionTicket(),
      _SatisfactionTicket2(),
      _SatisfactionTicket3(),
      _SatisfactionTicket4(),
    ];
  }

  Widget _SatisfactionTicket() {
    return Container(
      color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: ColorPalette.ticketsColor2,
            title: Text('Satisfacción de Tickets',
                style: TextStyle(color: Colors.white))),
        body: Container(
          color: ColorPalette.ticketsColor2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50), // Espacio entre el texto y las estrellas

                Text('Por favor, califica tu experiencia general',
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Deficiente',
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                    SizedBox(width: 14),
                    // Espacio entre el texto y las estrellas

                    Container(
                      height: 80,
                      width: 140,
                      child: RiveAnimation.asset(
                        "assets/stars.riv",
                        onInit: (art) {
                          print(raiting1);
                          _onRiveInit(art);
                        },
                      ),
                    ),

                    SizedBox(width: 14),
                    Text('Excelente',
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ],
                ),
                SizedBox(height: 150.0),
                Container(
                  width: 170,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.ticketsColor5,
                    ),
                    onPressed: () {
                      swiperController.next();
                    },
                    child: Text(
                      'Siguiente',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _SatisfactionTicket2() {
    return Container(
      color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: ColorPalette.ticketsColor2,
            title: Text('Satisfacción de Tickets',
                style: TextStyle(color: Colors.white))),
        body: Container(
          color: ColorPalette.ticketsColor2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50), // Espacio entre el texto y las estrellas

                Text('Por favor, califica tu experiencia general',
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Deficiente',
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                    SizedBox(width: 14),
                    // Espacio entre el texto y las estrellas

                    Container(
                      height: 80,
                      width: 140,
                      child: RiveAnimation.asset(
                        "assets/stars.riv",
                        onInit: (art) {
                          print(raiting2);
                          _onRiveInit2(art);
                        },
                      ),
                    ),

                    SizedBox(width: 14),
                    Text('Excelente',
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ],
                ),
                SizedBox(height: 150.0),
                Container(
                  width: 170,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.ticketsColor5,
                    ),
                    onPressed: () {
                      swiperController.next();
                    },
                    child: Text(
                      'Siguiente',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _SatisfactionTicket3() {
    return Container(
      height: 100,
      color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: ColorPalette.ticketsColor2,
          title: Text(
            'Satisfacción de Tickets',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          color: ColorPalette.ticketsColor2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50), // Espacio entre el texto y las estrellas

                Text(
                    'Por favor, califica que tan bien te resolvierón el problema',
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Deficiente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        )),
                    SizedBox(width: 14),
                    // Espacio entre el texto y las estrellas
                    Container(
                      height: 80,
                      width: 140,
                      child: RiveAnimation.asset(
                        "assets/stars.riv",
                        onInit: (art) {
                          _onRiveInit3(art);
                          size = MediaQuery.of(context).size;
                        },
                      ),
                    ),
                    SizedBox(width: 14),
                    // Espacio entre las estrellas y el texto
                    Text('Excelente',
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ],
                ),
                SizedBox(height: 150.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.ticketsColor5,
                        ),
                        onPressed: () {
                          swiperController.previous();
                        },
                        child: Text(
                          'Anterior',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 170,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.ticketsColor5,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          swiperController.next();
                        },
                        child: Text(
                          'Siguiente',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _SatisfactionTicket4() {
    return Container(
      height: 100,
      color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: ColorPalette.ticketsColor2,
          title: Text(
            'Satisfacción de Tickets',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          color: ColorPalette.ticketsColor2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50), // Espacio entre el texto y las estrellas

                Text('Ingresa algun comentario adicional',
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                SizedBox(height: 20.0),
                Container(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      floatingLabelStyle: TextStyle(
                        color: Colors.white,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors
                              .white, // Cambia esto al color que prefieras.
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .white, // Cambia esto al color que prefieras.
                        ),
                      ),
                      labelText: 'Ingresa un texto',
                      labelStyle:
                          TextStyle(color: Colors.white), // Añade esta línea
                    ),
                  ),
                ),

                SizedBox(height: 90.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.ticketsColor5,
                        ),
                        onPressed: () {
                          swiperController.previous();
                        },
                        child: Text(
                          'Anterior',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 170,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.ticketsColor5,
                        ),
                        onPressed: () async {
                          final satisfaction = SatisfactionModel(
                            calificacion_General: storedRating1.toInt(),
                            calificacion_Tiempo: storedRating2.toInt(),
                            calificacion_Calidad: storedRating3.toInt(),
                            Comentario: _commentController.text,
                            ticketsID: widget.id,
                          );
                          print(satisfaction.Comentario);
                          saveSatisfaction(satisfaction);
                        },
                        child: Text(
                          'Enviar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onRiveInit(Artboard art) {
    final controller =
        StateMachineController.fromArtboard(art, "State Machine 1");
    art.addController(controller!);
    _input1 = controller.findInput<double>("rating") as SMINumber;
    _input1!.change(raiting1);
    controller.isActiveChanged.addListener(() {
      if (controller.isActive) {

        setState(() {
          raiting1 = _input1!.value;
        });
        storedRating1 =
            raiting1;
        print('El valor actual de raiting 1 es: $storedRating1');
      }
    });

    updateRating1(raiting1);
  }

  _onRiveInit2(Artboard art) {
    final controller = StateMachineController.fromArtboard(art, "State Machine 1");
    if (controller != null) {
      art.addController(controller);
      _input2 = controller.findInput<double>("rating") as SMINumber;
      if (_input2 != null) {
        _input2!.change(raiting2);
        controller.isActiveChanged.addListener(() {
          if (controller.isActive) {
            setState(() {
              raiting2 = _input2!.value;
            });
            storedRating2 = raiting2;
            print('El valor actual de raiting 2 es: $storedRating2');
          }
        });
      }
      updateRating2(raiting2);
    }
  }

  _onRiveInit3(Artboard art) {
    final controller =
    StateMachineController.fromArtboard(art, "State Machine 1");
    art.addController(controller!);
    _input3 = controller.findInput<double>("rating") as SMINumber;
    _input3!.change(raiting3);
    controller.isActiveChanged.addListener(() {
      if (controller.isActive) {
        setState(() {
          raiting3 = _input3!.value;
        });
        storedRating3 =
            raiting3;
        print('El valor actual de raiting 3 es: $storedRating3');
      }
    });

    updateRating3(raiting3);
  }

  void updateRating1(double newRating) {
    setState(() {
      raiting1 = newRating;
    });
    if (_input1 != null) {
      _input1!.change(raiting1);
    }
  }

  void updateRating2(double newRating) {
    setState(() {
      raiting2 = newRating;
    });
    if (_input2 != null) {
      _input2!.change(raiting2);
    }
  }
  void updateRating3(double newRating) {
    setState(() {
      raiting3 = newRating;
    });
    if (_input3 != null) {
      _input3!.change(raiting3);
    }
  }

  Future<void> saveSatisfaction(SatisfactionModel satisfaction) async {
    try{
      LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      final satisfactionController = SatisfactionController();
      bool save = await satisfactionController.saveSatisfaction(satisfaction);
      if(save){
        CustomAwesomeDialog(title: Texts.addSuccess, desc: '',
            btnOkOnPress: () {}, btnCancelOnPress: () {}).showSuccess(context);
      }else{
        CustomAwesomeDialog(title: Texts.errorSavingData, desc: 'Error al guardar el ticket',
            btnOkOnPress: () {},
            btnCancelOnPress: () {}).showError(context);
      }
    }catch(e){
      CustomAwesomeDialog(title: Texts.errorSavingData, desc: 'Error al guardar el ticket $e',
          btnOkOnPress: () {},
          btnCancelOnPress: () {}).showError(context);
    }


    await Future.delayed(const Duration(milliseconds: 2500), () async {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.of(context).pop();
    });
  }

}
