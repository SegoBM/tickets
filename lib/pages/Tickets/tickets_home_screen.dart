import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tickets/controllers/TicketController/DashboardController.dart';
import 'package:tickets/models/TicketsModels/DashboardModels/ticketsMes.dart';
import 'package:tickets/models/TicketsModels/DashboardModels/ticketsPrioridad.dart';
import 'package:tickets/models/TicketsModels/DashboardModels/ticketsPromedio.dart';
import 'package:tickets/models/TicketsModels/DashboardModels/ticketsResume.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:intl/intl.dart';
import '../../models/TicketsModels/DashboardModels/ticketsEstatus.dart';
import '../../shared/actions/handleException.dart';
import '../../shared/utils/icon_library.dart';
import '../../shared/utils/texts.dart';
import '../../shared/utils/user_preferences.dart';
import '../../shared/widgets/Snackbars/customSnackBar.dart';
class TicketsHomeDashboardScreen extends StatefulWidget {
  static String id = 'dashboardScreen';
  BuildContext context;
  TicketsHomeDashboardScreen({Key? key, required this.context});
  @override
  _TicketsHomeDashboardScreenState createState() => _TicketsHomeDashboardScreenState();
}

class _TicketsHomeDashboardScreenState extends State<TicketsHomeDashboardScreen> {
  late List<_ChartData> data; late List<ChartData> listData;
  late TooltipBehavior _tooltip;
  late TooltipBehavior _tooltip2;
  final _controller = ScrollController();
  late ThemeData theme; late Size size;
  DateTime today = DateTime.now();
  TextEditingController dateInitial = TextEditingController();
  bool isEmpty = false, _isLoading = true;
  double countOpen = 0, countClose = 0, countInProgress = 0, countResolved = 0;

  Map<DateTime, double> dateCountsOpen = {};
  Map<DateTime, double> dateCountsClosed = {};
  Map<DateTime, double> dateCountsInProgress = {};
  Map<DateTime, double> dateCountsResolved = {};

  final List<TicketsData> chartData = [], chartData2 = [], chartData3 = [], chartData4 = [];
  List<TicketsResume> ticketsResume = [], listTicketsTemp = [],listTicketsTempReport=[];
  List<TicketsEstatus> ticketsEstatus = [];
  List<TicketsMes> ticketsMes = [];
  List<TicketsPrioridad> ticketsPrioridad = [];
  List<TicketsPromedio> ticketsPromedio = [];

  DashboardController dashboardController = DashboardController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();

    _getDatos();
    const timeLimit = Duration(seconds: 15);
    Timer(timeLimit, () {
      if (ticketsResume.isEmpty) {
        if (!isEmpty) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        _isLoading = false;
      }
    });
    _tooltip = TooltipBehavior(enable: true);
    _tooltip2 = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context); size = MediaQuery.of(context).size;
    if (_isLoading) {
      return Container(width: size.width, height: size.height,
        color: ColorPalette.ticketsTextSelectedColor,
        child: const Center(child: CircularProgressIndicator(color: Colors.black),),
      );
    }else if(ticketsResume.isEmpty){
      return Container(width: size.width, height: size.height, color: ColorPalette.ticketsTextSelectedColor,
        child: const Center(
          child: Text("No hay tickets generados", style: TextStyle(color: Colors.black, fontSize: 20,
              fontWeight: FontWeight.bold),),
        ),
      );
    }else {
      return Scaffold(backgroundColor: ColorPalette.ticketsTextSelectedColor,
          appBar: size.width > 600 ? appBarWidget() : null,
          body: Padding(padding: const EdgeInsets.symmetric(vertical: 5), child:
          MediaQuery.of(context).size.width > 500 ? _bodyLandscape() : _bodyPortrait()
          ));
    }
  }
  PreferredSizeWidget? appBarWidget(){
    return MyCustomAppBarDesktop(title: "Ticket Dashboard", context: context,
    textColor: Colors.white, backButton: false, color: ColorPalette.ticketsColor,ticketsFlag: false,
    backButtonWidget: TextButton.icon(
    icon: const Icon(IconLibrary.iconBack, color: Colors.white),
    label: const Text(Texts.ticketExit, style: TextStyle(color: Colors.white),),
    style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.transparent,),
    onPressed: () {Navigator.of(widget.context).pop();},
    ));
  }

  Widget _bodyLandscape(){
    return SingleChildScrollView(child: Column(children: [
      _scrollInfo(),
      const SizedBox(height: 40,),
      Center(child: SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
          SizedBox(width: 750, child:_graficoConRelieve(_graficoStackedLine(750))),
          const SizedBox(width: 20,),
          Column(mainAxisAlignment: MainAxisAlignment.start,children: [
            _graficoConRelieve(_graficoBarras(370)),
            const SizedBox(height: 20,),
            _graficoConRelieve(_graficoPie(370)),
          ],)
        ],),))
    ],),);
  }

  Widget _graficoBarras(double width){
    return Column(children: [
      SizedBox(width: width,child: const Center(child: Text("Prioridad de tickets",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),)),),
      SizedBox(width: width, height: 150,child:
      SfCartesianChart(primaryXAxis: CategoryAxis(labelStyle: const TextStyle(color: Colors.white),),
          primaryYAxis: NumericAxis(minimum: 0, maximum: 10, interval: 10, labelStyle: const TextStyle(color: Colors.white),),
          tooltipBehavior: _tooltip,
          legend: const Legend(isVisible: false, textStyle: TextStyle(color: Colors.white)),
          series: <CartesianSeries<_ChartData, String>>[
            ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.x,
              yValueMapper: (_ChartData data, _) => data.y,
              name: 'Tickets',
              dataLabelSettings: const DataLabelSettings(isVisible: true,
                  textStyle: TextStyle(color: Colors.white)),
              color: ColorPalette.ticketsColor4,)
          ]),)
    ],);
  }

  Widget _bodyPortrait(){
    return SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(children: [
          _scrollInfo(),
          const SizedBox(height: 5,),
          SizedBox(width: size.width-15, height: 380,
              child:_graficoConRelieve(_graficoStackedLine(size.width-15, height: 345))),
          const SizedBox(height: 10,),
          _graficoConRelieve(_graficoBarras(370)),
          const SizedBox(height: 10,),
          _graficoConRelieve(_graficoPie(370)),
        ],),
      ),);
  }
  Widget _graficoConRelieve(Widget grafico) {
    return Container(padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: ColorPalette.ticketsColor2, borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.5), spreadRadius: 2, blurRadius: 2,
            offset: const Offset(0, 2),),
        ],
      ), child: grafico,
    );
  }
  Widget _graficoPie(double width){
    return Column(children: [
      const Text("Estatus de tickets",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
      SizedBox(width: width, height: 200,child:
      SfCircularChart(
          legend: const Legend(isVisible: true, textStyle: TextStyle(color: Colors.white)), // Agrega una leyenda
          tooltipBehavior: TooltipBehavior(enable: true), // Habilita tooltips
          series: <CircularSeries>[
            // Render pie chart
            PieSeries<ChartData, String>(
              dataSource: listData,
              pointColorMapper:(ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: true,
                  textStyle: TextStyle(color: Colors.white)), // Muestra etiquetas de datos
              explode: true, // Agrega un efecto de explosión
              explodeIndex: 0, // El índice del segmento que quieres que esté explotado inicialmente
              explodeOffset: '5%', // La cantidad que deseas que se desplace el segmento explotado
            )
          ]
      ))
    ],);
  }
  Widget _scrollInfo(){
    if(Platform.isAndroid || Platform.isIOS){
      return FadingEdgeScrollView.fromSingleChildScrollView(child:
      SingleChildScrollView(scrollDirection: Axis.horizontal,controller: _controller,child:
      _listScroll(),));
    }else{
      return SingleChildScrollView(scrollDirection: Axis.horizontal,controller: _controller,
        child: _listScroll(),);
    }
  }
  Widget _listScroll(){
    return  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        containerInfo("TicketAbierto",ColorPalette.ticketsColor2,Colors.white,
            "Tiempo promedio de atención", "${ticketsPromedio.isNotEmpty? ticketsPromedio.first.tiempoPromedioHoras : 0} Hrs"),
      ],
    );
  }
  Widget _graficoStackedLine(double width, {double height = 399}){
    return Transform.scale(scale: 0.9,
      child: Column(children: [
        const Text("Tickets", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),),
        SizedBox(width: width, height: height, child:
        SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat.yMMM(), // Formato de fecha
              title: AxisTitle(text: 'Mes', textStyle: const TextStyle(color: Colors.white)), // Título del eje X
              labelStyle: const TextStyle(color: Colors.white), // Color de las etiquetas del eje X
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Tickets Generados', textStyle: const TextStyle(color: Colors.white)), // Título del eje Y
              numberFormat: NumberFormat.decimalPattern(), // Formato de número
              labelStyle: const TextStyle(color: Colors.white), // Color de las etiquetas del eje Y
            ),
            legend:  const Legend(isVisible: true,textStyle:TextStyle(color: Colors.white)), // Agrega una leyenda
            tooltipBehavior: TooltipBehavior(enable: true), // Habilita tooltips
            series: <CartesianSeries>[
              // Render line chart
              LineSeries<TicketsData, DateTime>(
                dataSource: chartData,
                xValueMapper: (TicketsData sales, _) => sales.year,
                yValueMapper: (TicketsData sales, _) => sales.sales,
                name: 'Tickets Abiertos',
                dataLabelSettings: const DataLabelSettings(isVisible: true, color: Colors.white70),
                enableTooltip: true,
                color: Colors.white70,
              ),

              LineSeries<TicketsData, DateTime>(
                dataSource: chartData2,
                xValueMapper: (TicketsData sales, _) => sales.year,
                yValueMapper: (TicketsData sales, _) => sales.sales,
                name: 'Tickets Cerrados',
                dataLabelSettings: const DataLabelSettings(isVisible: true, color: ColorPalette.ticketsColor7),
                enableTooltip: true,
                color: Colors.blue,
              ),

              LineSeries<TicketsData, DateTime>(
                dataSource: chartData3,
                xValueMapper: (TicketsData sales, _) => sales.year,
                yValueMapper: (TicketsData sales, _) => sales.sales,
                name: 'Tickets En progreso',
                dataLabelSettings: const DataLabelSettings(isVisible: true, color: Colors.white),
                enableTooltip: true,
                color: Colors.white,
              ),

              LineSeries<TicketsData, DateTime>(
                dataSource: chartData4,
                xValueMapper: (TicketsData sales, _) => sales.year,
                yValueMapper: (TicketsData sales, _) => sales.sales,
                name: 'Tickets Resueltos',
                dataLabelSettings: const DataLabelSettings(isVisible: true, color: Colors.grey),
                enableTooltip: true,
                color: Colors.grey,
              )
            ]
        ))
      ],),
    );
  }
  Widget containerInfo(String image, Color colorContainer, Color colorText, String title, String text){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(width: 170, height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(color: colorContainer,
          border: Border.all(color: ColorPalette.ticketsColor5, width: 3,),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/$image.png', width: 40, height: 40,), // Reemplaza esto con la ruta de tu imagen
              Text(title, style: TextStyle(fontSize: 12, color: colorText),),
              Text(text, style: TextStyle(fontSize: 21, color: colorText, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );  }
  // Método para generar datos de ejemplo


  Widget _buildLoadingIndicator(int n) {
    List<Widget> buttonList = List.generate(n, (index) {
      return Center(
        child: Column(
          children: [
            loadingSkeletonForGraph(size.width, size.height), // Ajusta el alto según tus necesidades
          ],
        ),
      );    });
    return SingleChildScrollView(physics: const NeverScrollableScrollPhysics(),
      child: Column(children: buttonList,),
    );
  }

  Widget loadingSkeletonForGraph(double width, double height) {
    return SizedBox(width: width, height: height,
      child: Shimmer.fromColors(
        baseColor: ColorPalette.ticketsColor2,
        highlightColor: ColorPalette.ticketsColor3,
        child: Container(color: ColorPalette.ticketsColor2,),
      ),
    );
  }

  Widget loadingSkeletonForInfoContainer(double width, double height) {
    return SizedBox(width: width, height: height,
      child: Card(color: ColorPalette.ticketsColor9,
        child: Padding(padding: const EdgeInsets.all(10),
          child: Shimmer.fromColors(
            baseColor: ColorPalette.ticketsColor2,
            highlightColor: ColorPalette.ticketsColor3,
            child: Container(color: ColorPalette.ticketsColor2,),
          ),
        ),
      ),
    );
  }
  Future<List<_ChartData>> _getData() async {
    Map<String, int> prioridad = {
      'Importante': 0,
      'Urgente': 0,
      'No urgente': 0,
      'Pregunta': 0,
    };
    for (var ticket in ticketsPrioridad) {
      prioridad[ticket.prioridad] = ticket.cantidad;
    }
    return [
      _ChartData(prioridad.keys.first, prioridad.values.first.toDouble()),
      _ChartData(prioridad.keys.elementAt(1), prioridad.values.elementAt(1).toDouble()),
      _ChartData(prioridad.keys.elementAt(2), prioridad.values.elementAt(2).toDouble()),
      _ChartData(prioridad.keys.elementAt(3), prioridad.values.elementAt(3).toDouble()),
    ];
  }
  Future<List<ChartData>> _getData2() async {
    Map<String, int> estatus = {
      'Abierto': 0,
      'En progreso': 0,
      'Resuelto': 0,
      'Cerrado': 0,
    };
    for (var ticket in ticketsEstatus) {
      estatus[ticket.estatus] = ticket.cantidad;
    }
    return [
      ChartData(estatus.keys.first, estatus.values.first.toDouble(), ColorPalette.ticketsDashboard1),
      ChartData(estatus.keys.elementAt(1), estatus.values.elementAt(1).toDouble(), ColorPalette.ticketsDashboard2),
      ChartData(estatus.keys.elementAt(2), estatus.values.elementAt(2).toDouble(), ColorPalette.ticketsDashboard3),
      ChartData(estatus.keys.elementAt(3), estatus.values.elementAt(3).toDouble(), ColorPalette.ticketsDashboard4),
    ];
  }
  Future<void> _getDatos() async {
    try {
      final idUsuario = await UserPreferences().getUsuarioID();

      ticketsPrioridad = await dashboardController.getTicketsPrioridad(idUsuario);
      //ticketsMes = await dashboardController.getTicketsMes(idUsuario);
      ticketsPromedio = await dashboardController.getTicketsPromedio(idUsuario);
      ticketsEstatus = await dashboardController.getTicketsEstatus(idUsuario);

      ticketsResume = await dashboardController.getTicketsResume(idUsuario);
      data = await _getData();
      listData = await _getData2();

      if (ticketsResume.isEmpty) {
        isEmpty = true;
        _isLoading = false;
      }else{
        ticketsResume.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion)); // Ordenar por fecha de creación
        listTicketsTemp = ticketsResume;
      }

      for (var ticket in listTicketsTemp) {
        DateTime fechaCreacion = ticket.fechaCreacion;
        DateTime fechaSinHora = DateTime(fechaCreacion.year, fechaCreacion.month, fechaCreacion.day);

        if (ticket.estatus == "Abierto") {
          dateCountsOpen[fechaSinHora] = (dateCountsOpen[fechaSinHora] ?? 0) + 1;
        } else if (ticket.estatus == "Cerrado") {
          dateCountsClosed[fechaSinHora] = (dateCountsClosed[fechaSinHora] ?? 0) + 1;
        } else if (ticket.estatus == "En Progreso") {
          dateCountsInProgress[fechaSinHora] = (dateCountsInProgress[fechaSinHora] ?? 0) + 1;
        } else if (ticket.estatus == "Resuelto") {
          dateCountsResolved[fechaSinHora] = (dateCountsResolved[fechaSinHora] ?? 0) + 1;
        }
      }

      chartData.clear();
      dateCountsOpen.forEach((date, count) {
        chartData.add(TicketsData(date, count));
      });

      chartData2.clear();
      dateCountsClosed.forEach((date, count) {
        chartData2.add(TicketsData(date, count));
      });

      chartData3.clear();
      dateCountsInProgress.forEach((date, count) {
        chartData3.add(TicketsData(date, count));
      });

      chartData4.clear();
      dateCountsResolved.forEach((date, count) {
        chartData4.add(TicketsData(date, count));
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(context, Texts.errorGettingData);
      final connectionExceptionHandler = ConnectionExceptionHandler();
      connectionExceptionHandler.handleConnectionException(context, e);
      setState(() {
        _isLoading = false;
      });
    }
  }

}
class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}
class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
class TicketsData {
  TicketsData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
