import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/core/constants/constants.dart';
import 'package:offline_app/future/auth/cubic/auth_cubit.dart';
import 'package:offline_app/future/home/cubic/task_cubic.dart';
import 'package:offline_app/future/home/pages/add_new_task.dart';
import 'package:offline_app/future/home/widget/date_selector.dart';
import 'package:offline_app/future/home/widget/task_card.dart';

class Homepage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const Homepage());
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<TaskCubic>().getTask(token: user.user.token);
    Connectivity().onConnectivityChanged.listen((data) {
      if (data == ConnectivityResult.wifi) {
        context.read<TaskCubic>().synscTask(user.user.token);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: const Text("My Task"),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, AddNewTask.route());
                },
                icon: const Icon(CupertinoIcons.add))
          ],
        ),
        body: BlocBuilder<TaskCubic, TaskState>(
          builder: (context, state) {
            if (state is TaskLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                  strokeWidth: 2,
                ),
              );
            } else if (state is TaskErrorState) {
              return const Center(
                child: Text("No data found"),
              );
            } else if (state is GetTaskSuccess) {
              final task = state.getTask
                  .where((element) =>
                      DateFormat('d').format(element.dueAt) ==
                          DateFormat('d').format(selectedDate) &&
                      selectedDate.month == element.dueAt.month &&
                      selectedDate.year == element.dueAt.year)
                  .toList();
              return Column(
                children: [
                  CustomDateSelector(
                    selectedDate: selectedDate,
                    onTap: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: task.length,
                        itemBuilder: (context, index) {
                          final tasks = task[index];
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTaskCard(
                                        colors: tasks.color,
                                        heasderText: tasks.title,
                                        discription: tasks.discription),
                                  ),
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: tasks.color,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      DateFormat.jm().format(tasks.dueAt),
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          );
                        }),
                  )
                ],
              );
            } else {
              return const Center(child: Text("No Data Found"));
            }
          },
        ));
  }
}
