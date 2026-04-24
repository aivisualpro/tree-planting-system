import ExcelJS from 'exceljs';

/**
 * Generates an Excel file from data and columns.
 */
export async function generateExcel(data: any[], columns: any[], sheetName: string = 'Data') {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet(sheetName);

  worksheet.columns = columns.map(col => ({
    header: col.header,
    key: col.key,
    width: col.width || 20
  }));

  worksheet.addRows(data);

  // Style header row
  const headerRow = worksheet.getRow(1);
  headerRow.font = { bold: true, color: { argb: 'FFFFFFFF' } };
  headerRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF166534' } // Green-800
  };
  headerRow.alignment = { vertical: 'middle', horizontal: 'center' };

  // Add zebra striping to rows
  worksheet.eachRow((row, rowNumber) => {
    if (rowNumber > 1 && rowNumber % 2 === 0) {
      row.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFF9FAFB' } // Gray-50
      };
    }
  });

  return await workbook.xlsx.writeBuffer();
}
