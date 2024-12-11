import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tickets/shared/actions/my_show_dialog.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'generate_invoice.dart';

Future<void> generateReport( context ) async {
  try{

    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        brush: PdfSolidBrush(PdfColor(218, 215, 205))
    );

    final PdfGrid grid = getGrid();
    final PdfLayoutResult result = _drawHeader( page, pageSize, grid );

   // _drawGrid(page, grid, result);

    final List<int> bytes = document.saveSync();
    document.dispose();
    await saveAndLauncheReport(bytes, 'Report.pdf');
    _succes(context);

  }catch( e ){
    _decline( context );
    print( e );
  }
}

Future<void> saveAndLauncheReport( List<int> bytes, String fileName ) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File( '${directory.path}\$fileName' );
  await file.writeAsBytes( bytes, flush : true );
  await OpenFile.open( file.path );
}

_succes ( context ){
  CustomAwesomeDialog(
    title: '¡Reporte generado Exitosamente!', desc: '', btnOkOnPress: () {Navigator.of(context).pop();},
    btnCancelOnPress: () {},).showSuccess(context);
}
_decline ( context ){
  CustomAwesomeDialog(
      title: '¡Error al generar el reporte!',desc: '',btnOkOnPress: (){},
      btnCancelOnPress: (){}).showError(context);
}


PdfLayoutResult _drawHeader( PdfPage page, Size pageSize, PdfGrid grid ){
  page.graphics.drawRectangle(
    brush: PdfSolidBrush( PdfColor( 207, 185, 165 ) ),
    bounds: Rect.fromLTWH(0, 0, pageSize.width, 90)
  );
  final PdfFont contentFont = PdfStandardFont( PdfFontFamily.helvetica, 12 );
   String report = " Holo caryolo ";
  final Size contentSize = contentFont.measureString( report );
  return PdfTextElement( text: 'hello',  ).draw(
    page: page,
    bounds:Rect.fromLTWH(30, 120, pageSize.width - ( contentSize.width + 30 ),pageSize.height -120 )
  )!;
}
void _drawGrid ( PdfPage page, PdfGrid grid, PdfLayoutResult result ){
  Rect? totalPriceCellBounds;  // limites de la celda de precio total
  Rect? quantityCellBounds; // limites de la celda de cantidad
  //Invoke the beginCellLayout event.
  grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
    final PdfGrid grid = sender as PdfGrid;
    if (args.cellIndex == grid.columns.count - 1) {
      totalPriceCellBounds = args.bounds;
    } else if (args.cellIndex == grid.columns.count - 2) {
      quantityCellBounds = args.bounds;
    }
  };
  //Draw the PDF grid and get the result.
  result = grid.draw(
      page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;

  //Draw grand total.
  page.graphics.drawString('Grand Total',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(
          quantityCellBounds!.left,
          result.bounds.bottom + 10,
          quantityCellBounds!.width,
          quantityCellBounds!.height));
  page.graphics.drawString(getTotalAmount(grid).toString(),
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(
          totalPriceCellBounds!.left,
          result.bounds.bottom + 10,
          totalPriceCellBounds!.width,
          totalPriceCellBounds!.height));
}
