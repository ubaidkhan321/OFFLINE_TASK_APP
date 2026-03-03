import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/core/constants/constants.dart';
import 'package:offline_app/future/auth/cubic/auth_cubit.dart';
import 'package:offline_app/future/home/cubic/task_cubic.dart';
import 'package:offline_app/future/home/pages/home_page.dart';

class AddNewTask extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const AddNewTask());
  const AddNewTask({super.key});

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  DateTime selectedDate = DateTime.now();
  Color selectedColor = AppColor.primaryColor;
  final TextEditingController title = TextEditingController();
  final TextEditingController discription = TextEditingController();
  final formKey = GlobalKey<FormState>();
  void createTask() {
    if (formKey.currentState!.validate()) {
      AuthLoggedIn authUser = context.read<AuthCubit>().state as AuthLoggedIn;
      context.read<TaskCubic>().createTask(
          title: title.text.trim(),
          discription: discription.text.trim(),
          color: selectedColor,
          dueAt: selectedDate,
          token: authUser.user.token,
          uid: authUser.user.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    discription.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Text(
          "Add New Task",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              final selectDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)));

              if (selectDate != null) {
                setState(() {
                  selectedDate = selectDate;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(DateFormat("MM-d-y").format(selectedDate)),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TaskCubic, TaskState>(
        listener: (context, state) {
          if (state is TaskErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is AddTaskSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Task Has been Added")));
            Navigator.pushAndRemoveUntil(
                context, Homepage.route(), (route) => false);
          }
        },
        builder: (context, state) {
          if (state is TaskLoadingState) {
            return Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColor.primaryColor),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Title cant empty";
                          }
                          return null;
                        },
                        controller: title,
                        decoration: InputDecoration(
                          hintText: "Title",
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 3),
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Discription cant empty";
                        }
                        return null;
                      },
                      controller: discription,
                      decoration: InputDecoration(
                        hintText: "Discription",
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 3),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    ColorPicker(
                      heading: const Text(
                        "Select Color",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      subheading: const Text("Select a Different Shade"),
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      color: selectedColor,
                      pickersEnabled: const {ColorPickerType.wheel: true},
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            minimumSize: Size(double.infinity,
                                MediaQuery.of(context).size.height * 0.07)),
                        onPressed: () {
                          createTask();
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
