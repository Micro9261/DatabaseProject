export function getDateInfo(dateText) {
  const date = new Date(dateText);
  const day = date.getUTCDate();
  const month = date.getUTCMonth() + 1;
  const year = date.getUTCFullYear();
  const displayDate = `${day}.${month}.${year}`;
  return displayDate;
}
