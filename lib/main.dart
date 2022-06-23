import 'dart:io';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';

class event {
  /*
  Class representing an event.

  Attributes:
    name (String): Name of the event.
    date (String): Date of the event.
    time (String): Time of the event.
  */
  String name;
  List<String> dates;
  List<String> times;

  event(this.name, this.dates, this.times);

  void toStr() {
    print(
        '\nReminder: $name\nDate: ${dates[0]} --> ${dates[1]}\nTime: ${times[0]} --> ${times[1]}\n');
  }

  String startDate() {
    return dates[0];
  }

  String endDate() {
    return dates[1];
  }

  String startTime() {
    return times[0];
  }

  String endTime() {
    return times[1];
  }
}

void main() {
  stdout.writeln('what is the title of the 🔔?');
  String? name = stdin.readLineSync();
  stdout.writeln('what is the 📅 period? (YYYY-MM-DD;YYYY-MM-DD)');
  String? date = stdin.readLineSync();
  List<String> dates = date!.split(';');
  stdout.writeln('what is the ⏰ period? (HH:MM:SS;HH:MM:SS)');
  String? time = stdin.readLineSync();
  List<String> times = time!.split(';');
  event newEvent = new event(name!, dates, times);
  newEvent.toStr();

  var _clientID;
  var _clientSec;

  readFile("keys.txt").then((value) {
    if (value == null) {
      print('🛑 Error reading API credentials');
    } else {
      _clientID = value[0];
      _clientSec = value[1];
      clientViaUserConsent(ClientId(_clientID, _clientSec),
              [CalendarApi.calendarScope], prompt)
          .then((value) {
        var calendar = CalendarApi(value);

        Event event2 = Event(); // Create object of event
        event2.summary = name; // Set name of event

        EventDateTime start = new EventDateTime();
        // start.dateTime = DateTime.parse('2022-06-14 19:30:00');
        start.dateTime =
            DateTime.parse('${newEvent.startDate()} ${newEvent.startTime()}');
        start.timeZone = 'GMT-4:00';
        event2.start = start;

        EventDateTime end = new EventDateTime();
        // end.dateTime = DateTime.parse('2022-06-14 19:35:00');
        end.dateTime =
            DateTime.parse('${newEvent.endDate()} ${newEvent.endTime()}');
        end.timeZone = 'GMT-4:00';
        event2.end = end;

        calendar.events.insert(event2, "primary").then((value) {
          print("Adding.............${value.status}");
          calendar.events.list("primary").then((value) {
            List? items = value.items;
            for (var i = 0; i < items!.length; i++) {
              print(items[i].summary);
            }
          });
        });
      });
    }
  });
}

void prompt(String url) {
  print('Please go to the following URL and grant access:');
  print('  => $url');
  print('');
}

Future<List?> readFile(String path) async {
  /*
  Reads the file at [path] and returns the contents as a list

  Args:
    path: The path to the file to read
  
  Returns:
    A list of strings, one for each line in the file
    or null if the file could not be read
  */
  File file = File(path);
  try {
    List contents = await file.readAsLines();
    return contents;
  } catch (e) {
    return null;
  }
}
