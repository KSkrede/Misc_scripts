// Configuration
const SORT_COLUMN_INDEX = 5; // A = 1, B = 2, etc...
const ASCENDING = true; // Whether to sort in ascending or descending order.
const NUMBER_OF_HEADER_ROWS = 1; // Exclude header rows from the sort.

// Keep track of the active sheet.
let activeSheet;

/**
 * Automatically sorts the pre-defined column.
 *
 * @param {Sheet} sheet The sheet to sort.
 */
function autoSort(sheet) {
  const range = sheet.getDataRange();

  if (NUMBER_OF_HEADER_ROWS > 0) {
    const dataRange = range.offset(NUMBER_OF_HEADER_ROWS, 0);
    dataRange.sort({
      column: SORT_COLUMN_INDEX,
      ascending: ASCENDING,
    });
  } else {
    range.sort({
      column: SORT_COLUMN_INDEX,
      ascending: ASCENDING,
    });
  }
}

/**
 * Triggers when a sheet is edited, and calls the autoSort function if the
 * edited cell is in the column being sorted.
 */
function onEdit(e) {
  const editedCell = e.range;
  activeSheet = editedCell.getSheet();

  if (editedCell.getColumn() === SORT_COLUMN_INDEX) {
    autoSort(activeSheet);
  }
}

/**
 * Runs when the sheet is opened.
 */
function onOpen() {
  activeSheet = SpreadsheetApp.getActiveSheet();
  autoSort(activeSheet);
}

/**
 * Calculate the difference in days between the given date and today.
 */
function calculateDaysDifference(date) {
  const today = new Date();
  const inputDate = new Date(date);
  const timeDifference = inputDate - today;
  const daysDifference = Math.floor(timeDifference / (1000 * 60 * 60 * 24) + 1); // ms * s * m * h = days + 1 to include today
  return daysDifference;
}

/**
 * Calculate and return the number of days until the given date.
 */
function daysUntil(date) {
  if (!date) {
    return "";
  }

  const daysDiff = calculateDaysDifference(date);

  return daysDiff < 0 ? "Frist passert" : daysDiff;
}
