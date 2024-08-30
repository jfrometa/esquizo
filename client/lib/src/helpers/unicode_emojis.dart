String flagUnicodeToString(String unicode) {
  List<String> splited = unicode.split(' ');
  StringBuffer buffer = StringBuffer();
  for (String u in splited) {
    buffer.write(String.fromCharCode(int.parse(u.substring(2), radix: 16)));
  }
  
  return buffer.toString();
}
