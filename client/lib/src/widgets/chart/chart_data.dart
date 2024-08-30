class ChartData {
  ChartData({required this.values, this.labels}) {
    if (labels != null) {
      assert(values.length == labels!.length);
    }
  }
  List<double> values;
  List<String>? labels;

  int _roundUp(double n, int greatness) {
    return ((n ~/ greatness) * greatness) + greatness;
  }

  int _roundDown(double n, int greatness) {
    return (n ~/ greatness) * greatness;
  }

  List<double> _getExtremes() {
    var min = values[0];
    var max = values[0];

    for (double element in values) {
      if (element < min) {
        min = element;
      }
      if (element > max) {
        max = element;
      }
    }

    return [min, max];
  }

  int _getGreatness(num n) {
    if (n < 100) {
      return 10;
    } else if (n < 1000) {
      return 100;
    } else if (n < 10000) {
      return 1000;
    } else if (n < 100000) {
      return 10000;
    } else if (n < 1000000) {
      return 100000;
    } else {
      return 1000000;
    }
  }

  List<int> intervals() {
    var extremes = _getExtremes();
    double maxInterval = extremes[1] - extremes[0];

    int greatness = _getGreatness(maxInterval);

    int first = _roundDown(extremes[0], greatness);
    int last = _roundUp(extremes[1], greatness);

    int nIntervals = 6;

    double interval = (last - first) / nIntervals;

    int roundInterval = _roundDown(interval, _getGreatness(interval));

    if (first + roundInterval * (nIntervals - 1) < last) {
      roundInterval = _roundUp(interval, _getGreatness(interval));
    }

    List<int> list = [first];

    for (var i = 1; i < nIntervals; i++) {
      list.add(first + roundInterval * i);
    }

    return list;
  }

  double scale(double height) {
    var i = intervals();
    return 1 / ((i[i.length - 1] - i[0]) / height);
  }
}
