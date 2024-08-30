import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

const millisecondsPerMinute = 60000;

//TODO: - Update After test
class IntervalTimer {
  IntervalTimer(this.onCompleted);

  var sampleSize = 60000;
  Function()? onCompleted;
  static const _defaultBpm = 240;

  var bpm = _defaultBpm;
  var intervalInMilliseconds = millisecondsPerMinute / _defaultBpm;

  Timer? timer;
  Isolate? isolate;
  int millisLastTick = 0;

  double overallDeviation = 0;
  var inAccurateTicks = 0;
  // defaults to -1, since there is natural delay between starting the timer or isolate and it's first tick
  var ticksOverall = -1;

  List<String> deviationInfo = [];

  void _onTimerTick() {
    if (ticksOverall >= sampleSize) {
      return;
    }

    ticksOverall++;

    var now = DateTime.now().millisecondsSinceEpoch;
    var duration = now - millisLastTick;

    // ignore the very first tick since there is natural delay between setting up the timer and the first tick
    if (duration != intervalInMilliseconds && ticksOverall > 0) {
      var deviation = (duration - intervalInMilliseconds).abs();
      deviationInfo.add('Deviation in tick #$ticksOverall - $deviation ms');

      inAccurateTicks++;
      overallDeviation += deviation;
    }

    millisLastTick = now;

    if (ticksOverall >= sampleSize) {
      _onSamplingComplete();
    }
  }

  void pessimisticApproach() {
    _resetStatistics();

    timer = Timer.periodic(
      const Duration(microseconds: 500),
      (timer) {
        if (ticksOverall >= sampleSize) {
          return;
        }

        var now = DateTime.now().millisecondsSinceEpoch;
        var duration = now - millisLastTick;

        if (duration >= intervalInMilliseconds) {
          _onTimerTick();

          millisLastTick = now;
        }
      },
    );
  }

  Future<void> pessimisticIsolateApproach() async {
    ReceivePort receiveFromIsolatePort = ReceivePort();

    _resetStatistics();

    isolate = await Isolate.spawn(
      _pessimisticIsolateTimer,
      {
        'tickRate': intervalInMilliseconds,
        'sendToMainThreadPort': receiveFromIsolatePort.sendPort,
      },
    );

    receiveFromIsolatePort.listen((_) {
      _onTimerTick();
    });
  }

  static Future<void> _pessimisticIsolateTimer(Map data) async {
    double tickRate = data['tickRate'];
    SendPort sendToMainThreadPort = data['sendToMainThreadPort'];

    var tickCounter = 0;
    var millisLastTick = DateTime.now().millisecondsSinceEpoch;
    bool needsTick = true;

    var overallDeviation = 0.0;
    var inAccurateTicks = 0;

    Timer.periodic(const Duration(microseconds: 500), (timer) {
      var now = DateTime.now().millisecondsSinceEpoch;
      var duration = now - millisLastTick;

      if (duration >= tickRate && needsTick) {
        sendToMainThreadPort.send(tickCounter++);
        millisLastTick = now;
        needsTick = false;

        var deviation = (duration - tickRate).abs();

        if (deviation > 0) {
          overallDeviation += deviation;
          inAccurateTicks++;

          log('Deviation in tick $tickCounter - $deviation ms');
          log('Overall deviation ${overallDeviation / inAccurateTicks} ms');
        }
      }

      if (duration < tickRate) {
        needsTick = true;
      }
    });
  }

  void _onSamplingComplete() {
    timer?.cancel();
    timer = null;

    isolate?.kill();
    isolate = null;

    log('Ticks $ticksOverall');

    if (onCompleted != null) {
      onCompleted!();
    }
  }

  void _resetStatistics() {
    timer?.cancel();
    millisLastTick = DateTime.now().millisecondsSinceEpoch;
    deviationInfo.clear();

    overallDeviation = 0;
    inAccurateTicks = 0;
    ticksOverall = -1;
  }
}
