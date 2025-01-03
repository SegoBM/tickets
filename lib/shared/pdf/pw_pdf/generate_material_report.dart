import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tickets/shared/pdf/pw_pdf/slice_painter.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw ;
import 'package:flutter/material.dart';
import '../../../controllers/TicketController/departamentController.dart';
import '../../../models/TicketsModels/ticket.dart';
import '../../../models/TicketsModels/ticketsReportModel.dart';
import '../../utils/user_preferences.dart';
import '../../widgets/dialogs/custom_awesome_dialog.dart';
import 'package:share_plus/share_plus.dart';
Future< void  >  generatedTicketsReport (BuildContext context, List<TicketsModels> tickets,DateTime startDate, DateTime endDate) async {
  try{

    UserPreferences userPreferences = UserPreferences();
    String idPuesto = await userPreferences.getPuestoID();
    String nombreUsuario = await userPreferences.getUsuarioNombre();
    final departamentoController = departamentController();
    String departament = await departamentoController.getPuesto(idPuesto) as String;
    String idUsuario = await userPreferences.getUsuarioID();
    String today = DateTime.now().toString().split(' ')[0];
    final Uint8List imagePng = await _loadImage('assets/shimaco.png');
    final Uint8List imageJPG2 = await _loadImage('assets/koreano.jpg');

    double nCerrados = 0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "Cerrado"){
        nCerrados +=1;
      }
    }

    double nRecibidos = 0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].UsuarioAsignadoID == idUsuario){
        nRecibidos +=1;
      }
    }

    double nAbiertos =0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "Abierto"){
        nAbiertos +=1;
      }
    }

    double nProgreso=0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "En Progreso"){
        nProgreso +=1;
      }
    }

    double nResueltos =0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "Resuelto"){
        nResueltos +=1;
      }
    }
    List<double> values = [100, 200, 150, 250, 300];
    List<PdfColor> colors = [PdfColor.fromHex('#877470'), PdfColor.fromHex('#f30b0b'),
      PdfColor.fromHex('#b5b6ff'), PdfColor.fromHex('#4f5081'), PdfColor.fromHex('#526954')];
print(nAbiertos);
print(nProgreso);
print(nResueltos);

    final values2 = [nAbiertos, nProgreso, nResueltos,nCerrados];
    final colors2 = [PdfColors.blueGrey, PdfColors.brown, PdfColors.black,PdfColors.blueAccent];
    int calificacion =0;

    final pdf = pw.Document()..addPage( pw.MultiPage(
      /// ----------------------------page Format--------------------------
        margin: const pw.EdgeInsets.all( 10 ), maxPages: 100,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        /// -------------------------header construction---------------------
        header:
            (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only( bottom: 3.0 * PdfPageFormat.mm ),
            padding: const pw.EdgeInsets.only( bottom: 3.0 * PdfPageFormat.mm ),
            decoration: const pw.BoxDecoration( // border: pw.BoxBorder( bottom: true, width: 2.0, color: PdfColors.grey ),
            ),
            child:
                pw.Column(children:[pw.Row(
                      children:[
                        _buildHeadGrid ( pw.Image(pw.MemoryImage( imagePng  ), width: 90) ,context,2,0,  4 ,60 )[0],
                        _buildHeadGrid ( pw.Text( 'REPORTE DE TICKETS' , style:  pw.TextStyle( fontSize: 17, color: PdfColors.red, fontWeight: pw.FontWeight.bold ) ), context,0,0,  4, 60 )[1],
                        // _buildHeadGrid ( pw.Text( 'Prueba info', textAlign: pw.TextAlign.center), context,0,2,  4, 60)[2],
                        pw.Column(  children: [
                          _headerCells( pw.Text( 'Usuario:', style: const pw.TextStyle( fontSize: 7,)) ,20, 5.5/2, context),
                          _headerCells( pw.Text( 'Departamento',style: const pw.TextStyle( fontSize: 7,)) ,20, 5.5/2, context),
                          _headerCells( pw.Text( 'Fecha gerenación reporte',style: const pw.TextStyle( fontSize: 7,)) ,22, 5.5/2, context),

                        ] ),
                        pw.Column(  children: [
                          _headerCells2(pw.Text(nombreUsuario, style: pw.TextStyle( fontSize: 7, fontWeight: pw.FontWeight.bold )) ,20, 4.8/2,  context),
                          _headerCells2(pw.Text(departament,style: pw.TextStyle( fontSize: 7, fontWeight: pw.FontWeight.bold )) ,20, 4.8/2,  context),
                          _headerCells2(pw.Text(today,style: pw.TextStyle( fontSize: 7, fontWeight: pw.FontWeight.bold )) ,20, 4.8/2,  context),
                        ] ),
                      ]
                  ),
                  pw.Row(children: [
                    pw.Column( children: [
                      _headerCells( pw.Text( 'Fecha de inicio del reporte:', style: const pw.TextStyle( fontSize: 8,)) ,20, 20/2, context),
                      _headerCells( pw.Text( 'Fecha de cierre del reporte:', style: const pw.TextStyle( fontSize: 8,)) ,20, 20/2, context),

                    ] ),
                    pw.Column(  children: [
                      _headerCells2(pw.Text("${startDate.toString().split(' ')[0]}",style: pw.TextStyle( fontSize: 8, fontWeight: pw.FontWeight.bold )) ,20, 20.5/2,  context),
                      _headerCells2(pw.Text("${endDate.toString().split(' ')[0]}",style: pw.TextStyle( fontSize: 8, fontWeight: pw.FontWeight.bold )) ,20, 20.5/2,  context),

                    ] ),
                  ],),
                ])
          );
        },
        /// -----------Body construction-----------------
        build:( pw.Context context){
          return [ /// here, you can add the widgets that you want to show in the pdf
            _headerGrid('ESPECIFICACIONES DE TICKETS',context ,1, 1, fontSize: 11, height: 18),
            pw.Column(children:[
              pw.Row( children:[
                  pw.Column( children: [
                    _createTwoRows('Tickets recibidos:', '${nRecibidos.toString().split(".")[0]}', context, height: 20,width: 10.14),
                    _createTwoRows('Tickets cerrados:', '${nCerrados.toString().split(".")[0]}', context,height: 20, width: 10.14),
                    _createTwoRows('Tickets abiertos:', '${nAbiertos.toString().split(".")[0]}', context, height: 20, width: 10.14),
                    _createTwoRows('Tickets en progreso:', '${nProgreso.toString().split(".")[0]}', context, height: 20, width: 10.14),
                    _createTwoRows('Tickets en resueltos:', '${nResueltos.toString().split(".")[0]}', context, height: 20, width: 10.14),
                    _createTwoRows('Calificación promedio:', '${calificacion.toString().split(".")[0]}', context, height: 20, width: 10.14),
                  ] ),
                ]),
                  pw.SizedBox( height: 10 ),
                ]),
            _headerGrid('RESUMEN DE TICKETS', context, 1, 1,fontSize: 11,height: 18 ),
            pw.Column( children:[
              pw.Column( children:[
                _createTenRows("Titulo", "Descripción","Fecha de creación","Estatus","Prioridad","Usuario creador","Usuario o deparamento asignado","Fecha de asignación","Fecha de finalización","Satisfacción",
                    context,width: 2.03,height: 28.0),
              ]),
            ] ),
            _viewTable(tickets, context),
            pw.SizedBox( height: 10 ),
            pw.Column(children:[
              pw.Center(child:barChart(values, colors),
              ),
              pw.SizedBox( height: 10 ),
              pw.Row(children:[
                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColors.blue, // Cambia esto al color que corresponda a 'Tickets abiertos'
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets abiertos'),
                  ],
                ),
                pw.SizedBox(width: 10),

                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColors.green, // Cambia esto al color que corresponda a 'Tickets en progreso'
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets en progreso'),
                  ],
                ),
                pw.SizedBox(width: 10),

                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColors.yellow, // Cambia esto al color que corresponda a 'Tickets resueltos'
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets resueltos'),
                  ],
                ),
                pw.SizedBox(width: 10),

                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColors.red, // Cambia esto al color que corresponda a 'Tickets cerrados'
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets cerrados'),
                  ],
                ),
              ]),

            ]),
            pw.Center(child: PieChart(
              values: values2,
              colors: colors2,
            ),),



            pw.Divider(thickness: .5),
            _headerGrid('Metricas y Analisis',context ,1, 1, fontSize: 11, height: 18),
            pw.Column( children: [
              _createTwoRows('Tiempo promedio de resolución:', '', context, height: 20,width: 10.14),
              _createTwoRows('Tickets por prioridad', '', context,height: 20, width: 10.14),
              _createTwoRows('Propuestas de mejoras', '', context, height: 50, width: 10.14),

            ] ),
            pw.SizedBox( height: 10 ),

            _signRowsT(context),


          ];
        },
        /// ---------------footerConstruction-------------------
        /// just in case thers more than one page, this will show the page number
        footer: (pw.Context context) {
          final String pageNumber = context.pageNumber.toString();
          //final String tatalPages = context.pagesCount.toString();
          return pw.Align( alignment: pw.Alignment.center,
              child: pw.Text(pageNumber, style: const  pw.TextStyle( fontSize: 8 )) );
        }
    ),
    );
    await saveAndLauncheReport( await pdf.save(), 'MaterialsReportPrue.pdf' );
    _succes(context);
  } catch ( e ){
    CustomSnackBar.showWarningSnackBar(context, e.toString());
    _decline(context);
    print( e );
  }
}
Future< void  >  generatedTicketsReport2 (BuildContext context, List<TicketsReportModel> tickets,DateTime startDate, DateTime endDate) async {
  try{
    UserPreferences userPreferences = UserPreferences();
    String idPuesto = await userPreferences.getPuestoID();
    String nombreUsuario = await userPreferences.getUsuarioNombre();
    final departamentoController = departamentController();
    String departament = await departamentoController.getPuesto(idPuesto) as String;
    String idUsuario = await userPreferences.getUsuarioID();
    String today = DateTime.now().toString().split(' ')[0];
    final Uint8List imagePng = await _loadImage('assets/shimaco.png');
    final Uint8List imageJPG2 = await _loadImage('assets/koreano.jpg');

    double nCerrados = 0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "Cerrado"){
        nCerrados +=1;
      }
    }

    double nRecibidos = 0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].UsuarioAsignadoID == idUsuario){
        nRecibidos +=1;
      }
    }

    double nAbiertos =0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "Abierto"){
        nAbiertos +=1;
      }
    }

    double nProgreso=0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "En Progreso"){
        nProgreso +=1;
      }
    }

    double nResueltos =0;
    for(int i = 0; i < tickets.length; i++){
      if(tickets[i].Estatus == "Resuelto"){
        nResueltos +=1;
      }
    }

    int calificacionGen = 0;
    for(int i = 0; i < tickets.length; i++){
      calificacionGen += tickets[i].CalificacionGeneral ?? 0;
    }
    double calificacionGeneralProm = calificacionGen/tickets.length;

    int calificacionCalidad =0;
    for(int i =0;i< tickets.length;i++){
      calificacionCalidad += tickets[i].CalificacionCalidad ?? 0;
    }
    double calificacionCalidadProm = calificacionCalidad/tickets.length;

    int calificacionTiempo =0;
    for(int i =0;i< tickets.length;i++){
      calificacionTiempo += tickets[i].CalificacionTiempo ?? 0;
    }
    double calificacionTiempoProm = calificacionTiempo/tickets.length;

    String allComments = '';
    for (var ticket in tickets) {
      if (ticket.Comentarios != null) {
        allComments += (ticket.Comentarios! + '\n');
      }
    }
    int numberOfComments = allComments.split('\n').length;
    double heightPerComment = 10.0;
    double totalHeight = numberOfComments * heightPerComment;

    List<double> values = [nRecibidos*10, nCerrados*10, nProgreso*10, nAbiertos*10, nResueltos*10];
    List<PdfColor> colors = [PdfColor.fromHex('#1e2938'), PdfColor.fromHex('#6a6e6f'),
      PdfColor.fromHex('#34485c'), PdfColor.fromHex('#505d68'), PdfColor.fromHex('#c6cdd6')];
    print(nAbiertos);
    print(nProgreso);
    print(nResueltos);

    final values2 = [nAbiertos, nProgreso, nResueltos,nCerrados];
    final colors2 = [PdfColor.fromHex("#505d68"),PdfColor.fromHex("#34485c"), PdfColor.fromHex("#c6cdd6"),PdfColor.fromHex("#6a6e6f")];
    int calificacion =0;

    final pdf = pw.Document()..addPage( pw.MultiPage(
      /// ----------------------------page Format--------------------------
        margin: const pw.EdgeInsets.all( 10 ),
        maxPages: 100,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        /// -------------------------header construction---------------------
        header:
            (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only( bottom: 3.0 * PdfPageFormat.mm ),
              padding: const pw.EdgeInsets.only( bottom: 3.0 * PdfPageFormat.mm ),
              decoration: const pw.BoxDecoration( // border: pw.BoxBorder( bottom: true, width: 2.0, color: PdfColors.grey ),
              ),
              child:
              pw.Column(children:[pw.Row(
                  children:[
                    _buildHeadGrid ( pw.Image(pw.MemoryImage( imagePng  ), width: 90) ,context,2,0,  4 ,60 )[0],
                    _buildHeadGrid ( pw.Text( 'REPORTE DE TICKETS' , style:  pw.TextStyle( fontSize: 17, color: PdfColors.red, fontWeight: pw.FontWeight.bold ) ), context,0,0,  4, 60 )[1],
                    // _buildHeadGrid ( pw.Text( 'Prueba info', textAlign: pw.TextAlign.center), context,0,2,  4, 60)[2],
                    pw.Column(  children: [
                      _headerCells( pw.Text( 'Usuario:', style: const pw.TextStyle( fontSize: 7,)) ,20, 5.5/2, context),
                      _headerCells( pw.Text( 'Departamento',style: const pw.TextStyle( fontSize: 7,)) ,20, 5.5/2, context),
                      _headerCells( pw.Text( 'Fecha gerenación reporte',style: const pw.TextStyle( fontSize: 7,)) ,22, 5.5/2, context),

                    ] ),
                    pw.Column(  children: [
                      _headerCells2(pw.Text(nombreUsuario, style: pw.TextStyle( fontSize: 7, fontWeight: pw.FontWeight.bold )) ,20, 4.8/2,  context),
                      _headerCells2(pw.Text(tickets[0].NombreDepartamento!,style: pw.TextStyle( fontSize: 7, fontWeight: pw.FontWeight.bold )) ,20, 4.8/2,  context),
                      _headerCells2(pw.Text(today,style: pw.TextStyle( fontSize: 7, fontWeight: pw.FontWeight.bold )) ,20, 4.8/2,  context),
                    ] ),
                  ]
              ),
                pw.Row(children: [
                  pw.Column( children: [
                    _headerCells( pw.Text( 'Fecha de inicio del reporte:', style: const pw.TextStyle( fontSize: 8,)) ,20, 20/2, context),
                    _headerCells( pw.Text( 'Fecha de cierre del reporte:', style: const pw.TextStyle( fontSize: 8,)) ,20, 20/2, context),

                  ] ),
                  pw.Column(  children: [
                    _headerCells2(pw.Text("${startDate.toString().split(' ')[0]}",style: pw.TextStyle( fontSize: 8, fontWeight: pw.FontWeight.bold )) ,20, 20.5/2,  context),
                    _headerCells2(pw.Text("${endDate.toString().split(' ')[0]}",style: pw.TextStyle( fontSize: 8, fontWeight: pw.FontWeight.bold )) ,20, 20.5/2,  context),

                  ] ),
                ],),
              ])
          );
        },
        /// -----------Body construction-----------------
        build:( pw.Context context){
          return [ /// here, you can add the widgets that you want to show in the pdf
            _headerGrid('ESPECIFICACIONES DE TICKETS',context ,1, 1, fontSize: 11, height: 18),
            pw.Column(children:[
              pw.Row( children:[
                pw.Column( children: [
                  _createTwoRows('Tickets recibidos:', '${nRecibidos.toString().split(".")[0]}', context, height: 20,width: 10.14),
                  _createTwoRows('Tickets cerrados:', '${nCerrados.toString().split(".")[0]}', context,height: 20, width: 10.14),
                  _createTwoRows('Tickets abiertos:', '${nAbiertos.toString().split(".")[0]}', context, height: 20, width: 10.14),
                  _createTwoRows('Tickets en progreso:', '${nProgreso.toString().split(".")[0]}', context, height: 20, width: 10.14),
                  _createTwoRows('Tickets en resueltos:', '${nResueltos.toString().split(".")[0]}', context, height: 20, width: 10.14),
                  _createTwoRows('Calificación promedio:', '${calificacionGeneralProm.toString().split(".")[0]}', context, height: 20, width: 10.14),
                ] ),
              ]),
              pw.SizedBox( height: 10 ),
            ]),
            _headerGrid('RESUMEN DE TICKETS', context, 1, 1,fontSize: 11,height: 18 ),
            pw.Column( children:[
              pw.Column( children:[
                _createTenRows("Titulo", "Descripción","Fecha de creación","Estatus","Prioridad","Usuario creador","Usuario o deparamento asignado","Fecha de asignación","Fecha de finalización","Satisfacción",
                    context,width: 2.03,height: 28.0),
              ]),
            ] ),
            _viewTable2(tickets, context),
            pw.SizedBox( height: 10 ),
          
            pw.Center(child: PieChart(
              values: values2,
              colors: colors2,
            ),),
            pw.SizedBox( height: 10 ),
            pw.Row(
              children: [
                pw.SizedBox(width: 10),


                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColor.fromHex('#505d68'),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('${nAbiertos.toString().split(".")[0]}'),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets abiertos'),
                  ],
                ),
                pw.SizedBox(width: 10),

                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColor.fromHex('#34485c'),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('${nProgreso.toString().split(".")[0]}'),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets en progreso'),
                  ],
                ),
                pw.SizedBox(width: 10),

                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColor.fromHex('#c6cdd6'),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('${nResueltos.toString().split(".")[0]}'),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets resueltos'),
                  ],
                ),
                pw.SizedBox(width: 10),

                pw.Row(
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      color: PdfColor.fromHex('#6a6e6f'),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text('${nCerrados.toString().split(".")[0]}'),
                    pw.SizedBox(width: 5),
                    pw.Text('Tickets cerrados'),
                  ],
                ),
              ],
            ),


            pw.Divider(thickness: .5),
            _headerGrid('Metricas y Analisis',context ,1, 1, fontSize: 11, height: 18),
            pw.Column( children: [
              _createTwoRows('Calificación general en promedio:', (calificacionGeneralProm*20).toStringAsFixed(2)+'%', context, height: 20,width: 10.14),
              _createTwoRows('Calificación general en tiempo', (calificacionTiempoProm*20).toStringAsFixed(2)+'%', context,height: 20, width: 10.14),
              _createTwoRows('Calificación calidad en Calidad', (calificacionCalidadProm*20).toStringAsFixed(2)+'%', context, height: 50, width: 10.14),
              _createTwoRows('Comentarios adicionales', allComments, context, height: totalHeight, width: 10.14),

            ] ),
            pw.SizedBox( height: 10 ),

            _signRowsT(context),


          ];
        },
        /// ---------------footerConstruction-------------------
        /// just in case thers more than one page, this will show the page number
        footer: (pw.Context context) {
          final String pageNumber = context.pageNumber.toString();
          //final String tatalPages = context.pagesCount.toString();
          return pw.Align( alignment: pw.Alignment.center,
              child: pw.Text(pageNumber, style: const  pw.TextStyle( fontSize: 8 )) );
        }
    ),
    );
    await saveAndLauncheReport( await pdf.save(), 'ReporteTickets${startDate.toString().split(' ')[0]}.pdf' );
    _succes(context);
  } catch ( e ){
    CustomSnackBar.showWarningSnackBar(context, e.toString());
    _decline(context);
    print( e );
  }
}


pw.Widget bar(double height, PdfColor color) {
  return pw.Container(
    width: 20,
    height: height,
    color: color,
    margin: const pw.EdgeInsets.symmetric(horizontal: 4.0),
  );
}
pw.Widget barChart(List<double> values, List<PdfColor> colors) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.center,
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: List.generate(values.length, (index) {
      return bar(values[index],colors[index]);
    }),
  );
}

Future<void> saveAndLauncheReport( List<int> bytes, String fileName ) async {
  // final Directory directory = await getApplicationDocumentsDirectory(); this line mades that the pc answer about the app who is trying to access the directory
  late File file;
  if(Platform.isWindows){
    file = File( fileName );
  }else{
    file = File( '/storage/emulated/0/documents/$fileName' );
  }
  await file.writeAsBytes( bytes, flush : true );
  print(file.path);
  if(Platform.isWindows){
    OpenFile.open( file.path );
  }else{
    final result = await Share.shareXFiles([XFile(file.path)], text: fileName);
    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }
}
Future<Uint8List> _loadImage(String path) async {
  final ByteData data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}
_succes(context){
  CustomAwesomeDialog(
    title: '¡Reporte generado Exitosamente!', desc: '', btnOkOnPress: () {Navigator.of(context).pop();},
    btnCancelOnPress: () {}, width: MediaQuery.of(context).size.width > 500? null : MediaQuery.of(context).size.width*0.9).showSuccess(context);
}
_decline(context){
  CustomAwesomeDialog(
      title:'¡Error al generar el reporte!',desc: '',btnOkOnPress: (){},
      btnCancelOnPress: (){}, width: MediaQuery.of(context).size.width > 500? null : MediaQuery.of(context).size.width*0.9).showError(context);
}

pw.Widget _infoTexts(){
    return pw.Column(children: [
      pw.RichText(text: pw.TextSpan(children:[
        pw.TextSpan(
            text: 'Recomendaciónes: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 8,  lineSpacing: 2)),
        const pw.TextSpan(text:
        ' -Evitar frotes o rozamientos extremadamente fuertes. -No usar disolventes con cloro, alcohol, productos limpiacristales o aerosoles. -No aplicar ceras ni productos con contenidos químicos abrasivos.'
        ' -Evitar fuentes de calor extrema o la exposición prolongada a la luz solar- Almacenar en áreas libres de humedad.',
            style: pw.TextStyle(fontSize: 8, lineSpacing: 2)),
      ])),
        pw.RichText(text:   pw.TextSpan( children:[
        pw.TextSpan(text: 'Recommendations:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, lineSpacing: 2 ) ),

        const  pw.TextSpan(text: ' -Avoid extremely strong rubbing or friction. -Do not use solvents with chlorine, alcohol, cleaning products or aerosols. -Do not apply waxes or products with abrasive chemical contents.'
            ' -Avoid extreme heat sources or prolonged exposure to sunlight- Store in moisture-free areas.  ',
            style: pw.TextStyle(fontSize: 8,lineSpacing: 2)),
      ] )),
        pw.RichText(text:  pw.TextSpan( children:[
        pw.TextSpan(text: 'Observaciones: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8,  lineSpacing: 2) ),
        const  pw.TextSpan(text: 'Las recomendaciones y sugerencias contenidas en está ficha técnica están basadas en las pruebas obtenidas en nuestro laboratorio,'
            ' se sugiere realizar pruebas previas para verificar que los parámetros recomendados son los adecuados en las condiciones de trabajo del cliente.',
            style: pw.TextStyle(fontSize: 8,lineSpacing: 2)),
      ])
      ),
      pw.RichText(text:  pw.TextSpan( children:[
        pw.TextSpan(text: 'Observations: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, lineSpacing: 2) ),
        const  pw.TextSpan(text: 'the recommendations and suggestions contained in this technical sheet are based on evidence obtained in our laboratory,'
            ' it is suggested to perform preliminary tests to verify that the recommended parameters are appropriate in the customer´s working conditions.',
            style: pw.TextStyle(fontSize: 8, lineSpacing: 2, )),
      ])
      ),


    ]);
}
pw.Widget _updateRow (context ){
  return pw.Column(children: [
      _headerGrid('HISTORIAL DE ACTUALIZACIONES', context, 1, 1, fontSize: 11, height: 18),
   pw.Row(children:[
  _textContainer('Fecha:', context, width: 2.3, height: 35, padding: const pw.EdgeInsets.all(1), fontSize: 8, align: pw.Alignment.center, bold: true, pdfColor: "#EBECE8" ),
  _textContainer('Especificacion o Composición', context, width:4.5, height: 35, padding: const pw.EdgeInsets.all(1), fontSize: 8, align: pw.Alignment.center, bold: true, pdfColor: "#EBECE8"),
     pw.Column( children:[
       _textContainer('Valor o composición', context, height: 35/2, width: 4, padding: const pw.EdgeInsets.all(2), fontSize: 8, align: pw.Alignment.center, bold: true, pdfColor: "#EBECE8"),
       pw.Row(children:[
       _textContainer('Nueva', context, height: 35/2,width: 2, padding: const pw.EdgeInsets.all(1), fontSize: 8, align: pw.Alignment.center, bold: true,pdfColor: "#EBECE8"),
       _textContainer('Anterior', context, height: 35/2, width: 2, padding: const pw.EdgeInsets.all(1), fontSize: 8, align: pw.Alignment.center, bold: true,pdfColor: "#EBECE8")  ]),
     ] ),
      _textContainer('Motivo de cambio', context, height:35, width: 9.5, align: pw.Alignment.center, padding: const pw.EdgeInsets.all(1), fontSize: 8, bold: true,pdfColor: "#EBECE8"),
    ]),
    pw.Row(children:[
      _textContainer('99/99/2099', context, width: 2.3, height: 25, padding: const pw.EdgeInsets.all(1), fontSize: 8, align: pw.Alignment.center, bold: false,),
      _textContainer('Material Composition', context, width:4.5, height: 25, padding: const pw.EdgeInsets.all(1), fontSize: 8, align: pw.Alignment.center, bold: false),
      _textContainer('X', context, height: 25, width: 2, padding: const pw.EdgeInsets.all(2), fontSize: 10, align: pw.Alignment.center, bold: false,),
      _textContainer('X', context, height: 25, width: 2, padding: const pw.EdgeInsets.all(2), fontSize: 10, align: pw.Alignment.center, bold: false,),
      _textContainer('Initial Composition', context, height:25, width: 9.5, align: pw.Alignment.center, padding: const pw.EdgeInsets.all(1), fontSize: 8, bold: false),
    ]),
  ]);
}
pw.Widget _signRows(pw.Context context){
  return pw.Column(
      children: [
        _createThreeRows('Develop and authorize/ Elabora y Autoriza','Receive/ Recibe','Informed/ Enterado',
          context, width: 6.76, height: 25,align: pw.Alignment.center,pdfColor:'#E8E2DE', fontColor: "#000000"  ),
        _createThreeRows('Firma y Sello\nControl de Calidad','Firma y Sello\nDesarrollo','Firma y Sello\nVentas',
            context,width: 6.76, height: 75, align: pw.Alignment.bottomCenter, pdfColor: '#FFFFFF', fontColor: "#FFC0CB" ),
  ]);
}

pw.Widget _signRowsT(pw.Context context){
  return pw.Column(
      children: [
        _createThreeRows('Genera Reporte','Recibe Reporte','Enterado Reporte',
            context, width: 6.76, height: 25,align: pw.Alignment.center,pdfColor:'#E8E2DE', fontColor: "#000000"  ),
        _createThreeRows('Firma y Sello','Firma y Sello','Firma y Sello',
            context,width: 6.76, height: 75, align: pw.Alignment.bottomCenter, pdfColor: '#FFFFFF', fontColor: "#FFC0CB" ),
      ]);
}

pw.Widget _viewTable(List<TicketsModels> tickets, pw.Context context){
  return pw.Column(children: [
    for(int i = 0; i < tickets.length; i++)...[
      pw.Container(
        child: pw.Row(
          children:[
            pw.Column( children:[
              _createTenRowsDescription("${tickets[i].Titulo}","${tickets[i].Descripcion}","${tickets[i].FechaCreacion?.split("T")[0]}\n${tickets[i].FechaCreacion?.split("T")[1].split(".")[0]}","${tickets[i].Estatus}","${tickets[i].Prioridad}","${tickets[i].UsuarioNombre}","${tickets[i].NombreUsuarioAsignado ?? tickets[i].NombreDepartamento}","${tickets[i].FechaAsignacion?.split("T")[0]}\n${tickets[i].FechaAsignacion?.split("T")[1].split(".")[0]}","${tickets[i].FechaFinalizacion?.split("T")[0]??""}\n${tickets[i].FechaFinalizacion?.split("T")[1].split(".")[0]??""}", "Satisfacción",
                  context,width: 2.03,height: 43.0),
            ]),
          ],
        ),
      )
    ]
  ]);
}


pw.Widget _viewTable2(List<TicketsReportModel> tickets, pw.Context context){
  return pw.Column(children: [
   for(int i = 0; i < tickets.length; i++)...[
     pw.Container(
       child: pw.Row(
         children:[
           pw.Column( children:[
             _createTenRowsDescription("${tickets[i].Titulo}","${tickets[i].Descripcion}","${tickets[i].FechaCreacion?.split("T")[0]}\n${tickets[i].FechaCreacion?.split("T")[1].split(".")[0]}","${tickets[i].Estatus}","${tickets[i].Prioridad}","${tickets[i].UsuarioNombre}","${tickets[i].NombreUsuarioAsignado ?? tickets[i].NombreDepartamento}","${tickets[i].FechaAsignacion?.split("T")[0]}\n${tickets[i].FechaAsignacion?.split("T")[1].split(".")[0]}","${tickets[i].FechaFinalizacion?.split("T")[0]??""}\n${tickets[i].FechaFinalizacion?.split("T")[1].split(".")[0]??""}","Satisfacción",
                 context,width: 2.03,height: 43.0),
           ]),
         ],
       ),
     )
    ]
  ]);
}

pw.Widget _signRows2(pw.Context context){
  return pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        _createFourRows('SOLICITA','AUTORIZA','AUTORIZA','EJECUTA',
            context, width: 4, height: 12,align: pw.Alignment.center,pdfColor:'#000000', fontColor: "#FFFFFF"),
        _createFourRows('','','','',
            context, width: 4, height: 60,align: pw.Alignment.center,pdfColor:'#FFFFFF', fontColor: "#000000"),
        _createFourRows('USUARIO','GERENCIA','CONTRALORIA','DIRECCIÓN',
            context, width: 4, height: 11,align: pw.Alignment.center,pdfColor:'#FFFFFF', fontColor: "#000000"),
      ]);
}
List<pw.Widget> _buildHeadGrid ( pw.Widget widget, pw.Context context, double radiusLeft, double radiusRight, double sizeW, double sizeH){
  return [
    pw.Container(
      height: sizeH ,width: PdfPageFormat.a4.width/sizeW - 20,
      decoration: pw.BoxDecoration(
        border: pw.Border.all( color: PdfColor.fromHex("#3E4D54"), width: 1),
        borderRadius:  pw.BorderRadius.horizontal(left: pw.Radius.circular(radiusLeft), right: pw.Radius.circular(radiusRight)),
      ),
      child: pw.Align( alignment: pw.Alignment.center, child: widget),
    ),
    pw.Container(
      height: sizeH , width:PdfPageFormat.a4.width/sizeW+150,
      decoration: pw.BoxDecoration(
        border: pw.Border.all( color: PdfColor.fromHex("#3E4D54"), width: 1),
        borderRadius:  pw.BorderRadius.horizontal(left: pw.Radius.circular(radiusLeft), right: pw.Radius.circular(radiusRight)),
      ),
      child: pw.Align( alignment: pw.Alignment.center, child: widget),
    ),
  ];
}
pw.Widget _headerCells ( pw.Widget widget, double sizeH, double sizeW, pw.Context context ){
  return
    pw.Container( height : sizeH, width:sizeW* PdfPageFormat.cm,
      padding: const pw.EdgeInsets.all( 5),
      decoration: pw.BoxDecoration(color: PdfColor.fromHex("#E8E2DE"),
        border: pw.Border.all( color: PdfColor.fromHex("#3E4D54"), width: 1),
      ),
      child:  pw.Align( alignment: pw.Alignment.centerLeft , child:widget),
    );
}
pw.Widget _headerCells2 ( pw.Widget widget, double sizeH, double sizeW, pw.Context context ){
  return
    pw.Container( height : sizeH, width:sizeW* PdfPageFormat.cm,
      padding: const pw.EdgeInsets.all( 5),
      decoration: pw.BoxDecoration(
        // color: PdfColor.fromHex("#E8E2DE"),
        border: pw.Border.all( color: PdfColor.fromHex("#3E4D54"), width: 1),
      ),
      child:  pw.Align( alignment: pw.Alignment.centerLeft , child:widget),
    );
}
pw.Widget _headerCells3 ( pw.Widget widget, double sizeH, double sizeW, pw.Context context ){
  return
    pw.Container( height : sizeH, width:sizeW* PdfPageFormat.cm,
      padding: const pw.EdgeInsets.all( 5),
      decoration: pw.BoxDecoration(
        // color: PdfColor.fromHex("#E8E2DE"),
        border: pw.Border.all( color: PdfColor.fromHex("#3E4D54"), width: 1),
      ),
      child:  pw.Align( alignment: pw.Alignment.center , child:widget),
    );
}
pw.Widget _headerCells4(pw.Widget widget, double sizeH, double sizeW, pw.Context context, String color){
  return
    pw.Container( height : sizeH, width:sizeW* PdfPageFormat.cm,
      padding: const pw.EdgeInsets.all(2),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex("#$color"),
        border: pw.Border.all( color: PdfColor.fromHex("#000000"), width: 1),
      ),
      child:  pw.Align(alignment: pw.Alignment.center, child:widget),
    );
}
pw.Widget _headerGrid (String text , pw.Context context, double radiusLeft, double radiusRight, {double fontSize = 15, double height = 30} ){
  return pw.Container(
    height: height , decoration: pw.BoxDecoration(
    color:  PdfColor.fromHex("#E8E2DE"),
    border: pw.Border.all( color: PdfColor.fromHex("#3E4D54"), width: 1.5),
    borderRadius:  const pw.BorderRadius.all(pw.Radius.circular(0)),
  ), child: pw.Align(  alignment: pw.Alignment.center , child: pw.Text(text, style:  pw.TextStyle( fontWeight: pw.FontWeight.bold, fontSize: fontSize  )  )),
  );
}
/// ---------------original text container-------------------
pw.Widget _textContainer( String text,pw.Context context,
    {bool bold = false, pw.AlignmentGeometry align = pw.Alignment.centerLeft,
      double  width = 6, double  height = 25, padding = const pw.EdgeInsets.all(5), double fontSize = 10, String pdfColor = "#FFFFFF", String fontColor = "#000000"}){
  return pw.Container(
    height: height, width: width * PdfPageFormat.cm, padding: padding,
    decoration: pw.BoxDecoration(color: PdfColor.fromHex(pdfColor), border: pw.Border.all( color: PdfColor.fromHex("#3E4D54"),width: 1),),
    child: pw.Align( alignment: align,
      child: pw.Text(text, style:  pw.TextStyle( fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize:fontSize, color: PdfColor.fromHex(fontColor) )),),
  );
}
///--------------Create Rows is a customWidget that creates a row with two columns a info and info value in the pdf-----------
pw.Widget _createTwoRows(String label, String value ,pw.Context context,
    { double width = 6.1, double height =25, padding = const pw.EdgeInsets.all(3), double fontsize = 8, String pdfColor = "#FFFFFF" } ){
  return pw.Row(children: [
    _textContainer(label, context, align: pw.Alignment.centerLeft, width: width+(1.5), height: height, padding: padding, fontSize: fontsize, pdfColor: pdfColor),
    _textContainer(value, context, bold: true, align: pw.Alignment.centerLeft, width: width-(1.5), height: height, padding: padding, fontSize: fontsize,pdfColor: pdfColor),
  ]);
}
pw.Widget _createTwoRows2(String label, String value ,pw.Context context,
    { double width = 10.12, double height =25, padding = const pw.EdgeInsets.all(3), double fontsize = 8, String pdfColor = "#FFFFFF" } ){
  return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start,children: [
    _textContainer(label, context, align: pw.Alignment.centerLeft, width: width, height: height, padding: padding, fontSize: fontsize, pdfColor: pdfColor),
    _textContainer(value, context, align: pw.Alignment.centerLeft, width: width, height: height, padding: padding, fontSize: fontsize,pdfColor: pdfColor),
  ]);
}
/// ------------------Create three row to show the information in the pdf-----------------
pw.Widget _createThreeRows(String label,String label2,String label3 ,pw.Context context,
    { double width = 6.1, double height =25, padding = const pw.EdgeInsets.all(3),
      double fontsize = 8, String pdfColor = "#FFFFFF",  pw.AlignmentGeometry align = pw.Alignment.centerLeft , String fontColor = "#FFFFFF" } ){
  return pw.Row(children:[
    _textContainer(label,  context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label2, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label3, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
  ]);
}
pw.Widget _createFourRows(String label,String label2,String label3,String label4,pw.Context context,
    { double width = 6.1, double height =25, padding = const pw.EdgeInsets.all(3),
      double fontsize = 7, String pdfColor = "#FFFFFF",  pw.AlignmentGeometry align = pw.Alignment.centerLeft , String fontColor = "#FFFFFF" } ){
  return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center,children:[
    _textContainer(label,  context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label2, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label3, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label4, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
  ]);
}
pw.Widget _createTenRows(String label,String label2,String label3,String label4,String label5,String label6,String label7,String label8,String label9,String label10,pw.Context context,
    { double width =2, double height =25, padding = const pw.EdgeInsets.all(2),
      double fontsize = 7, String pdfColor = "#FFFFFF",  pw.AlignmentGeometry align = pw.Alignment.centerLeft , String fontColor = "#000000" } ){
  return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center,children:[
    _textContainer(label,  context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label2, context, align:align, width: 3, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label3, context, align:align, width: 1.71, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label4, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label5, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label6, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label7, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label8, context, align:align, width: 1.71, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label9, context, align:align, width: 1.71, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,
    _textContainer(label10, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:true, fontColor: fontColor) ,

  ]);
}
pw.Widget _createTenRowsDescription(String label,String label2,String label3,String label4,String label5,String label6,label7,label8,label9,label10,pw.Context context,
    { double width =2, double height =25, padding = const pw.EdgeInsets.all(2),
      double fontsize = 7, String pdfColor = "#FFFFFF",  pw.AlignmentGeometry align = pw.Alignment.centerLeft , String fontColor = "#000000" } ){
  return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center,children:[
    _textContainer(label,  context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label2, context, align:align, width: 3, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label3, context, align:align, width: 1.71, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label4, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label5, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label6, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label7, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label8, context, align:align, width: 1.71, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label9, context, align:align, width: 1.71, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,
    _textContainer(label10, context, align:align, width: width, height: height, padding:padding, fontSize:fontsize, pdfColor:pdfColor, bold:false, fontColor: fontColor) ,

  ]);
}
pw.Widget rowCheck(String text, bool value,[double width = 70]){
  return pw.Row(children: [
    pw.SizedBox(width: width,child:
    pw.Text(text, style: const pw.TextStyle(fontSize: 7,), textAlign: pw.TextAlign.start),),
    pw.Container(width: 15, height: 15, decoration: pw.BoxDecoration(color: value? PdfColor.fromHex("#000000"): PdfColor.fromHex("#FFFFFF"),
      border: pw.Border.all(color: PdfColor.fromHex("#000000"), width: 0.6,),),)
  ]);
}
