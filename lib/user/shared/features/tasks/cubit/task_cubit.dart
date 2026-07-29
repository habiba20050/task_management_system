import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/task_model.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  final List<TaskModel> _tasks = [];

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Replace with actual API call
      // final tasks = await taskRepository.getTasks();
      
      emit(TaskLoaded(_tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      // TODO: Replace with actual API call
      // await taskRepository.addTask(task);
      
      _tasks.add(task);
      emit(TaskLoaded(List.from(_tasks)));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      // TODO: Replace with actual API call
      // await taskRepository.updateTask(task);
      
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        emit(TaskLoaded(List.from(_tasks)));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      // TODO: Replace with actual API call
      // await taskRepository.deleteTask(taskId);
      
      _tasks.removeWhere((t) => t.id == taskId);
      emit(TaskLoaded(List.from(_tasks)));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
