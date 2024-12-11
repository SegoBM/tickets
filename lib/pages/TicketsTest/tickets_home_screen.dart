import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tickets/shared/widgets/appBar/appBar_decoration.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:intl/intl.dart';

import '../../shared/utils/color_palette.dart';
import '../../shared/utils/icon_library.dart';
import '../../shared/utils/texts.dart';
import '../../shared/widgets/buttons/custom_button.dart';

class TicketsHomeDashboardScreenTest extends StatefulWidget {
  static String id = 'TicketsHomeScreen2';
  BuildContext context;

  TicketsHomeDashboardScreenTest({Key? key, required this.context});

  @override
  _TicketsHomeDashboardScreenTestState createState() =>
      _TicketsHomeDashboardScreenTestState();
}

class _TicketsHomeDashboardScreenTestState
    extends State<TicketsHomeDashboardScreenTest> {
  late List<_ChartData> data;
  late List<ChartData> listData;
  late TooltipBehavior _tooltip;
  final _controller = ScrollController();
  late ThemeData theme;
  final List<SalesData> chartData = [
    SalesData(DateTime(2024, 1, 1), 35),
    SalesData(DateTime(2024, 2, 1), 28),
    SalesData(DateTime(2024, 3, 1), 34),
    SalesData(DateTime(2024, 4, 1), 32),
    SalesData(DateTime(2024, 5, 1), 40)
  ];

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

  late Size size;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: ColorPalette.ticketsTextSelectedColor,
        appBar: size.width > 600
            ? MyCustomAppBarDesktop(
                title: "Dashboard Chevron",
                context: context,
                textColor: Colors.white,
                backButton: true,
                defaultButtons: false,
                defaultButtonT: false,
                color: ColorPalette.ticketsColor,
                backButtonWidget: TextButton.icon(
                  icon: const Icon(
                    IconLibrary.iconBack,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Salir de tickets",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.transparent, // Color de fondo
                  ),
                  onPressed: () {
                    Navigator.of(widget.context).pop();
                  },
                ),
              )
            : null,
        body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: MediaQuery.of(context).size.width > 600
                ? _bodyLandscape()
                : _bodyPortrait()));
  }

  Widget _bodyLandscape() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        _graficoConRelieve(_graficoBarras(size.width / 4)),
                        const SizedBox(
                          height: 15,
                        ),
                        _graficoConRelieve(_graficoPie(size.width / 4)),
                      ],
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    Column(
                      children: [
                        _graficoConRelieve(_graficoStackedLine(size.width / 2)),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _bodyPortrait() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 20,
          ),
          _graficoConRelieve(_graficoBarras(size.width - 40)),
          const SizedBox(
            height: 20,
          ),
          _graficoConRelieve(_graficoPie(size.width - 40)),
          const SizedBox(
            height: 15,
          ),
          _graficoConRelieve(_graficoStackedLine(size.width - 40)),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _customButtonAdd() {
    return IntrinsicHeight(
      child: CustomButton(
          text: Texts.ticketAdd,
          onPressed: () async {},
          icon: IconLibrary.iconAdd,
          height: 50,
          color: ColorPalette.ticketsColor.withOpacity(0.9),
          colorText: Colors.white),
    );
  }

  Widget _graficoConRelieve(Widget grafico) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        // Espaciado interno
        color: ColorPalette.ticketsColor5, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Borde redondeado
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.5),
            // Color de la sombra
            spreadRadius: 2,
            blurRadius: 2,
            // Desenfoque de la sombra
            offset: const Offset(0, 2), // Posición de la sombra
          ),
        ],
      ),
      child: grafico,
    );
  }

  Widget _graficoBarras(double width) {
    return Column(
      children: [
        SizedBox(
          width: width,
          child: const Text("Tickets levantados por areas",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
        SizedBox(
          width: width,
          height: 150,
          child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<_ChartData, String>>[
                ColumnSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    name: 'Tickets',
                    color: Colors.blueGrey)
              ]),
        )
      ],
    );
  }

  Widget _graficoStackedLine(double width) {
    return Column(
      children: [
        const Text(
          "Tickets",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
            width: width,
            height: 399,
            child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMM(), // Formato de fecha
                  title: AxisTitle(text: 'Mes'), // Título del eje X
                ),
                primaryYAxis: CategoryAxis(
                  title: AxisTitle(text: 'Area'), // Título del eje X
                ),
                legend: const Legend(isVisible: true),
                // Agrega una leyenda
                tooltipBehavior: TooltipBehavior(enable: true),
                // Habilita tooltips
                series: <CartesianSeries>[
                  // Render line chart
                  LineSeries<SalesData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (SalesData sales, _) => sales.year,
                    yValueMapper: (SalesData sales, _) => sales.sales,
                    name: 'Tickets',
                    // Nombre de la serie
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    // Muestra etiquetas de datos
                    enableTooltip: true,
                    // Habilita tooltips para esta serie
                    color: theme.colorScheme.tertiary, // Color de la serie
                  )
                ]))
      ],
    );
  }

  Widget _graficoPie(double width) {
    return Column(
      children: [
        const Text(
          "Areas",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
            width: width,
            height: 200,
            child: SfCircularChart(
                legend: const Legend(isVisible: true), // Agrega una leyenda
                tooltipBehavior:
                    TooltipBehavior(enable: true), // Habilita tooltips
                series: <CircularSeries>[
                  // Render pie chart
                  PieSeries<ChartData, String>(
                      dataSource: listData,
                      pointColorMapper: (ChartData data, _) => data.color,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      // Muestra etiquetas de datos
                      explode: true,
                      // Agrega un efecto de explosión
                      explodeIndex: 0,
                      // El índice del segmento que quieres que esté explotado inicialmente
                      explodeOffset:
                          '10%' // La cantidad que deseas que se desplace el segmento explotado
                      )
                ]))
      ],
    );
  }

  Widget containerInfo(
      Color colorContainer, Color colorText, String title, String text) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: 170,
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: colorContainer,
            border: Border.all(
              color: theme.colorScheme.onSecondaryContainer, // border color
              width: 3, // border width
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 15, color: theme.colorScheme.background),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      text,
                      style: TextStyle(
                          fontSize: 21,
                          color: theme.colorScheme.background,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  // Método para generar datos de ejemplo
  List<_ChartData> _getData() {
    return [
      _ChartData('Ti', 10),
      _ChartData('Credito y cobranza', 20),
      _ChartData('Contaduria', 30),
      _ChartData('Ventas', 15),
    ];
  }

  final List<ChartData> _getChartData = [
    ChartData('Ti', 25),
    ChartData('Creco', 38),
    ChartData('Contaduria', 34),
    ChartData('Ventas', 52)
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
