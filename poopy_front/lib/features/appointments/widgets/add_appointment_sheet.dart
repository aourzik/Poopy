import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/models.dart';
import '../../../core/theme/app_theme.dart';

class AddAppointmentSheet extends StatefulWidget {
  const AddAppointmentSheet({super.key});

  @override
  State<AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<AddAppointmentSheet> {
  final _doctorController = TextEditingController();
  final _typeController = TextEditingController(); // Motif
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _prepController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(28, 20, 28, MediaQuery.of(context).viewInsets.bottom + 100),
      decoration: BoxDecoration(
        color: context.t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: context.t.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text("Nouveau Rendez-vous", style: TextStyle(fontFamily: 'Quicksand', fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),
            
            // Date & Heure
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text("Date", style: TextStyle(fontSize: 12)),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text("Heure", style: TextStyle(fontSize: 12)),
                    subtitle: Text(_selectedTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _selectedTime);
                      if (time != null) setState(() => _selectedTime = time);
                    },
                  ),
                ),
              ],
            ),
            
            TextField(controller: _doctorController, decoration: const InputDecoration(labelText: "Docteur ou Laboratoire")),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Lieu")),
            TextField(controller: _typeController, decoration: const InputDecoration(labelText: "Motif du RDV")),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: "Détails (Notes)")),
            TextField(controller: _prepController, decoration: const InputDecoration(labelText: "Préparation de la visite")),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rdv,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                final fullDate = DateTime(
                  _selectedDate.year, _selectedDate.month, _selectedDate.day,
                  _selectedTime.hour, _selectedTime.minute,
                );
                
                final appt = Appointment(
                  id: '', // Sera généré par le backend
                  date: fullDate,
                  doctor: _doctorController.text,
                  location: _locationController.text,
                  type: _typeController.text,
                  notes: _notesController.text,
                  preparation: _prepController.text,
                );
                Navigator.pop(context, appt);
              },
              child: const Text("Enregistrer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}