import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:tickets/controllers/TicketController/SatisfactionController.dart';
import 'package:tickets/pages/Tickets/CustomeAwesomeDialogTickets.dart';
import 'package:tickets/pages/Tickets/loadingDialogTickets.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:rive/rive.dart';
import '../../models/TicketsModels/satisfaction.dart';
import '../../shared/utils/texts.dart';
class SatisfactionTickets extends StatefulWidget {
  String id;
  SatisfactionTickets({Key? key, required String this.id}) : super(key: key);

  @override
  _SatisfactionTicketsState createState() => _SatisfactionTicketsState();
}

class _SatisfactionTicketsState extends State<SatisfactionTickets> {
  late Size size;
  late TabController tabController;
  final TextEditingController _commentController = TextEditingController();
  SMINumber? _input1, _input2, _input3;
  double raiting1 = 0, raiting2 = 0, raiting3 = 0, storedRating1 = 0.0, storedRating2 = 0.0, storedRating3 = 0.0;

  final SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return size.width > 500 ? _mainSwiperBody() : bodyMobile();
  }

  Widget _mainSwiperBody() {
    return SizedBox(height: 350,
      child: Swiper(loop: false,containerHeight: 100, itemCount: 4, physics: const BouncingScrollPhysics(),
        pagination: const SwiperPagination(margin: EdgeInsets.symmetric(vertical: 10),
          builder: DotSwiperPaginationBuilder(color: Colors.white, activeColor: Colors.black54,),
        ),
        itemBuilder: (context, index) {return _swiperBody()[index];},
        controller: swiperController,
      ),
    );
  }

  Widget bodyMobile(){
    return Scaffold(backgroundColor: ColorPalette.ticketsColor2,
        body: Column(mainAxisAlignment: MainAxisAlignment.center,children: [_mainSwiperBody()],));
  }

  List<Widget> _swiperBody() {
    return [
      satisfactionTicket(),
      satisfactionTicket2(),
      satisfactionTicket3(),
      satisfactionTicket4(),
    ];
  }

  Widget satisfactionTicket() {
    return Container(color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(centerTitle: true, automaticallyImplyLeading: false,
            backgroundColor: ColorPalette.ticketsColor2,
            title: const Text(Texts.ticketSurvey, style: TextStyle(color: Colors.white))),
        body: Container(color: ColorPalette.ticketsColor2,
          child: Padding(padding: const EdgeInsets.all(16.0),
            child: Column(children: <Widget>[
                const SizedBox(height: 10), // Espacio entre el texto y las estrellas
                const Text(Texts.ticketGeneralExperience,
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                const SizedBox(height: 20.0),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(Texts.ticketDeficient, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                    const SizedBox(width: 14),
                    // Espacio entre el texto y las estrellas
                    SizedBox(height: 50, width: 140,
                      child: RiveAnimation.asset("assets/stars.riv",
                        onInit: (art) {
                          print(raiting1);
                          _onRiveInit(art);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(Texts.ticketExcellent, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(width: 170, height: 40,
                  child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.ticketsColor5,),
                    onPressed: () {swiperController.next();},
                    child: const Text('Siguiente', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget satisfactionTicket2() {
    return Container(color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(centerTitle: true, automaticallyImplyLeading: false,
            backgroundColor: ColorPalette.ticketsColor2,
            title: const Text(Texts.ticketSurvey, style: TextStyle(color: Colors.white))),
        body: Container(color: ColorPalette.ticketsColor2,
          child: Padding(padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10), // Espacio entre el texto y las estrellas
                const Text(Texts.ticketTimeExperience,
                    style: TextStyle(fontSize: 18.0, color: Colors.white)),
                const SizedBox(height: 20.0),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(Texts.ticketDeficient, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                    const SizedBox(width: 14),
                    // Espacio entre el texto y las estrellas
                    SizedBox(height: 50, width: 140,
                      child: RiveAnimation.asset("assets/stars.riv",
                        onInit: (art) {
                          print(raiting2);
                          _onRiveInit2(art);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(Texts.ticketExcellent, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ],
                ),
                const SizedBox(height: 20.0),

                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 170, height: 40,
                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.ticketsColor5,
                      ),
                        onPressed: () {swiperController.previous();},
                        child: const Text('Anterior', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: 170, height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.ticketsColor5,
                              foregroundColor: Colors.white),
                          onPressed: () {swiperController.next();},
                          child: const Text('Siguiente', style: TextStyle(color: Colors.white),)
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

  Widget satisfactionTicket3() {
    return Container(height: 100, color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(centerTitle: true, automaticallyImplyLeading: false,
          backgroundColor: ColorPalette.ticketsColor2,
          title: const Text(Texts.ticketSurvey, style: TextStyle(color: Colors.white),),
        ),
        body: Container(color: ColorPalette.ticketsColor2,
          child: Padding(padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10), // Espacio entre el texto y las estrellas
                const Text(Texts.ticketQualityExperience,
                    style: TextStyle(fontSize: 18.0, color: Colors.white), textAlign: TextAlign.center,),
                const SizedBox(height: 20.0),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(Texts.ticketDeficient, style: TextStyle(color: Colors.white,
                          fontSize: 18.0,)),
                    const SizedBox(width: 14),
                    // Espacio entre el texto y las estrellas
                    SizedBox(height: 50, width: 140,
                      child: RiveAnimation.asset("assets/stars.riv",
                        onInit: (art) {
                          print(raiting3);
                          _onRiveInit3(art);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Espacio entre las estrellas y el texto
                    const Text(Texts.ticketExcellent, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 170, height: 40,
                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.ticketsColor5,
                        ),
                        onPressed: () {swiperController.previous();},
                        child: const Text('Anterior', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: 170, height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.ticketsColor5,
                            foregroundColor: Colors.white),
                        onPressed: () {swiperController.next();},
                        child: const Text('Siguiente', style: TextStyle(color: Colors.white),)
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

  Widget satisfactionTicket4() {
    return Container(height: 100, color: ColorPalette.ticketsColor2,
      child: Scaffold(
        appBar: AppBar(centerTitle: true, automaticallyImplyLeading: false,
          backgroundColor: ColorPalette.ticketsColor2,
          title: const Text(Texts.ticketSurvey, style: TextStyle(color: Colors.white),),
        ),
        body: Container(color: ColorPalette.ticketsColor2,
          child: Padding(padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10), // Espacio entre el texto y las estrellas
                const Text(Texts.ticketComment, style: TextStyle(fontSize: 18.0, color: Colors.white)),
                const SizedBox(height: 10.0),
                TextField(controller: _commentController,
                  style: const TextStyle(color: Colors.white), maxLines: 3,
                  decoration: InputDecoration(
                    floatingLabelStyle: const TextStyle(color: Colors.white,),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    labelText: 'Ingresa un texto',
                    labelStyle: const TextStyle(color: Colors.white), // Añade esta línea
                  ),
                ),

                const SizedBox(height: 10.0),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 170, height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.ticketsColor5,
                        ),
                        onPressed: () {swiperController.previous();},
                        child: const Text('Anterior', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: 170, height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.ticketsColor5,),
                        onPressed: () async {
                          if(storedRating1.toInt() != 0 && storedRating2.toInt() != 0 && storedRating3.toInt() != 0){
                            final satisfaction = SatisfactionModel(
                              calificacion_General: storedRating1.toInt(),
                              calificacion_Tiempo: storedRating2.toInt(),
                              calificacion_Calidad: storedRating3.toInt(),
                              Comentario: _commentController.text,
                              ticketsID: widget.id,
                            );
                            print(satisfaction.Comentario);
                            saveSatisfaction(satisfaction);
                          }else{
                            CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: "No se han completado todas las calificaciones",
                                btnOkOnPress: () {}, width: size.width>500? null : size.width * 0.9,
                                btnCancelOnPress: () {}).showError(context);
                          }
                        },
                        child: const Text('Enviar', style: TextStyle(color: Colors.white),),
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
    final controller = StateMachineController.fromArtboard(art, "State Machine 1");
    art.addController(controller!);
    _input1 = controller.findInput<double>("rating") as SMINumber;
    _input1!.change(raiting1);
    controller.isActiveChanged.addListener(() {
      if (controller.isActive) {
        setState(() {
          raiting1 = _input1!.value;
        });
        storedRating1 = raiting1;
        print('El valor actual de raiting 1 es: $storedRating1');
      }
    });
    updateRating1(raiting1);
  }

  _onRiveInit2(Artboard art) {
    final controller = StateMachineController.fromArtboard(art, "State Machine 1");
    art.addController(controller!);
    _input2 = controller.findInput<double>("rating") as SMINumber;
    _input2!.change(raiting2);
    controller.isActiveChanged.addListener(() async {
      if (controller.isActive) {
        await Future.delayed(const Duration(milliseconds: 300), (){
          setState(() {
            raiting2 = _input2!.value;
          });
          storedRating2 = raiting2;
          print('El valor actual de raiting 2 es: $storedRating2');
        });
      }
    });
    updateRating2(raiting2);
  }

  _onRiveInit3(Artboard art) {
    final controller = StateMachineController.fromArtboard(art, "State Machine 1");
    art.addController(controller!);
    _input3 = controller.findInput<double>("rating") as SMINumber;
    _input3!.change(raiting3);
    controller.isActiveChanged.addListener(() async {
      if (controller.isActive) {
        await Future.delayed(const Duration(milliseconds: 300), (){
          setState(() {
            raiting3 = _input3!.value;
          });
          storedRating3 = raiting3;
          print('El valor actual de raiting 3 es: $storedRating3');
        });
      }
    });
    updateRating3(raiting3);
  }

  void updateRating1(double newRating) {
    setState(() {
      print("object");
      //raiting1 = newRating;
    });
    if (_input1 != null) {
      _input1!.change(newRating);
    }
  }

  void updateRating2(double newRating) {
    setState(() {
      print("object");
      //raiting2 = newRating;
    });
    if (_input2 != null) {
      _input2!.change(newRating);
    }
  }
  void updateRating3(double newRating) {
    setState(() {
      print("object");
      //raiting3 = newRating;
    });
    if (_input3 != null) {
      _input3!.change(newRating);
    }
  }

  Future<void> saveSatisfaction(SatisfactionModel satisfaction) async {
    try{
      LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
      final satisfactionController = SatisfactionController();
      bool save = await satisfactionController.saveSatisfaction(satisfaction);
      if(save){
        CustomAwesomeDialogTickets(title: Texts.addSuccess, desc: '', width: size.width>500? null : size.width * 0.9,
            btnOkOnPress: () {}, btnCancelOnPress: () {}).showSuccess(context);
      }else{
        CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: Texts.ticketErrorSave,
            btnOkOnPress: () {}, width: size.width>500? null : size.width * 0.9,
            btnCancelOnPress: () {}).showError(context);
      }
    }catch(e){
      CustomAwesomeDialogTickets(title: Texts.errorSavingData, desc: '${Texts.ticketErrorSave}. $e',
          btnOkOnPress: () {}, width: size.width>500? null : size.width * 0.9,
          btnCancelOnPress: () {}).showError(context);
    }
    await Future.delayed(const Duration(milliseconds: 2500), () async {
      LoadingDialogTickets.hideLoadingDialogTickets(context);
      Navigator.of(context).pop();
    });
  }

}
