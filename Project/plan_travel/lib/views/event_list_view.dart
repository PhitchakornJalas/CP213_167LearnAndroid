import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/daily_detail_viewmodel.dart';
import 'daily_detail_view.dart';

class EventListView extends StatelessWidget {
  final DateTime selectedDay;
  const EventListView({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DailyDetailViewModel>(context);
    final events = vm.getEventsForDay(selectedDay);

    return Scaffold(
      appBar: AppBar(title: Text("กิจกรรมวันที่ ${selectedDay.day}/${selectedDay.month}")),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            leading: Icon(event.isAllDay ? Icons.wb_sunny : Icons.access_time),
            title: Text(event.title),
            subtitle: Text(event.isAllDay ? "ตลอดวัน" : "${event.startTime.hour}:00 - ${event.endTime.hour}:00"),
            trailing: Text("${event.budget} ฿"),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => DailyDetailView(selectedDay: selectedDay, existingEvent: event)
            )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // เช็คก่อนว่ามีกิจกรรม All Day ไหม
          final error = vm.checkTimeOverlap(selectedDay, DateTime.now(), DateTime.now(), true);
          if (error != null && events.isNotEmpty && events.any((e) => e.isAllDay)) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
          } else {
             Navigator.push(context, MaterialPageRoute(
               builder: (context) => DailyDetailView(selectedDay: selectedDay)
             ));
          }
        },
      ),
    );
  }
}
