// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/core/constants/constants.dart';
import 'package:offline_app/core/constants/utils.dart';

class CustomDateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onTap;
  const CustomDateSelector(
      {super.key, required this.selectedDate, required this.onTap});

  @override
  State<CustomDateSelector> createState() => _CustomDateSelectorState();
}

class _CustomDateSelectorState extends State<CustomDateSelector> {
  int weekoffset = 0;

  @override
  Widget build(BuildContext context) {
    final weekDates = genrateWeekDates(weekoffset);
    String monthName = DateFormat("MMMM").format(weekDates.first);
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      weekoffset--;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              Text(
                monthName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      weekoffset++;
                    });
                  },
                  icon: const Icon(Icons.arrow_forward_ios)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 70,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                itemBuilder: (context, index) {
                  final date = weekDates[index];
                  final isSelected =
                      DateFormat('d').format(widget.selectedDate) ==
                              DateFormat('d').format(date) &&
                          widget.selectedDate.month == date.month &&
                          widget.selectedDate.year == date.year;
                  return GestureDetector(
                    onTap: () => widget.onTap(date),
                    child: Container(
                      width: 55,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: isSelected ? AppColor.primaryColor : null,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: 2)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            DateFormat('E').format(date),
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                    isSelected ? Colors.white : Colors.black),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
        )
      ],
    );
  }
}
