import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าการแจ้งเตือน"),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("การจัดการแจ้งเตือน", 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.savings_outlined, color: Colors.orange),
                title: const Text("แจ้งเตือนออมเงิน"),
                subtitle: const Text("แจ้งเตือนให้คุณออมเงินตามแผน"),
                value: settingsVM.savingReminderEnabled,
                onChanged: (val) => settingsVM.setSavingReminderEnabled(val),
              ),
              if (settingsVM.savingReminderEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 70, right: 16),
                  child: Row(
                    children: [
                      // const Text("ความถี่: "),
                      DropdownButton<int>(
                        value: settingsVM.savingReminderInterval,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("ทุก 1 ชั่วโมง")),
                          DropdownMenuItem(value: 6, child: Text("ทุก 6 ชั่วโมง")),
                        ],
                        onChanged: (val) => settingsVM.setSavingReminderInterval(val!),
                      ),
                    ],
                  ),
                ),
              const Divider(indent: 70),
              SwitchListTile(
                secondary: const Icon(Icons.event_note, color: Colors.blue),
                title: const Text("แจ้งเตือนเมื่อใกล้ถึงกิจกรรม"),
                subtitle: const Text("แจ้งเตือนนับถอยหลังก่อนวันเดินทาง"),
                value: settingsVM.eventCountdownEnabled,
                onChanged: (val) => settingsVM.setEventCountdownEnabled(val),
              ),
              if (settingsVM.eventCountdownEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 70, right: 16, bottom: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("แจ้งเตือนก่อน: "),
                          DropdownButton<int>(
                            value: settingsVM.eventCountdownDays,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text("1 วัน")),
                              DropdownMenuItem(value: 3, child: Text("3 วัน")),
                              DropdownMenuItem(value: 7, child: Text("7 วัน")),
                            ],
                            onChanged: (val) => settingsVM.setEventCountdownDays(val!),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const Divider(indent: 70),
              SwitchListTile(
                secondary: const Icon(Icons.timer_outlined, color: Colors.purple),
                title: const Text("แจ้งเตือนก่อนเริ่มกิจกรรม"),
                subtitle: const Text("สำหรับกิจกรรมที่มีระบุเวลา"),
                value: settingsVM.eventReminderBeforeEnabled,
                onChanged: (val) => settingsVM.setEventReminderBeforeEnabled(val),
              ),
              if (settingsVM.eventReminderBeforeEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 70, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      const Text("แจ้งเตือนล่วงหน้า: "),
                      DropdownButton<int>(
                        value: settingsVM.eventReminderBeforeHours,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("1 ชั่วโมง")),
                          DropdownMenuItem(value: 2, child: Text("2 ชั่วโมง")),
                          DropdownMenuItem(value: 3, child: Text("3 ชั่วโมง")),
                        ],
                        onChanged: (val) => settingsVM.setEventReminderBeforeHours(val!),
                      ),
                    ],
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "* หมายเหตุ: ระบบแจ้งเตือนออมเงินจะหยุดทำงานอัตโนมัติในวันนั้นๆ เมื่อคุณทำรายการออมครบตามแผนแล้ว",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
