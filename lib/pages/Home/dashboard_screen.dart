import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:intl/intl.dart';

import '../../shared/actions/key_raw_listener.dart';
class DashboardScreen extends StatefulWidget {
  static String id = 'dashboardScreen';
  BuildContext context;
  DashboardScreen({Key? key, required this.context});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<_ChartData> data;late List<ChartData> listData;
  late TooltipBehavior _tooltip;
  final _controller = ScrollController();
  late ThemeData theme; late Size size;
  final List<SalesData> chartData = [SalesData(DateTime(2024,1,1), 35),
    SalesData(DateTime(2024,2,1), 28), SalesData(DateTime(2024,3,1), 34),
    SalesData(DateTime(2024,4,1), 32), SalesData(DateTime(2024,5,1), 40)
  ];
  final _key = GlobalKey();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    // Inicialización de datos y configuración del tooltip
    data = _getData();
    listData = _getChartData;
    _tooltip = TooltipBehavior(enable: true);
  }
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context); size = MediaQuery.of(context).size;
    return PressedKeyListener(keyActions: <LogicalKeyboardKey, Function()> {
      LogicalKeyboardKey.escape : () async {Navigator.of(context).pushNamed('homeMenuScreen');},
      LogicalKeyboardKey.f8 : () async {Navigator.of(widget.context).pushNamed('TicketsHome');}
    }, Gkey: _key, child: Scaffold(
        appBar: size.width > 600? MyCustomAppBarDesktop(title: "Dashboard",context: widget.context,backButton: false)
            : null,
        body: Padding(padding: const EdgeInsets.symmetric(vertical: 5),child:
          size.width > 600 ? _bodyLandscape() : _bodyPortrait()
        )));
  }
  Widget _bodyLandscape(){
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      _scrollInfo(),
      const SizedBox(height: 15,),
      SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child:Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 20,),
              Column(children: [
                _graficoConRelieve(_graficoBarras(370)),
                const SizedBox(height: 20,),
                _graficoConRelieve(_graficoPie(370)),
              ],),
              const SizedBox(width: 30,),
              Column(
                children: [
                  _graficoConRelieve(_graficoStackedLine(650)),
                ],
              ),
              const SizedBox(width: 20,),
            ],
          ),))
    ],),);
  }
  Widget _bodyPortrait(){
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20,),
        _scrollInfo(),
        const SizedBox(height: 20,),
        _graficoConRelieve(_graficoBarras(size.width-40)),
        const SizedBox(height: 20,),
        _graficoConRelieve(_graficoPie(size.width-40)),
        const SizedBox(height: 15,),
        _graficoConRelieve(_graficoStackedLine(size.width-40)),
        const SizedBox(height: 15,),
    ],),);
  }
  Widget _graficoConRelieve(Widget grafico) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(// Espaciado interno
        color: theme.colorScheme.inverseSurface, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Borde redondeado
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.5), // Color de la sombra
            spreadRadius: 2, blurRadius: 2, // Desenfoque de la sombra
            offset: const Offset(0, 2), // Posición de la sombra
          ),
        ],
      ),
      child: grafico,
    );
  }
  Widget _scrollInfo(){
    if(Platform.isAndroid || Platform.isIOS){
      return FadingEdgeScrollView.fromSingleChildScrollView(child:
      SingleChildScrollView(scrollDirection: Axis.horizontal,controller: _controller,child:
      _listScroll(),));
    }else{
      return ScrollLoopAutoScroll(scrollDirection: Axis.horizontal, duration: const Duration(minutes: 4),
        child: _listScroll(),);
    }
  }
  Widget _listScroll(){
    return Row(children: [
      containerInfo(theme.colorScheme.secondary, theme.colorScheme.background,
          "Pedidos surtidos", "32"),
      containerInfo(theme.colorScheme.tertiary, theme.colorScheme.onTertiary,
          "Pedidos capturados", "53"),
      containerInfo(theme.colorScheme.primaryContainer, theme.colorScheme.onSecondaryContainer,
          "Pedidos pendientes", "13"),
      containerInfo(theme.colorScheme.secondaryContainer, theme.colorScheme.onPrimaryContainer,
          "Usuarios activos", "28"),
      containerInfo(theme.colorScheme.secondary, theme.colorScheme.onSecondary,
          "Material más vendido", "Sintetico Prada"),
      containerInfo(theme.colorScheme.tertiary, theme.colorScheme.onTertiary,
          "Contenedores recibidos en el mes", "3"),
      containerInfo(theme.colorScheme.primaryContainer, theme.colorScheme.onSecondaryContainer,
          "Contenedores pendientes", "2"),
    ],);
  }
  Widget _graficoBarras(double width){
    return Column(children: [
      SizedBox(width: width,child: const Center(child: Text("Productos más vendidos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),),
      SizedBox(width: width, height: 150,child:
      SfCartesianChart(primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
          tooltipBehavior: _tooltip,
          series: <CartesianSeries<_ChartData, String>>[
            ColumnSeries<_ChartData, String>(
                dataSource: data,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                name: 'Ventas',
                color: theme.colorScheme.secondaryContainer)
          ]),)
    ],);
  }
  Widget _graficoStackedLine(double width){
    return Column(children: [
      const Text("Ventas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      SizedBox(width: width, height: 399,child:
      SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat.yMMM(), // Formato de fecha
            title: AxisTitle(text: 'Año'), // Título del eje X
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Ventas'), // Título del eje Y
            numberFormat: NumberFormat.simpleCurrency(), // Formato de número
          ),
          legend: const Legend(isVisible: true), // Agrega una leyenda
          tooltipBehavior: TooltipBehavior(enable: true), // Habilita tooltips
          series: <CartesianSeries>[
            // Render line chart
            LineSeries<SalesData, DateTime>(
              dataSource: chartData,
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
              name: 'Ventas', // Nombre de la serie
              dataLabelSettings: const DataLabelSettings(isVisible: true), // Muestra etiquetas de datos
              enableTooltip: true, // Habilita tooltips para esta serie
              color: theme.colorScheme.tertiary, // Color de la serie
            )
          ]
      ))
    ],);
  }
  Widget _graficoPie(double width){
    return Column(children: [
      const Text("Vendedores", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      SizedBox(width: width, height: 200,child:
      SfCircularChart(
          legend: const Legend(isVisible: true), // Agrega una leyenda
          tooltipBehavior: TooltipBehavior(enable: true), // Habilita tooltips
          series: <CircularSeries>[
            // Render pie chart
            PieSeries<ChartData, String>(
                dataSource: listData,
                pointColorMapper:(ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(isVisible: true), // Muestra etiquetas de datos
                explode: true, // Agrega un efecto de explosión
                explodeIndex: 0, // El índice del segmento que quieres que esté explotado inicialmente
                explodeOffset: '10%' // La cantidad que deseas que se desplace el segmento explotado
            )
          ]
      ))
    ],);
  }
  Widget containerInfo(Color colorContainer, Color colorText, String title, String text){
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
      width: 170, height: 120, padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: colorContainer,
        border: Border.all(
          color: theme.colorScheme.onSecondaryContainer, // border color
          width: 3, // border width
        ),
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
  List<_ChartData> _getData() {
    return [
      _ChartData('Prada', 10),
      _ChartData('Alaska', 20),
      _ChartData('Forro', 30),
      _ChartData('Casco', 15),
    ];
  }
  final List<ChartData> _getChartData = [
    ChartData('David', 25),
    ChartData('Steve', 38),
    ChartData('Jack', 34),
    ChartData('Others', 52)
  ];
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
class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
